#!/usr/bin/env bash
# Estrae testo in italiano da immagini o PDF usando Tesseract OCR.
set -euo pipefail

if [ $# -lt 1 ]; then
  echo "Uso: $0 <file.jpg|file.png|file.pdf> [altri file...]" >&2
  exit 1
fi

if ! command -v tesseract >/dev/null 2>&1; then
  echo "Errore: tesseract non è installato. Esegui: sudo apt-get install -y tesseract-ocr tesseract-ocr-ita poppler-utils" >&2
  exit 1
fi

if ! tesseract --list-langs 2>&1 | grep -q '^ita$'; then
  echo "Errore: pacchetto lingua italiana mancante. Esegui: sudo apt-get install -y tesseract-ocr-ita" >&2
  exit 1
fi

for input in "$@"; do
  if [ ! -f "$input" ]; then
    echo "File non trovato: $input" >&2
    continue
  fi

  ext_lower=$(echo "${input##*.}" | tr '[:upper:]' '[:lower:]')

  echo "===== $input ====="

  if [ "$ext_lower" = "pdf" ]; then
    if ! command -v pdftoppm >/dev/null 2>&1; then
      echo "Errore: pdftoppm non è installato. Esegui: sudo apt-get install -y poppler-utils" >&2
      continue
    fi
    tmpdir=$(mktemp -d)
    pdftoppm -png -r 300 "$input" "$tmpdir/page"
    for page in "$tmpdir"/page-*.png; do
      [ -e "$page" ] || continue
      echo "--- pagina: $(basename "$page") ---"
      tesseract "$page" - -l ita --psm 3
    done
    rm -rf "$tmpdir"
  else
    tesseract "$input" - -l ita --psm 3
  fi
done
