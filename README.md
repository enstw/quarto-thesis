# Quarto Thesis

A compact teaching repo for learning how to render Quarto `.qmd` files into:

- PDF documents
- Reveal.js HTML presentations
- SVG diagrams generated from PlantUML source

The examples are intentionally plain text first. You can copy a single `.qmd`
file, render it, and then gradually add themes, diagrams, and slide features.

## Repository Map

```text
.
├── _quarto.yml                  # Project-level render defaults
├── examples/
│   └── dual-output.qmd          # Same source rendered to PDF or Reveal.js
├── slides/
│   └── slide-styles.qmd         # Reveal.js deck demonstrating slide styles
├── themes/
│   └── thesis.scss              # Custom Reveal.js SCSS theme
├── diagrams/
│   ├── quarto-flow.puml         # PlantUML source
│   └── quarto-flow.svg          # Pre-rendered SVG used by the examples
├── scripts/
│   ├── plantuml-to-svg.sh       # macOS/Linux PlantUML -> SVG helper
│   └── plantuml-to-svg.ps1      # Windows PowerShell helper
└── docs/
    ├── install.md
    ├── themes.md
    └── plantuml.md
```

## Quick Start

Install Quarto, then verify it:

```bash
quarto check
```

Install TinyTeX for PDF rendering:

```bash
quarto install tinytex
```

Render the example PDF:

```bash
quarto render examples/dual-output.qmd --to pdf
```

Render the same source as a Reveal.js HTML presentation:

```bash
quarto render examples/dual-output.qmd --to revealjs
```

Render the slide-style gallery:

```bash
quarto render slides/slide-styles.qmd
```

Preview the deck with live reload:

```bash
quarto preview slides/slide-styles.qmd
```

Outputs are written to `_output/`.

## Rebuild Diagrams

The repository includes a pre-rendered SVG so the examples render offline. To
regenerate it from PlantUML source:

```bash
scripts/plantuml-to-svg.sh diagrams/quarto-flow.puml diagrams/quarto-flow.svg
```

On Windows PowerShell:

```powershell
.\scripts\plantuml-to-svg.ps1 diagrams\quarto-flow.puml diagrams\quarto-flow.svg
```

The scripts try, in order:

1. A local `plantuml` command
2. A local PlantUML jar pointed to by `PLANTUML_JAR`
3. The public Kroki API

## Documentation

- [Installation guide](docs/install.md)
- [Theme browsing and customization](docs/themes.md)
- [PlantUML to SVG workflow](docs/plantuml.md)

## Primary References

- Quarto Get Started: https://quarto.org/docs/get-started/
- Quarto CLI reference: https://quarto.org/docs/cli/
- Quarto PDF basics: https://quarto.org/docs/output-formats/pdf-basics
- Quarto Reveal.js guide: https://quarto.org/docs/presentations/revealjs/
- Quarto Reveal themes: https://quarto.org/docs/presentations/revealjs/themes.html
- PlantUML command line: https://plantuml.com/command-line
- Kroki documentation: https://docs.kroki.io/kroki/
