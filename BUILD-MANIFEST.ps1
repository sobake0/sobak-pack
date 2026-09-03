param(
    [string]$PackVersion = "1.0.3"
)

$ErrorActionPreference = "Stop"

$Root = Split-Path -Parent $MyInvocation.MyCommand.Path
$FilesRoot = Join-Path $Root "files"
$ManifestPath = Join-Path $Root "manifest.json"

$BaseUrl = "https://raw.githubusercontent.com/sobake0/sobak-pack/main/files/"

if (!(Test-Path $FilesRoot)) {
    New-Item -ItemType Directory -Path $FilesRoot | Out-Null
}

$manifestFiles = @()

Get-ChildItem -Path $FilesRoot -File -Recurse | ForEach-Object {

    $fullPath = $_.FullName

    $relativePath =
        $fullPath.Substring($FilesRoot.Length + 1).Replace("\", "/")

    $hash =
        (Get-FileHash $fullPath -Algorithm SHA256).Hash

    $encodedPath =
        ($relativePath -split "/") |
        ForEach-Object {
            [System.Uri]::EscapeDataString($_)
        }

    $urlPath =
        $encodedPath -join "/"

    $url =
        "$BaseUrl$urlPath?v=$PackVersion"

    $manifestFiles += [PSCustomObject]@{
        path   = $relativePath
        url    = $url
        sha256 = $hash
    }

    Write-Host "추가: $relativePath"
}

$manifest = [ordered]@{
    packVersion = $PackVersion
    baseUrl      = $BaseUrl
    files        = $manifestFiles
    delete       = @()
}

$json =
    $manifest |
    ConvertTo-Json -Depth 10

[System.IO.File]::WriteAllText(
    $ManifestPath,
    $json,
    [System.Text.UTF8Encoding]::new($false)
)

Write-Host ""
Write-Host "=============================="
Write-Host "manifest.json 생성 완료"
Write-Host "버전: $PackVersion"
Write-Host "파일 수: $($manifestFiles.Count)"
Write-Host "경로: $ManifestPath"
Write-Host "=============================="
