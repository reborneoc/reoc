[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [string]$PayloadPath,

    [Parameter(Mandatory = $true)]
    [ValidatePattern('^[0-9]+\.[0-9]+\.[0-9]+$')]
    [string]$Version,

    [Parameter(Mandatory = $true)]
    [string]$OutputPath
)

Set-StrictMode -Version 2.0
$ErrorActionPreference = 'Stop'

function Fail {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Message
    )

    Write-Error $Message
    exit 1
}

# ---------------------------------------------------------------------------
# Validate input/output paths
# ---------------------------------------------------------------------------

if (-not (Test-Path -LiteralPath $PayloadPath -PathType Container)) {
    Fail "Payload directory does not exist: $PayloadPath"
}

try {
    $payload = (Resolve-Path -LiteralPath $PayloadPath).Path
}
catch {
    Fail "Unable to resolve payload directory: $PayloadPath"
}

try {
    New-Item -ItemType Directory -Force -Path $OutputPath | Out-Null
    $output = (Resolve-Path -LiteralPath $OutputPath).Path
}
catch {
    Fail "Unable to create or resolve output directory: $OutputPath"
}

# Do not allow build output inside the payload.
$payloadPrefix = $payload.TrimEnd('\', '/') + [IO.Path]::DirectorySeparatorChar

if (
    $output.Equals($payload, [StringComparison]::OrdinalIgnoreCase) -or
    $output.StartsWith($payloadPrefix, [StringComparison]::OrdinalIgnoreCase)
) {
    Fail "OutputPath must not be the payload directory or a directory inside the payload."
}

# ---------------------------------------------------------------------------
# Collect and validate payload
# ---------------------------------------------------------------------------

$forbiddenNames = @(
    'REOC_Updater.ps1',
    'BIFROST_Updater.ps1'
)

$files = @(
    Get-ChildItem -LiteralPath $payload -Recurse -File -Force |
    Sort-Object FullName
)

if ($files.Count -eq 0) {
    Fail "Payload is empty."
}

$manifestFiles = @()

foreach ($file in $files) {

    $relative = $file.FullName.Substring($payload.Length)

    $relative = $relative.TrimStart('\', '/')
    $relative = $relative -replace '\\', '/'

    if ([string]::IsNullOrWhiteSpace($relative)) {
        Fail "Invalid empty relative path: $($file.FullName)"
    }

    # Reject unsafe archive paths.
    if (
        $relative.StartsWith('/') -or
        $relative -match '(^|/)\.\.(/|$)' -or
        $relative -match '^[A-Za-z]:'
    ) {
        Fail "Unsafe path detected: $relative"
    }

    if ($forbiddenNames -contains $file.Name) {
        Fail "Updater must not be included in payload: $relative"
    }

    try {
        $hash = (
            Get-FileHash -LiteralPath $file.FullName -Algorithm SHA256
        ).Hash.ToUpperInvariant()
    }
    catch {
        Fail "Unable to calculate SHA256 for: $relative"
    }

    $manifestFiles += [ordered]@{
        path   = $relative
        sha256 = $hash
        size   = [int64]$file.Length
    }
}

# ---------------------------------------------------------------------------
# Build temporary package structure
# ---------------------------------------------------------------------------

$work = Join-Path $env:TEMP (
    "REOC_BUILD_" + [guid]::NewGuid().ToString('N')
)

try {

    $payloadOut = Join-Path $work 'payload'

    New-Item `
        -ItemType Directory `
        -Force `
        -Path $payloadOut |
        Out-Null

    # Copy every top-level payload item.
    # Using LiteralPath here prevents characters such as [ ] from being
    # interpreted as PowerShell wildcards.
    $topLevelItems = @(
        Get-ChildItem -LiteralPath $payload -Force
    )

    foreach ($item in $topLevelItems) {
        Copy-Item `
            -LiteralPath $item.FullName `
            -Destination $payloadOut `
            -Recurse `
            -Force
    }

    # -----------------------------------------------------------------------
    # Manifest
    # -----------------------------------------------------------------------

    $manifest = [ordered]@{
        version = $Version
        files   = $manifestFiles
    }

    $manifestPath = Join-Path $work 'manifest.json'

    $manifest |
        ConvertTo-Json -Depth 6 |
        Set-Content `
            -LiteralPath $manifestPath `
            -Encoding UTF8

    # -----------------------------------------------------------------------
    # Create cumulative update ZIP
    # -----------------------------------------------------------------------

    $zipName = "REOC_UPDATE_$Version.zip"
    $zipPath = Join-Path $output $zipName

    if (Test-Path -LiteralPath $zipPath) {
        Remove-Item -LiteralPath $zipPath -Force
    }

    Compress-Archive `
        -LiteralPath $manifestPath, $payloadOut `
        -DestinationPath $zipPath `
        -CompressionLevel Optimal

    if (-not (Test-Path -LiteralPath $zipPath -PathType Leaf)) {
        Fail "ZIP package was not created."
    }

    # -----------------------------------------------------------------------
    # Calculate final ZIP checksum
    # -----------------------------------------------------------------------

    $zipHash = (
        Get-FileHash -LiteralPath $zipPath -Algorithm SHA256
    ).Hash.ToUpperInvariant()

    $zipSize = (
        Get-Item -LiteralPath $zipPath
    ).Length

    # -----------------------------------------------------------------------
    # Generate latest.json candidate
    #
    # IMPORTANT:
    # This file is generated locally as latest.generated.json.
    # It must NOT become the active repository latest.json until the matching
    # GitHub Release and ZIP asset actually exist.
    # -----------------------------------------------------------------------

    $latest = [ordered]@{
        version   = $Version
        url       = "https://github.com/reborneoc/reoc/releases/download/v$Version/$zipName"
        sha256    = $zipHash
        size      = [int64]$zipSize
        mandatory = $false
        notes     = "REOC update $Version"
    }

    $latestPath = Join-Path $output 'latest.generated.json'

    $latest |
        ConvertTo-Json -Depth 4 |
        Set-Content `
            -LiteralPath $latestPath `
            -Encoding UTF8

    # -----------------------------------------------------------------------
    # Final result
    # -----------------------------------------------------------------------

    Write-Host ""
    Write-Host "============================================"
    Write-Host " REOC UPDATE BUILD"
    Write-Host "============================================"
    Write-Host "PASS"
    Write-Host ""
    Write-Host "Version : $Version"
    Write-Host "Files   : $($manifestFiles.Count)"
    Write-Host "Package : $zipPath"
    Write-Host "SHA256  : $zipHash"
    Write-Host "Size    : $zipSize bytes"
    Write-Host "Latest  : $latestPath"
    Write-Host ""
    Write-Host "IMPORTANT:"
    Write-Host "Do not publish latest.generated.json as latest.json"
    Write-Host "until the matching GitHub Release asset is online and verified."
    Write-Host "============================================"
}
catch {
    Fail $_.Exception.Message
}
finally {

    if (
        $work -and
        (Test-Path -LiteralPath $work)
    ) {
        Remove-Item `
            -LiteralPath $work `
            -Recurse `
            -Force `
            -ErrorAction SilentlyContinue
    }
}
