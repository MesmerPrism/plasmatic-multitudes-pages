# Plasmatic Multitudes Pages

Public-facing GitHub Pages site for essays and references on weakly bounded bodies, semi-corporeal avatars, and related XR and media-theory work.

Live site: [mesmerprism.github.io/plasmatic-multitudes-pages](https://mesmerprism.github.io/plasmatic-multitudes-pages/)

## What this repo does

- Publishes a readable web edition of the main overview text.
- Publishes compact companion essays for adjacent tracks.
- Maintains a references page with organized source links.
- Links outward to DOI, publisher, arXiv, and catalog pages instead of mirroring PDF files.

## Structure

- `index.html`: the published essay
- `archive.html`: redirect from the retired guide URL to the overview
- `project.html`: compact public project framing
- `pain.html`: public pain-treatment research framing
- `references.html`: shared references library
- `assets/site.css`: longform site styles
- `assets/calligraphy-reference-pack/`: museum-backed styling references, derivative crops, and palette notes for future visual work
- `.github/workflows/deploy-pages.yml`: GitHub Pages deployment workflow
- `scripts/build-calligraphy-reference-pack.ps1`: rebuilds the curated calligraphy reference pack from official museum image URLs

## Visual direction

The current theme uses a custom ink-on-paper system influenced by public-domain calligraphy reference collections from the [Cleveland Museum of Art](https://openaccess-api.clevelandart.org/), [The Met](https://metmuseum.github.io/), and the [Smithsonian / National Museum of Asian Art](https://www.si.edu/openaccess/devtools). The shipped visuals are custom SVG brush textures and CSS paper treatments rather than downloaded collection images.

## Local preview

From the repo root:

```powershell
python -m http.server 4173
```

Then open `http://127.0.0.1:4173/`.

## GitHub Pages

This repository deploys through the GitHub Actions Pages flow. Pushes to `main` trigger `.github/workflows/deploy-pages.yml`, which stages the static site and publishes it to the live URL above.
