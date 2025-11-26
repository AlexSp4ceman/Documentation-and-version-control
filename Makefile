# Variables
MD_SOURCE := main.md
DOCX_OUTPUT := article.docx
REFERENCE_DOC := custom-reference-doc.docx

OPTIONS = -d default.yaml \
	--from=markdown \
	--citeproc \
	--reference-doc=$(REFERENCE_DOC)

# Platform-specific commands
ifeq ($(OS),Windows_NT)
    RM := del /Q
    MK_BUILD = if not exist build mkdir build
else
    RM := rm -f
    MK_BUILD = mkdir -p build
endif

# Default target
all: $(DOCX_OUTPUT)

# Main conversion rule
$(DOCX_OUTPUT): $(MD_SOURCE) $(REFERENCE_DOC)
	@echo "Converting $(MD_SOURCE) to Word."
	$(MK_BUILD)
	pandoc $(MD_SOURCE) $(OPTIONS) --output=$@ --to=docx
	@echo "Successfully created $(DOCX_OUTPUT) with GOST-formatted references"

# Clean target (Windows compatible)
clean:
	@if exist "$(DOCX_OUTPUT)" ($(RM) "$(DOCX_OUTPUT)" && echo "Cleaned up generated files") else (echo "No files to clean")

# Help target
help:
	@echo "Available targets:"
	@echo "  all           - Convert markdown to Word with BibTeX references"
	@echo "  clean         - Remove generated files"
	@echo "  help          - Show this help message"
	@echo.

# Phony targets
.PHONY: all docx clean help check-files

# Alias
docx: $(DOCX_OUTPUT)