param(
    [string]$Destination = (Join-Path $PSScriptRoot "..\reference\OfflineDAoC")
)

$ErrorActionPreference = "Stop"
$Repo = "https://github.com/shadowofze/OfflineDAoC.git"
$Commit = "38aef23dadfe2f1659fec2a382ffde427879f475"
$Manifest = Join-Path $PSScriptRoot "..\manifests\offlinedaoc-reference.txt"
$Cache = Join-Path $PSScriptRoot "..\.cache\OfflineDAoC"

if (-not (Get-Command git -ErrorAction SilentlyContinue)) { throw "git.exe is required." }
if (-not (Test-Path $Manifest)) { throw "Manifest not found: $Manifest" }

if (Test-Path $Cache) { Remove-Item $Cache -Recurse -Force }
New-Item -ItemType Directory -Force -Path $Cache | Out-Null

Push-Location $Cache
try {
    git init -q
    git remote add origin $Repo
    git fetch -q --depth 1 origin $Commit
    git checkout -q --detach FETCH_HEAD
    $actual = (git rev-parse HEAD).Trim()
    if ($actual -ne $Commit) { throw "Pinned commit mismatch: $actual" }
}
finally { Pop-Location }

if (Test-Path $Destination) { Remove-Item $Destination -Recurse -Force }
New-Item -ItemType Directory -Force -Path $Destination | Out-Null

$entries = Get-Content $Manifest | ForEach-Object { $_.Trim() } | Where-Object { $_ -and -not $_.StartsWith("#") }
foreach ($relative in $entries) {
    $source = Join-Path $Cache ($relative -replace '/', '\')
    if (-not (Test-Path $source)) { throw "Pinned source missing: $relative" }
    $target = Join-Path $Destination ($relative -replace '/', '\')
    New-Item -ItemType Directory -Force -Path (Split-Path $target -Parent) | Out-Null
    Copy-Item -LiteralPath $source -Destination $target -Force
}

@(
    "Repository=$Repo",
    "Commit=$Commit",
    "CreatedUtc=$([DateTime]::UtcNow.ToString('O'))",
    "Files=$($entries.Count)"
) | Set-Content -Encoding UTF8 (Join-Path $Destination "REOC_REFERENCE_SNAPSHOT.txt")

Write-Host "OfflineDAoC reference snapshot ready:" -ForegroundColor Green
Write-Host $Destination
Write-Host "Pinned commit: $Commit"
Write-Host "Files copied: $($entries.Count)"
Write-Host "The imported reference folder is ignored by this branch."
