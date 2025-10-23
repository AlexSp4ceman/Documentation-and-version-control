# Makefile for converting Markdown to Word document with specific formatting

# Variables
MD_SOURCE := main.md
DOCX_OUTPUT := article.docx
PANDOC := pandoc

# Detect OS
ifeq ($(OS),Windows_NT)
    DETECTED_OS := Windows
else
    DETECTED_OS := $(shell uname -s)
endif

# Platform-specific commands
ifeq ($(DETECTED_OS),Windows)
    RM := del /Q
    ECHO := echo
else
    RM := rm -f
    ECHO := echo
endif

# Pandoc flags for Times New Roman 14pt, black text
PANDOC_FLAGS := --standalone \
                --toc \
                --toc-depth=3 \
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
	@$(ECHO) "Using Times New Roman 14pt with black text..."
	$(PANDOC) $(PANDOC_FLAGS) -f markdown -t docx -o $@ $<
	@$(ECHO) "Successfully created $(DOCX_OUTPUT)"

# Check if pandoc is installed
check-pandoc:
	@where pandoc >nul 2>nul || (\
	 $(ECHO) "Error: pandoc is not installed." & \
	 $(ECHO) "Please refer to README.md for installation instructions." & \
	 exit 1)
	@$(ECHO) "✓ pandoc is installed"

# Clean target (Windows compatible)
clean:
	@if exist "$(DOCX_OUTPUT)" ($(RM) "$(DOCX_OUTPUT)" && $(ECHO) "Cleaned up generated files") else ($(ECHO) "No files to clean")

# Help target
help:
	@$(ECHO) "Available targets:"
	@$(ECHO) "  all           - Convert markdown to Word"
	@$(ECHO) "  docx          - Same as 'all'"
	@$(ECHO) "  check-pandoc  - Verify pandoc is installed"
	@$(ECHO) "  clean         - Remove generated files"
	@$(ECHO) "  help          - Show this help message"
	@$(ECHO).

# Phony targets
.PHONY: all docx docx-preserve docx-custom check-pandoc clean help

# Alias
docx: $(DOCX_OUTPUT)