# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Overview

A nix flake that takes a Pandoc-flavored markdown resume and renders it to HTML, PDF, TXT, and DOCX formats. The justfile serves as both the build script and the packaged executable.

## Development

Enter the dev shell:
```bash
nix develop
```

## Build Commands

All commands are run via `just` and require a markdown file as input. Set environment variables for resume metadata:

```bash
export VERSION="1.0.0"
export EMAIL="you@example.com"
export NAME="Your Name"
export PHONE="555-1234"
export GITHUB_URL="https://github.com/you/repo"
```

Generate outputs:
```bash
just html-embedded resume.md   # HTML with embedded CSS (for inclusion in pages)
just html-standalone resume.md # Full standalone HTML page
just txt resume.md             # Plain text (80 columns, reference links)
just pdf resume.html           # PDF from existing HTML (requires html-to-pdf)
just docx resume.md            # Word document
```

## Architecture

The justfile is the core: it wraps pandoc with resume-specific options and gets packaged as the `resume-builder` executable via nix.

**Templates:**
- `pandoc-template-html-embedded.html` - For embedding in other pages, includes header/footer with version links
- `pandoc-template-html-standalone.html` - Full HTML document
- `pandoc-template-txt.txt` - Minimal template for plain text

**Lua filter (`pandoc-lua-filter-txt.lua`):**
- Adds banner and horizontal rules to text output
- Handles `position-flex` div classes for formatted job title/date lines
- Centers trailer with build date and version
