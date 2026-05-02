[CmdletBinding()]
param(
  [Parameter(Mandatory = $true)]
  [string]$InputPath,

  [Parameter(Mandatory = $false)]
  [string]$OutputPath
)

$ErrorActionPreference = "Stop"

$inputFile = Get-Item -LiteralPath $InputPath -ErrorAction Stop

if (-not $OutputPath) {
  $OutputPath = [System.IO.Path]::ChangeExtension($inputFile.FullName, ".svg")
}
elseif (-not [System.IO.Path]::IsPathRooted($OutputPath)) {
  $OutputPath = Join-Path (Get-Location) $OutputPath
}

$outputPathFull = [System.IO.Path]::GetFullPath($OutputPath)
$outputDir = Split-Path -Parent $outputPathFull
if ($outputDir) {
  New-Item -ItemType Directory -Force $outputDir | Out-Null
}

function Test-NativeExitCode {
  param([string]$CommandName)

  if ($LASTEXITCODE -ne 0) {
    throw "$CommandName failed with exit code $LASTEXITCODE"
  }
}

function Copy-RenderedSvg {
  param([string]$GeneratedPath)

  if (-not (Test-Path -LiteralPath $GeneratedPath)) {
    throw "PlantUML did not create the expected SVG: $GeneratedPath"
  }

  if ([System.IO.Path]::GetFullPath($GeneratedPath) -ne $outputPathFull) {
    Copy-Item -LiteralPath $GeneratedPath -Destination $outputPathFull -Force
  }
}

$plantuml = Get-Command plantuml -ErrorAction SilentlyContinue
$java = Get-Command java -ErrorAction SilentlyContinue
$defaultSvg = [System.IO.Path]::ChangeExtension($inputFile.FullName, ".svg")

if ($plantuml) {
  & $plantuml.Source -tsvg $inputFile.FullName
  Test-NativeExitCode "plantuml"
  Copy-RenderedSvg $defaultSvg
}
elseif ($env:PLANTUML_JAR -and (Test-Path $env:PLANTUML_JAR) -and $java) {
  & $java.Source -jar $env:PLANTUML_JAR -tsvg $inputFile.FullName
  Test-NativeExitCode "java -jar PLANTUML_JAR"
  Copy-RenderedSvg $defaultSvg
}
else {
  $request = @{
    Method = "Post"
    Uri = "https://kroki.io/plantuml/svg"
    ContentType = "text/plain"
    InFile = $inputFile.FullName
    OutFile = $outputPathFull
  }

  if ((Get-Command Invoke-WebRequest).Parameters.ContainsKey("UseBasicParsing")) {
    $request.UseBasicParsing = $true
  }

  Invoke-WebRequest @request
}

Write-Host "Wrote $outputPathFull"
