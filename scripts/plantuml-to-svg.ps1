param(
  [Parameter(Mandatory = $true)]
  [string]$InputPath,

  [Parameter(Mandatory = $false)]
  [string]$OutputPath
)

$ErrorActionPreference = "Stop"

if (-not (Test-Path $InputPath)) {
  throw "Input not found: $InputPath"
}

if (-not $OutputPath) {
  $OutputPath = [System.IO.Path]::ChangeExtension($InputPath, ".svg")
}

$outputDir = Split-Path -Parent $OutputPath
if ($outputDir) {
  New-Item -ItemType Directory -Force $outputDir | Out-Null
}

$plantuml = Get-Command plantuml -ErrorAction SilentlyContinue
$java = Get-Command java -ErrorAction SilentlyContinue

if ($plantuml) {
  Get-Content -Raw $InputPath | & $plantuml.Source -tsvg -pipe | Set-Content -NoNewline $OutputPath
}
elseif ($env:PLANTUML_JAR -and (Test-Path $env:PLANTUML_JAR) -and $java) {
  Get-Content -Raw $InputPath | & $java.Source -jar $env:PLANTUML_JAR -tsvg -pipe | Set-Content -NoNewline $OutputPath
}
else {
  Invoke-WebRequest `
    -Method Post `
    -Uri "https://kroki.io/plantuml/svg" `
    -ContentType "text/plain" `
    -InFile $InputPath `
    -OutFile $OutputPath
}

Write-Host "Wrote $OutputPath"
