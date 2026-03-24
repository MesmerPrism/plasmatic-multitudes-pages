param()

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

Add-Type -AssemblyName System.Drawing

$repoRoot = Split-Path -Parent $PSScriptRoot
$packRoot = Join-Path $repoRoot "assets\calligraphy-reference-pack"
$originalRoot = Join-Path $packRoot "original"
$derivedRoot = Join-Path $packRoot "derived"

foreach ($dir in @($packRoot, $originalRoot, $derivedRoot)) {
  New-Item -ItemType Directory -Force -Path $dir | Out-Null
}

function Save-RemoteFile {
  param(
    [Parameter(Mandatory = $true)][string]$Uri,
    [Parameter(Mandatory = $true)][string]$Path
  )

  Invoke-WebRequest -Uri $Uri -OutFile $Path
}

function Convert-NormalizedRect {
  param(
    [Parameter(Mandatory = $true)][System.Drawing.Image]$Image,
    [Parameter(Mandatory = $true)][double]$X,
    [Parameter(Mandatory = $true)][double]$Y,
    [Parameter(Mandatory = $true)][double]$Width,
    [Parameter(Mandatory = $true)][double]$Height
  )

  $rect = [System.Drawing.Rectangle]::new(
    [int]([math]::Round($Image.Width * $X)),
    [int]([math]::Round($Image.Height * $Y)),
    [int]([math]::Round($Image.Width * $Width)),
    [int]([math]::Round($Image.Height * $Height))
  )

  if ($rect.Width -lt 1) { $rect.Width = 1 }
  if ($rect.Height -lt 1) { $rect.Height = 1 }
  if ($rect.Right -gt $Image.Width) { $rect.Width = $Image.Width - $rect.X }
  if ($rect.Bottom -gt $Image.Height) { $rect.Height = $Image.Height - $rect.Y }

  return $rect
}

function Save-Crop {
  param(
    [Parameter(Mandatory = $true)][string]$SourcePath,
    [Parameter(Mandatory = $true)][string]$OutputPath,
    [Parameter(Mandatory = $true)][double]$X,
    [Parameter(Mandatory = $true)][double]$Y,
    [Parameter(Mandatory = $true)][double]$Width,
    [Parameter(Mandatory = $true)][double]$Height
  )

  $image = [System.Drawing.Image]::FromFile($SourcePath)
  try {
    $rect = Convert-NormalizedRect -Image $image -X $X -Y $Y -Width $Width -Height $Height
    $bitmap = [System.Drawing.Bitmap]::new($rect.Width, $rect.Height)
    try {
      $graphics = [System.Drawing.Graphics]::FromImage($bitmap)
      try {
        $graphics.DrawImage(
          $image,
          [System.Drawing.Rectangle]::new(0, 0, $rect.Width, $rect.Height),
          $rect,
          [System.Drawing.GraphicsUnit]::Pixel
        )
      } finally {
        $graphics.Dispose()
      }

      $bitmap.Save($OutputPath, [System.Drawing.Imaging.ImageFormat]::Jpeg)
    } finally {
      $bitmap.Dispose()
    }
  } finally {
    $image.Dispose()
  }
}

function Get-AverageColorHex {
  param(
    [Parameter(Mandatory = $true)][string]$SourcePath,
    [Parameter(Mandatory = $true)][double]$X,
    [Parameter(Mandatory = $true)][double]$Y,
    [Parameter(Mandatory = $true)][double]$Width,
    [Parameter(Mandatory = $true)][double]$Height
  )

  $image = [System.Drawing.Bitmap]::FromFile($SourcePath)
  try {
    $rect = Convert-NormalizedRect -Image $image -X $X -Y $Y -Width $Width -Height $Height
    $stepX = [math]::Max(1, [int]($rect.Width / 24))
    $stepY = [math]::Max(1, [int]($rect.Height / 24))
    $sumR = 0
    $sumG = 0
    $sumB = 0
    $count = 0

    for ($px = $rect.X; $px -lt ($rect.X + $rect.Width); $px += $stepX) {
      for ($py = $rect.Y; $py -lt ($rect.Y + $rect.Height); $py += $stepY) {
        $color = $image.GetPixel($px, $py)
        $sumR += $color.R
        $sumG += $color.G
        $sumB += $color.B
        $count += 1
      }
    }

    if ($count -eq 0) {
      throw "Average color sample for $SourcePath resolved to zero pixels."
    }

    $avgR = [int]([math]::Round($sumR / $count))
    $avgG = [int]([math]::Round($sumG / $count))
    $avgB = [int]([math]::Round($sumB / $count))
    return "#{0:X2}{1:X2}{2:X2}" -f $avgR, $avgG, $avgB
  } finally {
    $image.Dispose()
  }
}

