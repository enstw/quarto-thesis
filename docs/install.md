# Installing Quarto for PDF and Reveal.js

This guide covers the minimum setup for rendering `.qmd` files to PDF and
Reveal.js HTML presentations on macOS and Windows.

## 1. Install Quarto

The most reliable path is the official installer from:

https://quarto.org/docs/get-started/

macOS options:

```bash
# Official installer: download from quarto.org
# Homebrew users can also install Quarto with Homebrew if desired.
quarto check
```

Windows options:

```powershell
# Official installer: download the Windows installer from quarto.org
quarto check
```

After installation, open a new terminal and verify:

```bash
quarto --version
quarto check
```

## 2. Install TinyTeX for PDF

Quarto can render HTML without LaTeX, but PDF output requires a TeX
distribution. Quarto recommends TinyTeX for a lightweight TeX Live setup:

```bash
quarto install tinytex
```

Then check the toolchain:

```bash
quarto check
quarto tools
```

Render a PDF:

```bash
quarto render presentation.qmd --to beamer
```

## 3. Render Reveal.js HTML

Reveal.js output does not require LaTeX:

```bash
quarto render presentation.qmd --to revealjs
quarto preview presentation.qmd
```

Render a single self-contained HTML file for sharing:

```bash
quarto render presentation.qmd --to revealjs -M embed-resources:true
```

## 4. Optional Diagram Dependencies

For local PlantUML rendering, install Java plus PlantUML.

macOS:

```bash
brew install plantuml graphviz
```

Windows:

```powershell
# Option A: use your preferred package manager for plantuml and graphviz.
# Option B: download plantuml.jar, install Java, then set PLANTUML_JAR.
$env:PLANTUML_JAR = "C:\tools\plantuml\plantuml.jar"
```

If local PlantUML is not available, the scripts can fall back to Kroki:

```bash
scripts/plantuml-to-svg.sh diagrams/quarto-flow.puml diagrams/quarto-flow.svg
```

## 5. Useful Checks

```bash
quarto check
quarto tools
quarto render presentation.qmd --to beamer
quarto render presentation.qmd --to revealjs
quarto render slides/slide-styles.qmd
```

If PDF rendering fails with a missing LaTeX package, TinyTeX usually installs it
automatically. If it does not, use `tlmgr install <package-name>`.
