[CmdletBinding()]
param(
    [Parameter(Mandatory=$true)][string]$PackagePath
)

$ErrorActionPreference = 'Stop'

function Fail([string]$Message) {
    Write-Host "FAIL: $Message"
    exit 1
}

$package = (Resolve-Path -LiteralPath $PackagePath).Path
$work = Join-Path $env:TEMP ("REOC_VERIFY_" + [guid]::NewGuid().ToString('N'))
try {
    New-Item -ItemType Directory -Force -Path $work | Out-Null
    Expand-Archive -LiteralPath $package -DestinationPath $work -Force

    $manifestPath = Join-Path $work 'manifest.json'
    $payloadPath = Join-Path $work 'payload'
    if (-not (Test-Path -LiteralPath $manifestPath)) { Fail 'manifest.json is missing.' }
    if (-not (Test-Path -LiteralPath $payloadPath)) { Fail 'payload directory is missing.' }

    $manifest = Get-Content -LiteralPath $manifestPath -Raw | ConvertFrom-Json
    if (-not $manifest.version) { Fail 'Manifest version is missing.' }
    if (-not $manifest.files) { Fail 'Manifest file list is missing.' }

    foreach ($entry in $manifest.files) {
        $relative = [string]$entry.path
        if ([string]::IsNullOrWhiteSpace($relative) -or $relative.StartsWith('/') -or $relative -match '(^|/)\.\.(/|$)' -or $relative -match '^[A-Za-z]:') {
            Fail "Unsafe path in manifest: $relative"
        }
        $candidate = Join-Path $payloadPath ($relative -replace '/', [IO.Path]::DirectorySeparatorChar)
        if (-not (Test-Path -LiteralPath $candidate -PathType Leaf)) { Fail "Missing file: $relative" }
        $item = Get-Item -LiteralPath $candidate
        if ([int64]$item.Length -ne [int64]$entry.size) { Fail "Size mismatch: $relative" }
        $hash = (Get-FileHash -LiteralPath $candidate -Algorithm SHA256).Hash.ToUpperInvariant()
        if ($hash -ne ([string]$entry.sha256).ToUpperInvariant()) { Fail "SHA256 mismatch: $relative" }
    }

    $actualFiles = Get-ChildItem -LiteralPath $payloadPath -Recurse -File
    if ($actualFiles.Count -ne @($manifest.files).Count) { Fail 'Payload contains files not represented exactly by manifest.' }

    Write-Host "PASS"
    Write-Host "Version: $($manifest.version)"
    Write-Host "Files:   $($actualFiles.Count)"
    Write-Host "ZIP SHA256: $((Get-FileHash -LiteralPath $package -Algorithm SHA256).Hash.ToUpperInvariant())"
    exit 0
}
catch {
    Fail $_.Exception.Message
}
finally {
    if (Test-Path -LiteralPath $work) { Remove-Item -LiteralPath $work -Recurse -Force -ErrorAction SilentlyContinue }
}