$items = @(
  [pscustomobject]@{
    slug = "cma-semi-cursive"
    institution = "Cleveland Museum of Art"
    title = "Calligraphy in Semi-Cursive Style (xing-caoshu)"
    creator = "Wang Duo"
    date = "c. 1660-1709"
    culture = "China, Qing dynasty (1644-1911)"
    medium = "Hanging scroll; ink on paper"
    rights = "CC0"
    rights_proof = "share_license_status = CC0"
    source_page = "https://clevelandart.org/art/2003.353"
    rights_url = "https://openaccess-api.clevelandart.org/"
    query_url = "https://openaccess-api.clevelandart.org/api/artworks/?q=calligraphy&cc0&has_image=1"
    image_url = "https://openaccess-cdn.clevelandart.org/2003.353/2003.353_web.jpg"
    filename = "cma-semi-cursive.jpg"
    visual_tags = @("bold brush mass", "seal red", "warm paper", "horizontal composition")
    integration_ideas = @("hero accent image", "brushstroke detail crop", "vermilion seal reference")
    note = "Strongest single-source example for dense black gesture plus stamp contrast."
  }
  [pscustomobject]@{
    slug = "cma-running-standard"
    institution = "Cleveland Museum of Art"
    title = "Poem on Imperial Gift of an Embroidered Silk"
    creator = "Wen Zhengming"
    date = "c. 1525"
    culture = "China, Suzhou, Ming dynasty (1368-1644)"
    medium = "Hanging scroll; ink on paper"
    rights = "CC0"
    rights_proof = "share_license_status = CC0"
    source_page = "https://clevelandart.org/art/1998.169"
    rights_url = "https://openaccess-api.clevelandart.org/"
    query_url = "https://openaccess-api.clevelandart.org/api/artworks/?q=calligraphy&cc0&has_image=1"
    image_url = "https://openaccess-cdn.clevelandart.org/1998.169/1998.169_web.jpg"
    filename = "cma-running-standard.jpg"
    visual_tags = @("vertical column", "quiet ink rhythm", "narrow scroll", "soft paper field")
    integration_ideas = @("side rail motif", "separator strip", "vertical nav accent")
    note = "Useful when we need a disciplined vertical reading order instead of a dramatic gesture."
  }
  [pscustomobject]@{
    slug = "cma-couplet"
    institution = "Cleveland Museum of Art"
    title = "Calligraphy Couplet"
    creator = "Unknown"
    date = "after 1911"
    culture = "China, Republican period (1912-49)"
    medium = "Pair of hanging scrolls; ink on paper"
    rights = "CC0"
    rights_proof = "share_license_status = CC0"
    source_page = "https://clevelandart.org/art/2023.162"
    rights_url = "https://openaccess-api.clevelandart.org/"
    query_url = "https://openaccess-api.clevelandart.org/api/artworks/?q=calligraphy&cc0&has_image=1"
    image_url = "https://openaccess-cdn.clevelandart.org/2023.162/2023.162_web.jpg"
    filename = "cma-couplet.jpg"
    visual_tags = @("paired scrolls", "strong negative space", "vertical framing", "vermilion stamps")
    integration_ideas = @("two-column section framing", "paired promo cards", "vertical margin study")
    note = "Best reference in the set for twin-column composition and the pacing between scroll bodies."
  }
  [pscustomobject]@{
    slug = "met-abiding-nowhere"
    institution = "The Met"
    title = '"Abiding nowhere, the awakened mind arises"'
    creator = "Muso Soseki"
    date = "early to mid-14th century"
    culture = "Japan"
    medium = "Hanging scroll; ink on paper"
    rights = "CC0 / Open Access"
    rights_proof = "isPublicDomain = true"
    source_page = "https://www.metmuseum.org/art/collection/search/816189"
    rights_url = "https://www.metmuseum.org/about-the-met/policies-and-documents/open-access"
    query_url = "https://collectionapi.metmuseum.org/public/collection/v1/search?hasImages=true&q=calligraphy"
    image_url = "https://images.metmuseum.org/CRDImages/as/web-large/DP-17101-002.jpg"
    filename = "met-abiding-nowhere.jpg"
    visual_tags = @("vertical drama", "dark field edges", "single statement", "brush taper")
    integration_ideas = @("hero side image", "section opener reference", "ink density benchmark")
    note = "Good check against over-lightening the interface; the ink should still read as deep and decisive."
  }
  [pscustomobject]@{
    slug = "met-letter-of-invitation"
    institution = "The Met"
    title = "Letter of Invitation"
    creator = "Hon'ami Koetsu"
    date = "after 1615"
    culture = "Japan"
    medium = "Hanging scroll; ink on paper"
    rights = "CC0 / Open Access"
    rights_proof = "isPublicDomain = true"
    source_page = "https://www.metmuseum.org/art/collection/search/913850"
    rights_url = "https://www.metmuseum.org/about-the-met/policies-and-documents/open-access"
    query_url = "https://collectionapi.metmuseum.org/public/collection/v1/search?hasImages=true&q=calligraphy"
    image_url = "https://images.metmuseum.org/CRDImages/as/web-large/DP-38242-002.jpg"
    filename = "met-letter-of-invitation.jpg"
    visual_tags = @("paper band", "decorative mount", "quiet script", "horizontal strip")
    integration_ideas = @("card background reference", "scroll band motif", "subtle panel ornament")
    note = "Useful for understated panel treatments where the mount and paper strip matter more than raw stroke aggression."
  }
  [pscustomobject]@{
    slug = "met-yan-zhenqing"
    institution = "The Met"
    title = "Calligraphy after three texts by Yan Zhenqing"
    creator = "Wang Shu"
    date = "dated 1729"
    culture = "China"
    medium = "Handscroll; ink on paper"
    rights = "CC0 / Open Access"
    rights_proof = "isPublicDomain = true"
    source_page = "https://www.metmuseum.org/art/collection/search/36145"
    rights_url = "https://www.metmuseum.org/about-the-met/policies-and-documents/open-access"
    query_url = "https://collectionapi.metmuseum.org/public/collection/v1/search?hasImages=true&q=calligraphy"
    image_url = "https://images.metmuseum.org/CRDImages/as/web-large/sf1986.22_CRD.jpg"
    filename = "met-yan-zhenqing.jpg"
    visual_tags = @("fine line", "seal red", "wide scroll", "ample paper margin")
    integration_ideas = @("thin divider study", "headline contrast reference", "wide banner reference")
    note = "Keeps us from making every brush cue too heavy; this one is precise, airy, and still legible."
  }
  [pscustomobject]@{
    slug = "nmaa-manuscript-letter"
    institution = "National Museum of Asian Art"
    title = "Manuscript letter"
    creator = "Unknown"
    date = "ca. 1627-37"
    culture = "Kyoto, Japan"
    medium = "Ink on paper, mounted as hanging scroll"
    rights = "CC0 / Smithsonian Open Access"
    rights_proof = "NMAA search filter media_usage = CC0 and object page exposes Download Image"
    source_page = "https://asia.si.edu/explore-art-culture/collections/search/edanmdm:fsg_F1907.149/"
    rights_url = "https://asia.si.edu/explore-art-culture/collections/search/?edan_fq%5B%5D=media_usage%3ACC0&edan_fq%5B%5D=object_type%3ACalligraphy+%28visual+works%29"
    query_url = "https://www.si.edu/openaccess/devtools"
    image_url = "https://ids.si.edu/ids/deliveryService?id=FS-8042_05&max=1600"
    filename = "nmaa-manuscript-letter.jpg"
    visual_tags = @("sage paper field", "mount textile", "quiet handwriting", "large empty area")
    integration_ideas = @("background wash reference", "card surface reference", "paper texture sample")
    note = "Best source for pale paper atmosphere and restrained field color without losing archival character."
  }
  [pscustomobject]@{
    slug = "nmaa-two-poems"
    institution = "National Museum of Asian Art"
    title = "Two poems and postscript in standard script"
    creator = "Unknown"
    date = "17th century"
    culture = "China"
    medium = "Ink on fan paper"
    rights = "CC0 / Smithsonian Open Access"
    rights_proof = "NMAA search filter media_usage = CC0 and object page exposes Download Image"
    source_page = "https://asia.si.edu/explore-art-culture/collections/search/edanmdm:fsg_F1909.398b/"
    rights_url = "https://asia.si.edu/explore-art-culture/collections/search/?edan_fq%5B%5D=media_usage%3ACC0&edan_fq%5B%5D=object_type%3ACalligraphy+%28visual+works%29"
    query_url = "https://www.si.edu/openaccess/devtools"
    image_url = "https://ids.si.edu/ids/deliveryService?id=FS-7410_20&max=1600"
    filename = "nmaa-two-poems.jpg"
    visual_tags = @("fan arc", "bronze paper", "seal red", "dense but airy writing")
    integration_ideas = @("arched ornament reference", "warm metallic paper reference", "accent stamp detail")
    note = "Useful when we need curvature, warmer substrate color, and a more ceremonial accent structure."
  }
)

