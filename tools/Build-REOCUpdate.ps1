[CmdletBinding()]
param(
    [Parameter(Mandatory=$true)][string]$PayloadPath,
    [Parameter(Mandatory=$true)][ValidatePattern('^[0-9]+\.[0-9]+\.[0-9]+$')][string]$Version,
    [Parameter(Mandatory=$true)][string]$OutputPath
)

$ErrorActionPreference = 'Stop'

function Fail([string]$Message) {
    Write-Error $Message
    exit 1
}

$payload = (Resolve-Path -Path $PayloadPath).Path
New-Item -ItemType Directory -Force -Path $OutputPath | Out-Null
$output = (Resolve-Path -Path $OutputPath).Path

$forbiddenNames = @('REOC_Updater.ps1','BIFROST_Updater.ps1')
$files = Get-ChildItem -Path $payload -Recurse -File
if (-not $files) { Fail 'Payload is empty.' }

$manifestFiles = @()
foreach ($file in $files) {
    $relative = $file.FullName.Substring($payload.Length).TrimStart('\\','/') -replace '\\','/'
    if ([string]::IsNullOrWhiteSpace($relative)) { Fail "Invalid empty relative path: $($file.FullName)" }
    if ($relative.StartsWith('/') -or $relative -match '(^|/)\.\.(/|$)' -or $relative -match '^[A-Za-z]:') {
        Fail "Unsafe path detected: $relative"
    }
    if ($forbiddenNames -contains $file.Name) { Fail "Updater must not be included in payload: $relative" }

    $hash = (Get-FileHash -Path $file.FullName -Algorithm SHA256).Hash.ToUpperInvariant()
    $manifestFiles += [ordered]@{ path = $relative; sha256 = $hash; size = [int64]$file.Length }
}

$work = Join-Path $env:TEMP ("REOC_BUILD_" + [guid]::NewGuid().ToString('N'))
try {
    $payloadOut = Join-Path $work 'payload'
    New-Item -ItemType Directory -Force -Path $payloadOut | Out-Null
    Copy-Item -Path (Join-Path $payload '*') -Destination $payloadOut -Recurse -Force

    $manifest = [ordered]@{ version = $Version; files = $manifestFiles }
    $manifestPath = Join-Path $work 'manifest.json'
    $manifest | ConvertTo-Json -Depth 6 | Set-Content -Path $manifestPath -Encoding UTF8

    $zipName = "REOC_UPDATE_$Version.zip"
    $zipPath = Join-Path $output $zipName
    if (Test-Path -Path $zipPath) { Remove-Item -Path $zipPath -Force }
    Compress-Archive -Path $manifestPath,$payloadOut -DestinationPath $zipPath -CompressionLevel Optimal

    $zipHash = (Get-FileHash -Path $zipPath -Algorithm SHA256).Hash.ToUpperInvariant()
    $zipSize = (Get-Item -Path $zipPath).Length
    $latest = [ordered]@{
        version = $Version
        url = "https://github.com/reborneoc/reoc/releases/download/v$Version/$zipName"
        sha256 = $zipHash
        size = [int64]$zipSize
        mandatory = $false
        notes = "REOC update $Version"
    }
    $latestPath = Join-Path $output 'latest.generated.json'
    $latest | ConvertTo-Json -Depth 4 | Set-Content -Path $latestPath -Encoding UTF8

    Write-Host "PASS"
    Write-Host "Package: $zipPath"
    Write-Host "SHA256:  $zipHash"
    Write-Host "Size:    $zipSize"
    Write-Host "Latest:  $latestPath"
}
finally {
    if (Test-Path -Path $work) { Remove-Item -Path $work -Recurse -Force -ErrorAction SilentlyContinue }
}
