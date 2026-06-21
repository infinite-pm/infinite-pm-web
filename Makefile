# Makefile for infinite-pm-web — build the published site from the ipm-intro
# source repo (sibling) via the md-embed + md-html + slides-copy tools in
# ipm-tools.
#
#   reembed    : md-embed --force over ../ipm-intro  ->  ../ipm-intro/_ipm/*.svg
#   slides     :        slides.conf.json             ->  docs/slides/
#   intro HTML : ../ipm-intro/md-html.conf.json      ->  docs/intro/
#
# `reembed` writes back into the ipm-intro SOURCE repo (re-renders its embedded
# ipmt diagrams); slides + intro-html then consume those fresh SVGs and only
# write under this repo's docs/. md-html resolves every path (sources, out_dir,
# GitHub "view source" links) relative to its config's own directory, so that
# config stays in ipm-intro at the source root and this Makefile points at it.

IPM_TOOLS    ?= ../ipm-tools
IPM_INTRO    ?= ../ipm-intro
MD_HTML_CONF ?= $(IPM_INTRO)/md-html.conf.json
SLIDES_CONF  ?= slides.conf.json

MD_EMBED = go run -C $(IPM_TOOLS) ./cmd/md-embed        --root  $(abspath $(IPM_INTRO))
SLIDES   = go run -C $(IPM_TOOLS) ./cmd-dev/slides-copy -config $(abspath $(SLIDES_CONF))
MD_HTML  = go run -C $(IPM_TOOLS) ./cmd/md-html         -config $(abspath $(MD_HTML_CONF))

.PHONY: all reembed slides intro-html check reembed-check slides-check html-check help

all: reembed slides intro-html

reembed:
	$(MD_EMBED) --force

slides:
	$(SLIDES) -prune -verbose

intro-html:
	$(MD_HTML) -verbose

check: reembed-check slides-check html-check

reembed-check:
	$(MD_EMBED) --dry-run

slides-check:
	$(SLIDES) -prune -check

html-check:
	$(MD_HTML) -check

help:
	@echo "Available targets:"
	@echo "  all          - reembed + slides + intro HTML [default]"
	@echo "  reembed      - re-render ipmt blocks in ipm-intro to _ipm/*.svg (--force)"
	@echo "  slides       - copy carousel SVGs to docs/slides/ (verbose, prunes stale)"
	@echo "  intro-html   - render Markdown intro to docs/intro/ (verbose)"
	@echo "  check        - dry run all three; write/delete nothing"
	@echo ""
	@echo "Override IPM_TOOLS / IPM_INTRO / MD_HTML_CONF / SLIDES_CONF as needed."