$derivatives = @(
  [pscustomobject]@{ slug = "hero-gesture-cma-semi-cursive"; source = "cma-semi-cursive"; filename = "hero-gesture-cma-semi-cursive.jpg"; description = "Large black gesture with adjacent seal."; purpose = "Hero accent image or low-opacity header ornament."; x = 0.68; y = 0.04; width = 0.27; height = 0.70 }
  [pscustomobject]@{ slug = "seal-column-cma-semi-cursive"; source = "cma-semi-cursive"; filename = "seal-column-cma-semi-cursive.jpg"; description = "Seal cluster and left margin detail."; purpose = "Vermilion accent reference and stamp study."; x = 0.00; y = 0.11; width = 0.17; height = 0.67 }
  [pscustomobject]@{ slug = "vertical-run-cma-running-standard"; source = "cma-running-standard"; filename = "vertical-run-cma-running-standard.jpg"; description = "Tight vertical text rhythm."; purpose = "Side rail or vertical separator study."; x = 0.02; y = 0.02; width = 0.78; height = 0.93 }
  [pscustomobject]@{ slug = "letter-band-met-letter-of-invitation"; source = "met-letter-of-invitation"; filename = "letter-band-met-letter-of-invitation.jpg"; description = "Mounted paper strip with handwritten line."; purpose = "Panel interior treatment or banner strip."; x = 0.12; y = 0.15; width = 0.76; height = 0.43 }
  [pscustomobject]@{ slug = "paper-field-nmaa-manuscript-letter"; source = "nmaa-manuscript-letter"; filename = "paper-field-nmaa-manuscript-letter.jpg"; description = "Large pale paper field from the manuscript mount."; purpose = "Background texture reference for calm sections."; x = 0.10; y = 0.05; width = 0.80; height = 0.28 }
  [pscustomobject]@{ slug = "fan-arc-nmaa-two-poems"; source = "nmaa-two-poems"; filename = "fan-arc-nmaa-two-poems.jpg"; description = "Full fan arc with text flow preserved."; purpose = "Decorative arc motif or section-end flourish."; x = 0.07; y = 0.08; width = 0.86; height = 0.80 }
  [pscustomobject]@{ slug = "seal-detail-nmaa-two-poems"; source = "nmaa-two-poems"; filename = "seal-detail-nmaa-two-poems.jpg"; description = "Lower-left vermilion seal detail."; purpose = "Accent color sample and micro-ornament."; x = 0.07; y = 0.77; width = 0.15; height = 0.17 }
)

