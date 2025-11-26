# Markdown to Word example

This project is an example of converting a Markdown file into an MS Word document using Pandoc.

## Usage

The project uses a Makefile to simplify the build process. Below are the available commands.

### Makefile Commands

To use them, run `make <target_name>` in your terminal.


*   **`make all`** or **`make`**: The default target. Converts `main.md` into a Word document (`article.docx`), processing BibTeX references if a bibliography file is provided.

*   **`make clean`**: Removes all generated files (in this case, `article.docx`), allowing you to start a fresh build.

*   **`make help`**: Displays the list of all available targets with their descriptions.