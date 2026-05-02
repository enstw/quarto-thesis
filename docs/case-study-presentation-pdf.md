# 補充案例：模板專案中的 `presentation.pdf` 產生方式

主流程請先看 [`main-flow.md`](main-flow.md)：一個 `presentation.qmd`
可以直接 render 成：

```text
presentation.qmd
├── _output/presentation.pdf
└── _output/presentation.html
```

這份補充案例說明另一種較完整的模板化專案流程。`解析中國大陸圍台軍演`
專案仍然是以 `work/presentation.qmd` 作為投影片來源；差別是它不直接在
repo 根目錄執行 `quarto render work/presentation.qmd`，而是用
`scripts/build.py` 先產生 `work/_quarto.yml`，再從 `work/` 執行
`quarto render`。

因此概念上仍是：

```text
work/presentation.qmd -> work/_output/presentation.pdf
```

只是 build script 另外負責 metadata 套版、輸出檔名與複製位置。

## 專案結構

案例專案的核心檔案如下：

```text
.
├── WORK.json
├── scripts/
│   └── build.py
├── assets/
│   └── templates/
│       └── presentation/
│           ├── _quarto.yml
│           └── preamble.tex
└── work/
    ├── presentation.qmd
    ├── references.bib
    └── _quarto.yml        # build.py 產生，gitignored
```

其中：

- `WORK.json` 保存目前 work item 的標題、作者、日期與類型。
- `assets/templates/presentation/_quarto.yml` 保存 Beamer 輸出的固定設定。
- `assets/templates/presentation/preamble.tex` 保存 XeLaTeX、中文字型與 Beamer header/footer 設定。
- `work/presentation.qmd` 是實際投影片內容。
- `work/_quarto.yml` 是每次 build 時重新產生的 Quarto project config。
- `scripts/build.py` 是唯一建議使用的 PDF build entrypoint。

## `WORK.json`

案例中的 metadata：

```json
{
  "type": "presentation",
  "title": "解析中國大陸圍台軍演",
  "subtitle": "",
  "author": "莊佑邦",
  "date": "2026-04-30",
  "created": "2026-04-30",
  "variant": "reading-guide"
}
```

`type: "presentation"` 讓 build script 選擇：

```text
assets/templates/presentation/_quarto.yml
```

## Presentation Template

模板 `_quarto.yml` 的重點如下：

```yaml
project:
  type: default
  output-dir: _output
  render:
    - presentation.qmd

title: "[簡報標題]"
subtitle: "[副標題]"
author: "[作者]"
date: "[日期]"

format:
  beamer:
    pdf-engine: xelatex
    include-in-header:
      - ../assets/templates/presentation/preamble.tex
    theme: metropolis
    colortheme: default
    aspectratio: 169
    navigation: empty
    colorlinks: true

bibliography: references.bib
csl: ../assets/chicago-fullnote-bibliography.csl
lang: zh-Hant
```

這裡有幾個設計重點：

- `format: beamer` 讓 Quarto 產生 Beamer PDF。
- `pdf-engine: xelatex` 支援中文與自訂字型。
- `theme: metropolis` 使用 Beamer Metropolis theme。
- `include-in-header` 載入專案的 LaTeX preamble。
- `project.render` 指定預設輸入檔是 `presentation.qmd`。
- `output-dir: _output` 讓 Quarto 把 `presentation.pdf` 寫到 `work/_output/`。

## Build Command

從案例專案根目錄執行：

```bash
scripts/build.py
```

不要直接執行：

```bash
quarto render work/presentation.qmd
```

原因是直接 render 單檔時，不會先把 `WORK.json` 的標題、作者、日期寫入
`work/_quarto.yml`，也不會套用專案定義的輸出檔名規則。

## `scripts/build.py` 做了什麼

Build script 的流程是：

1. 確認目前在 git repo 根目錄。
2. 讀取 `WORK.json`。
3. 依 `WORK.json` 的 `type` 找到對應模板：

   ```text
   assets/templates/presentation/_quarto.yml
   ```

4. 把模板中的 placeholder 換成 `WORK.json` 的值：

   ```text
   "[簡報標題]" -> title
   "[副標題]"   -> subtitle
   "[作者]"     -> author
   "[日期]"     -> date
   ```

