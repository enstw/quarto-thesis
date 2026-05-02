#!/usr/bin/env bash
set -euo pipefail

if [[ $# -lt 1 || $# -gt 2 ]]; then
  echo "Usage: $0 INPUT.puml [OUTPUT.svg]" >&2
  exit 2
fi

input="$1"
output="${2:-${input%.*}.svg}"

if [[ ! -f "$input" ]]; then
  echo "Input not found: $input" >&2
  exit 1
fi

mkdir -p "$(dirname "$output")"

if command -v plantuml >/dev/null 2>&1; then
  plantuml -tsvg -pipe < "$input" > "$output"
elif [[ -n "${PLANTUML_JAR:-}" && -f "${PLANTUML_JAR}" ]] && command -v java >/dev/null 2>&1; then
  java -jar "$PLANTUML_JAR" -tsvg -pipe < "$input" > "$output"
elif command -v curl >/dev/null 2>&1; then
  curl -fsS \
    -H "Content-Type: text/plain" \
    --data-binary @"$input" \
    "https://kroki.io/plantuml/svg" \
    -o "$output"
else
  echo "No PlantUML renderer found. Install plantuml, set PLANTUML_JAR, or install curl for Kroki fallback." >&2
  exit 1
fi

echo "Wrote $output"
