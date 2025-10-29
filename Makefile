# Makefile for converting LaTeX to Markdown to Word document

# Variables
LATEX_SOURCE := main.tex
CONVERTED_MD := converted.md
MAIN_MD := main.md
DOCX_OUTPUT := article.docx
PYTHON_SCRIPT := main.py
PANDOC := pandoc
PYTHON := python

# Detect OS
ifeq ($(OS),Windows_NT)
    DETECTED_OS := Windows
    RM := del /Q
    ECHO := echo
else
    DETECTED_OS := $(shell uname -s)
    RM := rm -f
    ECHO := echo
endif

# Pandoc flags for Times New Roman 14pt, black text
PANDOC_FLAGS := --standalone \
                -V mainfont="Times New Roman" \
                -V fontsize=14pt \
                -V colorlinks=false \
                -V linkcolor=black \
                -V urlcolor=black

# Default target - full pipeline
all: $(DOCX_OUTPUT)

# Convert LaTeX to Markdown (creates converted.md)
$(CONVERTED_MD): $(LATEX_SOURCE) $(PYTHON_SCRIPT)
	@$(ECHO) "Converting $(LATEX_SOURCE) to $(CONVERTED_MD)..."
	$(PYTHON) $(PYTHON_SCRIPT) $(LATEX_SOURCE) $(CONVERTED_MD)
	@$(ECHO) "✓ Successfully created $(CONVERTED_MD)"

# Convert converted.md to Word
$(DOCX_OUTPUT): $(CONVERTED_MD)
	@$(ECHO) "Converting $(CONVERTED_MD) to $(DOCX_OUTPUT)..."
	@$(ECHO) "Using Times New Roman 14pt with black text..."
	$(PANDOC) $(PANDOC_FLAGS) -f markdown -t docx -o $@ $<
	@$(ECHO) "✓ Successfully created $(DOCX_OUTPUT)"

# Check if required tools are installed
check-tools:
	@$(ECHO) "Checking if required tools are installed..."
	@$(ECHO) "Detected OS: $(DETECTED_OS)"
	
	# Check Python
	@$(PYTHON) --version >nul 2>nul || (\
	 $(ECHO) "Error: $(PYTHON) is not installed or not in PATH." & \
	 exit 1)
	@$(ECHO) "✓ $(PYTHON) is installed"
	
	# Check pandoc
	@$(PANDOC) --version >nul 2>nul || (\
	 $(ECHO) "Error: $(PANDOC) is not installed." & \
	 $(ECHO) "Please install pandoc from: https://pandoc.org/installing.html" & \
	 exit 1)
	@$(ECHO) "✓ $(PANDOC) is installed"
	
	# Check Python script
	@if not exist "$(PYTHON_SCRIPT)" (\
	 $(ECHO) "Error: $(PYTHON_SCRIPT) not found." & \
	 exit 1)
	@$(ECHO) "✓ $(PYTHON_SCRIPT) found"
	
	# Check LaTeX source
	@if not exist "$(LATEX_SOURCE)" (\
	 $(ECHO) "Error: $(LATEX_SOURCE) not found." & \
	 exit 1)
	@$(ECHO) "✓ $(LATEX_SOURCE) found"

# Clean target
clean:
	@if exist "$(CONVERTED_MD)" ($(RM) "$(CONVERTED_MD)" && $(ECHO) "✓ Removed $(CONVERTED_MD)") else ($(ECHO) "No $(CONVERTED_MD) to remove")
	@if exist "$(DOCX_OUTPUT)" ($(RM) "$(DOCX_OUTPUT)" && $(ECHO) "✓ Removed $(DOCX_OUTPUT)") else ($(ECHO) "No $(DOCX_OUTPUT) to remove")

# Clean only DOCX (keep Markdown files)
clean-docx:
	@if exist "$(DOCX_OUTPUT)" ($(RM) "$(DOCX_OUTPUT)" && $(ECHO) "✓ Removed $(DOCX_OUTPUT)") else ($(ECHO) "No $(DOCX_OUTPUT) to remove")

# Clean only converted Markdown (keep main.md and DOCX)
clean-converted:
	@if exist "$(CONVERTED_MD)" ($(RM) "$(CONVERTED_MD)" && $(ECHO) "✓ Removed $(CONVERTED_MD)") else ($(ECHO) "No $(CONVERTED_MD) to remove")

# Help target
help:
	@$(ECHO) "Available targets:"
	@$(ECHO) "  all           - Full pipeline: main.tex → converted.md → article.docx"
	@$(ECHO) "  latex2md      - Convert only: main.tex → converted.md"
	@$(ECHO) "  md2docx       - Convert only: converted.md → article.docx"
	@$(ECHO) "  check-tools   - Verify all required tools are installed"
	@$(ECHO) "  clean         - Remove generated files (converted.md and article.docx)"
	@$(ECHO) "  clean-docx    - Remove only article.docx"
	@$(ECHO) "  clean-converted - Remove only converted.md"
	@$(ECHO) "  help          - Show this help message"
	@$(ECHO).
	@$(ECHO) "Project structure:"
	@$(ECHO) "  main.tex      - Source LaTeX file"
	@$(ECHO) "  main.md       - Your manual Markdown file (untouched)"
	@$(ECHO) "  converted.md  - Auto-generated from main.tex"
	@$(ECHO) "  article.docx  - Final output"

# Phony targets
.PHONY: all latex2md md2docx check-tools clean clean-docx clean-converted help

# Individual conversion targets
latex2md: $(CONVERTED_MD)

md2docx: $(DOCX_OUTPUT)

# Alias
docx: $(DOCX_OUTPUT)