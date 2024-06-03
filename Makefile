EXAMPLES := \
	computer-science

FONTSDIR := examples/fonts
TYPST    := typst

EXAMPLES_TARGETS := $(patsubst %,examples/%.pdf,$(EXAMPLES))

.PHONY: examples
examples: $(EXAMPLES_TARGETS)

.SECONDEXPANSION:
examples/%.pdf: examples/%/main.typ $(wildcard examples/%/*.typ) khw.typ
	$(info TYPST	$@)
	@'$(TYPST)' compile --root . --font-path '$(FONTSDIR)' $< $@

.PHONY: clean
clean:
	$(info RM	$(EXAMPLES_TARGETS))
	@rm -f $(EXAMPLES_TARGETS)
