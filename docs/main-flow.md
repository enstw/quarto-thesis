# Main Flow: `presentation.qmd` to PDF and Reveal.js HTML

The primary workflow in this repository is:

```text
presentation.qmd
├── _output/presentation.pdf
└── _output/presentation.html
```

`presentation.qmd` declares two presentation formats in its YAML front matter:

```yaml
format:
  revealjs:
    theme: [default, themes/thesis.scss]
  beamer:
    theme: metropolis
    pdf-engine: xelatex
    include-in-header:
      - assets/tex/presentation-preamble.tex
```

Use an explicit render target while learning:

```bash
quarto render presentation.qmd --to revealjs
quarto render presentation.qmd --to beamer
```

On Windows PowerShell, the same Quarto commands work from the repository root.
The repository also includes an end-to-end check:

```powershell
Set-ExecutionPolicy -Scope Process Bypass
.\scripts\render-workflow.ps1
```

The output names come from the source filename:

| Source | Format | Output |
|---|---|---|
| `presentation.qmd` | `revealjs` | `_output/presentation.html` |
| `presentation.qmd` | `beamer` | `_output/presentation.pdf` |

## Beamer Customization

The PDF output intentionally loads:

```yaml
include-in-header:
  - assets/tex/presentation-preamble.tex
```

That preamble reproduces the custom Beamer styling used in the Taiwan-drills
project:

- top miniframes-style section navigation bar
- Metropolis frame-title accent line
- bottom three-part information bar for title, author, date, and page count
- XeLaTeX CJK font setup through `assets/fonts/ENSFont-Regular.ttf`

This is the customization visible in the original `presentation.pdf`: the top
bar tracks sections, the frame title keeps the Metropolis accent rule, and the
bottom bar holds title, author, date, and slide count.

## Why `--to beamer` Instead of `--to pdf`

For slide decks, `beamer` is the PDF presentation format. It uses LaTeX Beamer
under the hood and writes a `.pdf` file.

Use:

```bash
quarto render presentation.qmd --to beamer
```

Use `--to pdf` when the target is a document or article-style PDF, not a slide
deck.

## Preview HTML Slides

During editing:

```bash
quarto preview presentation.qmd
```

Quarto opens the Reveal.js deck and refreshes it when the source changes.

## Share a Single HTML File

To embed local CSS and supporting assets into the HTML file:

```bash
quarto render presentation.qmd --to revealjs -M embed-resources:true
```

For diagrams, keep the `.puml` source and generated `.svg` in the repository.
The main presentation references:

```markdown
![Quarto rendering pipeline](diagrams/quarto-flow.svg)
```

## Relationship to the Case Study

The Taiwan-drills project uses the same conceptual source-to-output flow, but
wraps it with a project-specific build script:

```text
work/presentation.qmd -> work/_output/presentation.pdf
```

Then `scripts/build.py` copies the PDF to the repo-level `_output/` directory
with a branch-based filename. That is useful for a template system, but the
core Quarto idea remains the same: the presentation source is a `.qmd` file,
and Quarto renders the output files.
