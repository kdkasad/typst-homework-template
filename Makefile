EXAMPLES_DIR := examples
TYPST        := typst

EXAMPLES_TARGETS := $(patsubst %,%.pdf,$(filter-out %.pdf,$(wildcard $(EXAMPLES_DIR)/*)))

.PHONY: all
all: examples manual.pdf

.PHONY: examples
examples: $(EXAMPLES_TARGETS)

manual.pdf: manual.typ khw.typ
	$(info TYPST	$@)
	@$(TYPST) compile --root . $< $@

.SECONDEXPANSION:
examples/%.pdf: examples/%/main.typ $(wildcard examples/%/*) khw.typ
	$(info TYPST	$@)
	@$(TYPST) compile --root . $< $@

.PHONY: clean
clean:
	$(info RM	$(EXAMPLES_TARGETS))
	@rm -f $(EXAMPLES_TARGETS)
	$(info RM	manual.pdf)
	@rm -f manual.pdf

.PHON: clean-all-pdfs
clean-all-pdfs:
	find . -type f -name '*.pdf' -delete
