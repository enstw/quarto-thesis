# Reveal.js Theme Browsing and Customization

Quarto Reveal.js themes can be built-in names, local SCSS files, or a list that
combines both.

## Built-In Themes

The built-in Reveal.js themes include:

- `beige`
- `blood`
- `dark`
- `default`
- `dracula`
- `league`
- `moon`
- `night`
- `serif`
- `simple`
- `sky`
- `solarized`

Use one directly:

```yaml
format:
  revealjs:
    theme: dark
```

## Use the Custom Theme in This Repo

This repository includes `themes/thesis.scss`.

From `slides/slide-styles.qmd`, the path is:

```yaml
format:
  revealjs:
    theme: [default, ../themes/thesis.scss]
```

From a file at the repository root, use:

```yaml
format:
  revealjs:
    theme: [default, themes/thesis.scss]
```

## Download a Theme Source File

The official Quarto docs link to the built-in theme source files in the Quarto
CLI repository. You can copy a theme and customize it.

macOS/Linux:

```bash
mkdir -p themes/vendor
curl -L \
  -o themes/vendor/serif.scss \
  https://raw.githubusercontent.com/quarto-dev/quarto-cli/main/src/resources/formats/revealjs/themes/serif.scss
```

Windows PowerShell:

```powershell
New-Item -ItemType Directory -Force themes\vendor
Invoke-WebRequest `
  -Uri https://raw.githubusercontent.com/quarto-dev/quarto-cli/main/src/resources/formats/revealjs/themes/serif.scss `
  -OutFile themes\vendor\serif.scss
```

Then use it:

```yaml
format:
  revealjs:
    theme: themes/vendor/serif.scss
```

## SCSS Structure

Quarto theme files commonly use two sections:

```scss
/*-- scss:defaults --*/
$body-bg: #fbfaf7;
$body-color: #202124;
$link-color: #1c6b8c;

/*-- scss:rules --*/
.reveal .slide blockquote {
  border-left: 0.25rem solid $link-color;
  padding-left: 0.8rem;
}
```

Use `defaults` for theme variables and `rules` for CSS selectors. Rules that
target slide content normally use `.reveal .slide` so they override Reveal.js
theme defaults.

## Theme Workflow

1. Start with a built-in theme such as `default`, `simple`, or `serif`.
2. Add a local SCSS file in `themes/`.
3. Override a few variables first: background, text color, link color, heading
   font, heading color.
4. Add specific rules for repeated components such as callouts, diagrams,
   tables, and title slides.
5. Render often with `quarto preview slides/slide-styles.qmd`.
