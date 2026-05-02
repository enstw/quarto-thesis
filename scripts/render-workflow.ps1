[CmdletBinding()]
param(
  [switch]$SkipDiagrams,
  [switch]$SkipPdf
)

$ErrorActionPreference = "Stop"

$RepoRoot = Split-Path -Parent $PSScriptRoot
Set-Location $RepoRoot

function Invoke-NativeCommand {
  param(
    [Parameter(Mandatory = $true)]
    [string]$FilePath,

    [Parameter(Mandatory = $true)]
    [string[]]$Arguments
  )

  Write-Host "> $FilePath $($Arguments -join ' ')"
  & $FilePath @Arguments

  if ($LASTEXITCODE -ne 0) {
    throw "$FilePath failed with exit code $LASTEXITCODE"
  }
}

$quarto = Get-Command quarto -ErrorAction SilentlyContinue
if (-not $quarto) {
  throw "Quarto was not found on PATH. Install Quarto, open a new PowerShell window, and run this script again."
}

Invoke-NativeCommand $quarto.Source @("check")

if (-not $SkipDiagrams) {
  & "$PSScriptRoot\plantuml-to-svg.ps1" `
    "$RepoRoot\diagrams\quarto-flow.puml" `
    "$RepoRoot\diagrams\quarto-flow.svg"
}

Invoke-NativeCommand $quarto.Source @("render", "presentation.qmd", "--to", "revealjs")
Invoke-NativeCommand $quarto.Source @("render", "examples/dual-output.qmd", "--to", "revealjs")

if (-not $SkipPdf) {
  Invoke-NativeCommand $quarto.Source @("render", "presentation.qmd", "--to", "beamer")
  Invoke-NativeCommand $quarto.Source @("render", "examples/dual-output.qmd", "--to", "pdf")
}

Invoke-NativeCommand $quarto.Source @("render", "slides/slide-styles.qmd")

Write-Host ""
Write-Host "Workflow complete. Outputs are in $RepoRoot\_output."
