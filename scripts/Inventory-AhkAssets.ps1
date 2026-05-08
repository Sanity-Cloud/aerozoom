<#
.SYNOPSIS
    Inventories AutoHotkey migration-relevant assets in the AeroZoom repository.

.DESCRIPTION
    Run this script from the repository root. It lists AutoHotkey source files,
    compiled executables, INI/config files, icons, and common packaging files so
    the v2 migration can distinguish source, generated artifacts, and external tools.

.OUTPUTS
    Writes a Markdown report to .\AHK_ASSET_INVENTORY.generated.md unless -NoWrite is used.
#>

[CmdletBinding()]
param(
    [switch]$NoWrite,
    [string]$OutputPath = ".\AHK_ASSET_INVENTORY.generated.md"
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

function Get-RepoRelativePath {
    param(
        [Parameter(Mandatory = $true)]
        [System.IO.FileInfo]$File
    )

    $root = (Get-Location).Path.TrimEnd('\')
    $full = $File.FullName
    if ($full.StartsWith($root, [System.StringComparison]::OrdinalIgnoreCase)) {
        return $full.Substring($root.Length).TrimStart('\')
    }

    return $full
}

function Get-AssetRows {
    param(
        [string[]]$Extensions
    )

    Get-ChildItem -Path . -Recurse -File |
        Where-Object {
            $_.FullName -notmatch '\\.git\\' -and
            $Extensions -contains $_.Extension.ToLowerInvariant()
        } |
        Sort-Object FullName |
        ForEach-Object {
            [pscustomobject]@{
                Path      = Get-RepoRelativePath -File $_
                Extension = $_.Extension.ToLowerInvariant()
                SizeKB    = [math]::Round($_.Length / 1KB, 2)
                Modified  = $_.LastWriteTime.ToString("yyyy-MM-dd HH:mm:ss")
            }
        }
}

$sourceExtensions = @(".ahk")
$binaryExtensions = @(".exe", ".dll")
$configExtensions = @(".ini", ".json", ".xml", ".yaml", ".yml", ".iss", ".nsi")
$assetExtensions  = @(".ico", ".png", ".bmp", ".gif", ".jpg", ".jpeg", ".txt", ".md")

$sections = [ordered]@{
    "AutoHotkey source files" = Get-AssetRows -Extensions $sourceExtensions
    "Executables and binaries" = Get-AssetRows -Extensions $binaryExtensions
    "Config and packaging candidates" = Get-AssetRows -Extensions $configExtensions
    "Icons, images, text, and docs" = Get-AssetRows -Extensions $assetExtensions
}

$lines = New-Object System.Collections.Generic.List[string]
$lines.Add("# AeroZoom AHK Asset Inventory")
$lines.Add("")
$lines.Add("Generated: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')")
$lines.Add("")
$lines.Add("This generated report supports the staged AutoHotkey v2 migration. Review before committing because generated timestamps create noisy diffs.")
$lines.Add("")

foreach ($sectionName in $sections.Keys) {
    $rows = @($sections[$sectionName])
    $lines.Add("## $sectionName")
    $lines.Add("")

    if ($rows.Count -eq 0) {
        $lines.Add("_None found._")
        $lines.Add("")
        continue
    }

    $lines.Add("| Path | Extension | Size KB | Modified |")
    $lines.Add("|---|---:|---:|---|")
    foreach ($row in $rows) {
        $safePath = $row.Path.Replace("|", "\|")
        $lines.Add("| `$safePath` | $($row.Extension) | $($row.SizeKB) | $($row.Modified) |")
    }
    $lines.Add("")
}

$report = $lines -join [Environment]::NewLine

if (-not $NoWrite) {
    Set-Content -Path $OutputPath -Value $report -Encoding UTF8
    Write-Host "Wrote $OutputPath"
} else {
    $report
}

Pause
