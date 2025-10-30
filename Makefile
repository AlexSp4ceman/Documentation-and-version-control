# Makefile for converting Markdown to Word document with specific formatting

# Variables
MD_SOURCE := main.md
DOCX_OUTPUT := article.docx
PANDOC := pandoc
ECHO := echo

# Platform-specific commands
ifeq ($(OS),Windows_NT)
    RM := del /Q
else
    RM := rm -f
endif

# Pandoc flags for Times New Roman 14pt, black text
PANDOC_FLAGS := --standalone \
                -V mainfont="Times New Roman" \
                -V fontsize=14pt \
                -V colorlinks=false \
                -V linkcolor=black \
                -V urlcolor=black

# Default target
all: $(DOCX_OUTPUT)

# Main conversion rule
$(DOCX_OUTPUT): $(MD_SOURCE)
	@$(ECHO) "Converting $(MD_SOURCE) to Word format..."
	$(PANDOC) $(PANDOC_FLAGS) -f markdown -t docx -o $@ $<
	@$(ECHO) "Successfully created $(DOCX_OUTPUT)"

# Clean target (Windows compatible)
clean:
	@if exist "$(DOCX_OUTPUT)" ($(RM) "$(DOCX_OUTPUT)" && $(ECHO) "Cleaned up generated files") else ($(ECHO) "No files to clean")

# Help target
help:
	@$(ECHO) "Available targets:"
	@$(ECHO) "  all           - Convert markdown to Word"
	@$(ECHO) "  docx          - Same as 'all'"
	@$(ECHO) "  clean         - Remove generated files"
	@$(ECHO) "  help          - Show this help message"
	@$(ECHO).

# Phony targets
.PHONY: all docx docx-preserve docx-custom check-pandoc clean help

# Alias
docx: $(DOCX_OUTPUT)