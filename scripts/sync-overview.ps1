param(
    [string]$SourceRepo = "..\\Plasmatic Multitudes",
    [string]$SourceFile = "core-working-docs\\overview-article\\overview_semi-corporeal-avatar-aesthetics.md"
)

$repoRoot = Resolve-Path (Join-Path $PSScriptRoot "..")
$sourceRepoPath = Resolve-Path (Join-Path $repoRoot $SourceRepo)
$sourcePath = Join-Path $sourceRepoPath $SourceFile
$scratchDir = Join-Path $repoRoot "tmp"
$destinationPath = Join-Path $scratchDir "working-overview.md"

if (-not (Test-Path $sourcePath)) {
    throw "Could not find source overview at '$sourcePath'."
}

New-Item -ItemType Directory -Path $scratchDir -Force | Out-Null
Copy-Item -Path $sourcePath -Destination $destinationPath -Force

Write-Host "Copied working overview to $destinationPath"
Write-Host "Public article remains in index.html and should be updated manually for citation and wording changes."
