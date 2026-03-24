# Plasmatic Multitudes Pages

Public-facing GitHub Pages site for the `Plasmatic Multitudes` writing and research pages.

Live site: [mesmerprism.github.io/plasmatic-multitudes-pages](https://mesmerprism.github.io/plasmatic-multitudes-pages/)

## What this repo does

- Publishes a readable web edition of the main overview text.
- Publishes compact public framing pages for adjacent project tracks.
- Publishes an archive map so the private collection structure is legible without exposing local source files.
- Maintains a shared references library so essays can cite a central, organized bibliography.
- Keeps the public site separate from the private working archive and local source PDFs.
- Links outward to DOI, publisher, arXiv, and catalog pages instead of mirroring PDF files.

## Structure

- `index.html`: the published essay
- `project.html`: compact public project framing
- `pain.html`: public pain-treatment research framing
- `archive.html`: public collection map of the private research archive
- `references.html`: shared references library
- `assets/site.css`: longform site styles
- `.github/workflows/deploy-pages.yml`: GitHub Pages deployment workflow
- `scripts/sync-overview.ps1`: helper that copies the current private working draft into `tmp/` for local comparison

## Local preview

From the repo root:

```powershell
python -m http.server 4173
```

Then open `http://127.0.0.1:4173/`.

## GitHub Pages

This repository deploys through the GitHub Actions Pages flow. Pushes to `main` trigger `.github/workflows/deploy-pages.yml`, which stages the static site and publishes it to the live URL above.

## Updating from the working repo

The authoritative draft still lives in the private working repository. To copy that source draft into local scratch space for editorial comparison:

```powershell
.\scripts\sync-overview.ps1
```

That command copies the current overview markdown into `tmp/working-overview.md`. The public page in `index.html` remains curated by hand so citations, links, and public-facing wording stay clean.
