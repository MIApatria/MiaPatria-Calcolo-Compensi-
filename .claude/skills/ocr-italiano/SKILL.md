---
name: ocr-italiano
description: Estrae testo da immagini o PDF scansionati in lingua italiana usando Tesseract OCR. Usa questa skill quando l'utente chiede di leggere, trascrivere o estrarre testo da una foto, scansione, screenshot o PDF in italiano (es. "leggi questo documento", "trascrivi questa immagine", "estrai il testo da questo PDF").
---

# OCR Italiano (Tesseract)

Esegue il riconoscimento ottico dei caratteri (OCR) su immagini o PDF in lingua italiana usando Tesseract OCR.

## Setup (prima esecuzione)

Verifica se Tesseract e il pacchetto lingua italiana sono installati:

```bash
tesseract --list-langs 2>&1 | grep -q '^ita$' && echo OK || echo MISSING
```

Se il risultato è `MISSING` (o `tesseract` non esiste), installa i pacchetti necessari:

```bash
sudo apt-get update && sudo apt-get install -y tesseract-ocr tesseract-ocr-ita poppler-utils
```

- `tesseract-ocr-ita`: dati di addestramento per la lingua italiana
- `poppler-utils`: fornisce `pdftoppm`, necessario per convertire i PDF in immagini prima dell'OCR

## Utilizzo

Esegui lo script incluso passando uno o più percorsi di file (immagine o PDF):

```bash
.claude/skills/ocr-italiano/scripts/ocr.sh /percorso/al/file.jpg
.claude/skills/ocr-italiano/scripts/ocr.sh /percorso/al/documento.pdf
```

Comportamento dello script:
1. Se l'input è un PDF, lo converte in immagini PNG (una per pagina, 300dpi) con `pdftoppm`.
2. Esegue `tesseract -l ita` su ciascuna immagine/pagina.
3. Stampa il testo estratto su stdout, con un'intestazione per ogni file/pagina elaborata.

## Note

- Per foto di documenti (non scansioni), assicurati che l'immagine sia ben illuminata, a fuoco e non inclinata: migliora sensibilmente la qualità del testo estratto.
- Se il risultato è scadente, prova a preprocessare l'immagine (scala di grigi, aumento del contrasto, raddrizzamento) prima di rilanciare l'OCR.
- Per riconoscere italiano e inglese insieme, richiama tesseract manualmente con `-l ita+eng`.