$paletteSamples = @(
  [pscustomobject]@{ key = "paperWarm"; label = "Warm paper"; source = "met-letter-of-invitation"; note = "Curated base paper tone from the Koetsu scroll and CMA paper fields."; hex = "#D8C4A0" }
  [pscustomobject]@{ key = "paperSage"; label = "Sage mount"; source = "nmaa-manuscript-letter"; note = "Quiet alternative field color for secondary surfaces."; hex = "#B8C1A6" }
  [pscustomobject]@{ key = "inkDeep"; label = "Dense ink"; source = "cma-semi-cursive"; note = "Primary headline and divider ink."; hex = "#241C16" }
  [pscustomobject]@{ key = "inkSoft"; label = "Soft ink"; source = "met-letter-of-invitation"; note = "Secondary text and less aggressive brush marks."; hex = "#5E4B37" }
  [pscustomobject]@{ key = "sealRed"; label = "Seal red"; source = "nmaa-two-poems"; note = "Accent only; use sparingly."; hex = "#92453B" }
  [pscustomobject]@{ key = "mountBrown"; label = "Mount brown"; source = "nmaa-two-poems"; note = "Muted border and divider support tone."; hex = "#8C7656" }
)

$itemBySlug = @{}
foreach ($item in $items) {
  $destination = Join-Path $originalRoot $item.filename
  Save-RemoteFile -Uri $item.image_url -Path $destination
  $itemBySlug[$item.slug] = $item
}