5. 寫出產生後的設定檔：

   ```text
   work/_quarto.yml
   ```

6. 從 `work/` 目錄執行：

   ```bash
   quarto render
   ```

7. Quarto 產生：

   ```text
   work/_output/presentation.pdf
   ```

8. Build script 再把最新 PDF 複製到 repo 根目錄 `_output/`，並用 branch 名稱命名：

   ```text
   _output/presentation-2026-prc-taiwan-encirclement-drills.pdf
   ```

## 為什麼從 `work/` render

`work/` 是 Quarto project 的實際工作目錄。`work/_quarto.yml` 中的路徑都是
以 `work/` 為基準，例如：

```yaml
include-in-header:
  - ../assets/templates/presentation/preamble.tex

csl: ../assets/chicago-fullnote-bibliography.csl
```

如果從 repo 根目錄直接 render `work/presentation.qmd`，相對路徑、project
設定與輸出位置都容易和預期不一致。

## Beamer / LaTeX 依賴

這個案例需要：

```bash
brew install quarto
quarto install tinytex
brew install librsvg
```

TinyTeX 需要的主要 LaTeX package：

```bash
tlmgr install beamertheme-metropolis xecjk
```

用途：

- `beamertheme-metropolis`: Beamer Metropolis theme。
- `xecjk`: XeLaTeX 中文排版。
- `fontspec`: XeLaTeX 字型設定，通常會隨 TinyTeX dependency 安裝。
- `librsvg`: 提供 `rsvg-convert`，讓 SVG 圖表可以進入 Beamer PDF。

檢查方式：

```bash
kpsewhich beamerthememetropolis.sty
kpsewhich xeCJK.sty
kpsewhich fontspec.sty
command -v rsvg-convert
quarto check
```

## Render Log 的關鍵訊號

成功 render 時會看到類似：

```text
pandoc
  to: beamer
  output-file: presentation.tex
  pdf-engine: xelatex

Rendering PDF
running xelatex - 1
running xelatex - 2

Output created: _output/presentation.pdf

→ quarto render (cwd=work/)
→ _output/presentation-2026-prc-taiwan-encirclement-drills.pdf
```

第一個 `_output/presentation.pdf` 是 Quarto 在 `work/_output/` 產生的檔案。
第二個 `_output/presentation-2026-prc-taiwan-encirclement-drills.pdf` 是
`scripts/build.py` 複製到 repo 根目錄後的交付檔。

## 如果同一份 `presentation.qmd` 也要輸出 HTML

若這類模板專案要讓同一份 `presentation.qmd` 同時產生
`presentation.pdf` 與 `presentation.html`，需要讓產生後的
`work/_quarto.yml` 同時包含 `beamer` 與 `revealjs`：

```yaml
format:
  beamer:
    pdf-engine: xelatex
    theme: metropolis
  revealjs:
    theme: [default, ../themes/thesis.scss]
```

然後從 `work/` 目錄 render 指定 target：

```bash
quarto render presentation.qmd --to beamer
quarto render presentation.qmd --to revealjs
```

輸出會是：

```text
work/_output/presentation.pdf
work/_output/presentation.html
```

## Render Draft

如果要 render 另一個 work 目錄中的檔案，例如 `draft.qmd`：

```bash
scripts/build.py --target draft.qmd
```

這會執行：

```bash
cd work
quarto render draft.qmd
```

並把結果複製到 repo 根目錄：

```text
_output/presentation-2026-prc-taiwan-encirclement-drills-draft.pdf
```

## 可複製的模式

這個 build model 適合需要「模板固定、內容分離、metadata 由外部檔案管理」
的學術寫作或簡報專案：

```text
metadata file  ->  template _quarto.yml  ->  generated work/_quarto.yml
       |                    |                         |
       v                    v                         v
   WORK.json        assets/templates/...          quarto render
```

優點：

- 內容只放在 `work/`。
- 模板只放在 `assets/templates/`。
- 標題、作者、日期可以由 `WORK.json` 集中管理。
- build output 檔名可以跟 branch 名稱一致，方便保存不同 work item。
- 同一套 `scripts/build.py` 可以支援 thesis、journal、homework、presentation 等類型。
