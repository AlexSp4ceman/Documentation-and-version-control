import re
import sys

class LatexToMarkdown:
    def __init__(self):
        self.sections = []
        self.current_section = []
        self.in_table = False
        self.table_content = []
        self.table_caption = ""
        self.in_figure = False
        self.figure_content = []
        
    def parse_latex(self, latex_content):
        lines = latex_content.split('\n')
        markdown_lines = []
        
        i = 0
        while i < len(lines):
            line = lines[i].strip()
            
            # Skip documentclass and package declarations
            if line.startswith('\\documentclass') or line.startswith('\\usepackage'):
                i += 1
                continue
                
            # Handle title, author, date
            elif line.startswith('\\title'):
                title = self.extract_content(line)
                markdown_lines.append(f"# {title}\n")
            elif line.startswith('\\author'):
                author = self.extract_content(line)
                markdown_lines.append(f"**Автор:** {author}  \n")
            elif line.startswith('\\date'):
                date = self.extract_content(line)
                markdown_lines.append(f"**Дата:** {date}\n")
            elif line.startswith('\\maketitle'):
                markdown_lines.append("***\n\n")
                
            # Handle sections
            elif line.startswith('\\section'):
                if line.startswith('\\section*'):
                    content = self.extract_content(line)
                    if 'Аннотация' in content:
                        markdown_lines.append("## Аннотация\n\n")
                        # Collect abstract content
                        i += 1
                        abstract_lines = []
                        while i < len(lines) and not lines[i].strip().startswith('\\'):
                            if lines[i].strip() and not lines[i].strip().startswith('%'):
                                abstract_lines.append(lines[i].strip())
                            i += 1
                        abstract_text = ' '.join(abstract_lines)
                        markdown_lines.append(abstract_text + '\n')
                        markdown_lines.append("\n***\n\n")
                        continue
                else:
                    content = self.extract_content(line)
                    markdown_lines.append(f"## {content}\n\n")
                    
            elif line.startswith('\\subsection'):
                content = self.extract_content(line)
                markdown_lines.append(f"### {content}\n\n")
            elif line.startswith('\\subsubsection'):
                content = self.extract_content(line)
                markdown_lines.append(f"#### {content}\n\n")
                
            # Handle pagebreak
            elif line.startswith('\\pagebreak'):
                markdown_lines.append("\n")
                
            # Handle tables
            elif '\\begin{table}' in line:
                self.in_table = True
                self.table_content = []
                self.table_caption = ""
            elif '\\end{table}' in line:
                self.in_table = False
                markdown_lines.extend(self.process_table())
                self.table_content = []
                self.table_caption = ""
            elif self.in_table:
                self.table_content.append(line)
                
            # Handle figures
            elif '\\begin{center}' in line and i + 1 < len(lines) and '\\includegraphics' in lines[i + 1]:
                self.in_figure = True
                self.figure_content = [line]
            elif '\\end{center}' in line and self.in_figure:
                self.figure_content.append(line)
                self.in_figure = False
                markdown_lines.extend(self.process_figure())
                self.figure_content = []
            elif self.in_figure:
                self.figure_content.append(line)
                
            # Handle mathematical expressions
            elif '\\[' in line and '\\]' in line:
                math_content = re.search(r'\\\[(.*?)\\\]', line)
                if math_content:
                    math_text = math_content.group(1).strip()
                    markdown_lines.append(f"$$\n{math_text}\n$$\n\n")
                    
            # Handle regular content
            elif line and not line.startswith('\\') and not self.in_table and not self.in_figure:
                cleaned_line = self.clean_latex_commands(line)
                if cleaned_line and not cleaned_line.startswith('%'):
                    # Handle numbered lists
                    if re.match(r'^\d+\.', cleaned_line):
                        markdown_lines.append(cleaned_line + '\n')
                    else:
                        markdown_lines.append(cleaned_line + '\n\n')
            
            i += 1
            
        return ''.join(markdown_lines)
    
    def extract_content(self, line):
        """Extract content from LaTeX commands like \command{content}"""
        match = re.search(r'\{(.*?)\}', line)
        return match.group(1) if match else ""
    
    def clean_latex_commands(self, text):
        """Remove or convert LaTeX commands to Markdown"""
        # Handle bold text
        text = re.sub(r'\\textbf\{(.*?)\}', r'**\1**', text)
        
        # Handle citations
        text = re.sub(r'\\cite\{.*?\}', '', text)
        
        # Handle mathematical expressions in text
        text = re.sub(r'\\\[(.*?)\\\]', r'$$\1$$', text)
        text = re.sub(r'\\\((.*?)\\\)', r'$\1$', text)
        
        # Handle itemize environments
        text = re.sub(r'\\begin\{itemize\}', '', text)
        text = re.sub(r'\\end\{itemize\}', '', text)
        text = re.sub(r'\\item\s*', '- ', text)
        
        # Remove other LaTeX commands but keep the content
        text = re.sub(r'\\[a-zA-Z]+\{.*?\}', lambda x: self.extract_command_content(x.group()), text)
        text = re.sub(r'\\[a-zA-Z]+', '', text)
        
        # Clean up multiple spaces
        text = re.sub(r'\s+', ' ', text)
        
        return text.strip()
    
    def extract_command_content(self, command):
        """Extract content from LaTeX commands"""
        match = re.search(r'\{(.*?)\}', command)
        return match.group(1) if match else ""
    
    def process_table(self):
        """Convert LaTeX table to Markdown table"""
        markdown_lines = []
        caption = ""
        header = []
        rows = []
        in_tabular = False
        table_num = 1
        
        for line in self.table_content:
            line = line.strip()
            
            if '\\caption' in line:
                caption_match = re.search(r'\\caption\{(.*?)\}', line)
                if caption_match:
                    caption = caption_match.group(1)
                    # Extract table number from caption if present
                    num_match = re.search(r'Таблица\s+(\d+)', caption)
                    if num_match:
                        table_num = num_match.group(1)
                        caption = re.sub(r'Таблица\s+\d+:\s*', '', caption)
            
            elif '\\begin{tabular}' in line:
                in_tabular = True
                continue
            elif '\\end{tabular}' in line:
                in_tabular = False
                continue
                
            elif in_tabular and '\\hline' not in line and line:
                # Process table row
                row = []
                # Split by & but avoid splitting within math mode
                cells = re.split(r'(?<!\\)&', line)
                for cell in cells:
                    cleaned_cell = self.clean_latex_commands(cell.replace('\\\\', '').strip())
                    # Remove any remaining LaTeX commands
                    cleaned_cell = re.sub(r'\\[a-zA-Z]+\{.*?\}', '', cleaned_cell)
                    cleaned_cell = re.sub(r'\\[a-zA-Z]+', '', cleaned_cell)
                    row.append(cleaned_cell)
                
                if not header and row:
                    header = row
                elif row:
                    rows.append(row)
        
        if header:
            # Add table caption
            if caption:
                markdown_lines.append(f"**Таблица {table_num}: {caption}**\n\n")
            else:
                markdown_lines.append(f"**Таблица {table_num}**\n\n")
            
            # Create markdown table
            markdown_lines.append('| ' + ' | '.join(header) + ' |\n')
            markdown_lines.append('| ' + ' | '.join(['---'] * len(header)) + ' |\n')
            
            for row in rows:
                markdown_lines.append('| ' + ' | '.join(row) + ' |\n')
            
            markdown_lines.append('\n')
        
        return markdown_lines
    
    def process_figure(self):
        """Convert LaTeX figure to Markdown image"""
        markdown_lines = []
        caption = ""
        image_path = ""
        
        for line in self.figure_content:
            line = line.strip()
            
            if '\\includegraphics' in line:
                path_match = re.search(r'\\includegraphics\[.*?\]\{(.*?)\}', line)
                if path_match:
                    image_path = path_match.group(1)
            
            elif '\\caption' in line or '\\captionof{figure}' in line:
                caption_match = re.search(r'\\caption(?:of\{figure\})?\{(.*?)\}', line)
                if caption_match:
                    caption = caption_match.group(1)
        
        if image_path:
            markdown_lines.append(f"![{caption}]({image_path})\n\n")
            if caption and 'автора' not in caption.lower():
                markdown_lines.append(f"*{caption}*\n\n")
        
        return markdown_lines

def convert_latex_to_markdown(input_file, output_file):
    """Main conversion function"""
    try:
        with open(input_file, 'r', encoding='utf-8') as f:
            latex_content = f.read()
        
        parser = LatexToMarkdown()
        markdown_content = parser.parse_latex(latex_content)
        
        with open(output_file, 'w', encoding='utf-8') as f:
            f.write(markdown_content)
        
        print(f"Successfully converted {input_file} to {output_file}")
        return True
        
    except Exception as e:
        print(f"Error: {e}")
        return False

def main():
    if len(sys.argv) != 3:
        print("Usage: python main.py input.tex output.md")
        print("Example: python main.py main.tex converted.md")
        return
    
    input_file = sys.argv[1]
    output_file = sys.argv[2]
    
    convert_latex_to_markdown(input_file, output_file)

if __name__ == "__main__":
    main()