$derivedOutput = @()
foreach ($derivative in $derivatives) {
  $sourceItem = $itemBySlug[$derivative.source]
  $sourcePath = Join-Path $originalRoot $sourceItem.filename
  $derivedPath = Join-Path $derivedRoot $derivative.filename
  Save-Crop -SourcePath $sourcePath -OutputPath $derivedPath -X $derivative.x -Y $derivative.y -Width $derivative.width -Height $derivative.height

  $derivedOutput += [pscustomobject]@{
    slug = $derivative.slug
    source = $derivative.source
    file = ("derived/{0}" -f $derivative.filename)
    description = $derivative.description
    purpose = $derivative.purpose
  }
}

$paletteOutput = @()
foreach ($sample in $paletteSamples) {
  $paletteOutput += [pscustomobject]@{
    key = $sample.key
    label = $sample.label
    hex = $sample.hex
    source = $sample.source
    note = $sample.note
  }
}

$manifest = [pscustomobject]@{
  generated_at = (Get-Date).ToUniversalTime().ToString("yyyy-MM-ddTHH:mm:ssZ")
  pack = "calligraphy-reference-pack"
  purpose = "Museum-backed calligraphy references and derivative elements for future Plasmatic Multitudes styling passes."
  sources = $items | ForEach-Object {
    [pscustomobject]@{
      slug = $_.slug
      institution = $_.institution
      title = $_.title
      creator = $_.creator
      date = $_.date
      culture = $_.culture
      medium = $_.medium
      rights = $_.rights
      rights_proof = $_.rights_proof
      source_page = $_.source_page
      rights_url = $_.rights_url
      query_url = $_.query_url
      image_url = $_.image_url
      local_file = ("original/{0}" -f $_.filename)
      visual_tags = $_.visual_tags
      integration_ideas = $_.integration_ideas
      note = $_.note
    }
  }
  derived = $derivedOutput
  palette = $paletteOutput
}

$manifest | ConvertTo-Json -Depth 6 | Set-Content -Path (Join-Path $packRoot "manifest.json")
$paletteOutput | ConvertTo-Json -Depth 4 | Set-Content -Path (Join-Path $packRoot "palette.json")

Write-Host ("Built calligraphy reference pack in {0}" -f $packRoot)
