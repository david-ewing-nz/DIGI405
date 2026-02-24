# =================================================================================================
# extract-course-files.ps1
# -------------------------------------------------------------------------------------------------
# Purpose:
#   Extract "course files" from a Learn/Blackboard ZIP by flattening every folder named `content`
#   into a single destination folder. Handles duplicate filenames by appending -1, -2, etc.
#
# Arguments (ASCII or Unicode dashes accepted):
#   --help                     Show usage/help and exit
#   --dryrun / –dryrun / —dryrun
#                              Preview: list what would be copied (no writes)
#   --run   / –run   / —run    Perform extraction and copy (CLEARS destination first)
#   --zip <filename.zip>       Optional override ZIP (else newest .zip in script folder is used)
#
# Rules you requested:
#   • Any of: --run / –run / —run  ⇒ RUN
#   • Any of: --dryrun / –dryrun / —dryrun  ⇒ DRYRUN
#   • If both “run” and “dryrun” are present (ASCII or Unicode) ⇒ DRYRUN
#   • Unknown/bad flags ⇒ DRYRUN (print a short info line)
#   • No args ⇒ show help
#
# Destination:
#   - Writes to ./course_files (relative to this script)
#   - On RUN, destination is CLEARED first for a clean, reproducible result
#   - Duplicate filenames become name.ext, name-1.ext, name-2.ext, ...
#
# ZIP selection:
#   - If --zip is provided, that file is used (must exist)
#   - Else, the NEWEST *.zip file in the script folder is used (and printed)
#
# -------------------------------------------------------------------------------------------------
# 📂 (Same folder as the script)
# ├── <some-course-archive>.zip                  # Learn/Blackboard export (newest used by default)
# │     └── <random-root-folder>                 # top-level unzip folder
# │            ├── <random-module-A>
# │            │     └── content                 # Target folders: files DIRECTLY inside are copied
# │            │         ├── fileA-1.pdf
# │            │         └── fileA-2.docx
# │            ├── <random-module-B>
# │            │     └── content
# │            │         └── fileB-1.pdf
# │            └─(other similar module folders)
# │
# ├── course_files/                              # OUTPUT (flattened files, cleared on RUN)
# └── extract-course-files.ps1
# =================================================================================================

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

function Show-Usage {
    Write-Host ""
    Write-Host "Usage:"
    Write-Host "  .\extract-course-files.ps1 --dryrun [--zip <file.zip>]"
    Write-Host "  .\extract-course-files.ps1 --run    [--zip <file.zip>]"
    Write-Host "  .\extract-course-files.ps1 --help"
    Write-Host ""
    Write-Host "Notes:"
    Write-Host "  • --run / –run / —run  ⇒ RUN (clears ./course_files first)"
    Write-Host "  • --dryrun / –dryrun / —dryrun  ⇒ DRYRUN (no writes)"
    Write-Host "  • If both run & dryrun appear ⇒ DRYRUN"
    Write-Host "  • Unknown/bad flags ⇒ DRYRUN (short notice printed)"
    Write-Host "  • --zip <file> overrides; otherwise newest .zip in script folder is used"
    Write-Host ""
}

# ---------- Paths ----------
$ScriptRoot      = if ($PSScriptRoot) { $PSScriptRoot } else { Split-Path -Parent $MyInvocation.MyCommand.Path }
$ExtractRoot     = Join-Path $ScriptRoot "_unzipped"
$DestinationRoot = Join-Path $ScriptRoot "course_files"

# ---------- Helpers ----------
function Normalize-Dashes([string]$s) {
    if ($null -eq $s) { return $null }
    # Convert any leading sequence of ASCII hyphen, en-dash (U+2013), or em-dash (U+2014) into two ASCII hyphens
    # so –run / —run / --run all normalize to --run; same for dryrun.
    $s = $s -replace '^[\-–—]+', '--'
    return $s
}

function Parse-Args {
    param([string[]]$argv)

    $modeRun = $false
    $modeDry = $false
    $zipArg  = $null
    $unknown = @()

    for ($i = 0; $i -lt $argv.Count; $i++) {
        $raw = $argv[$i]
        $arg = Normalize-Dashes $raw

        switch -Regex ($arg) {
            '^--help$'    { return @{ Help=$true; Run=$false; Dry=$false; Zip=$null; Unknown=@() } }
            '^--run$'     { $modeRun = $true; continue }
            '^--dryrun$'  { $modeDry = $true; continue }
            '^--zip$'     {
                if ($i -lt ($argv.Count - 1)) {
                    $zipArg = $argv[$i+1]; $i++
                    continue
                } else {
                    # Missing filename after --zip → treat as unknown/bad
                    $unknown += $raw
                    continue
                }
            }
            default       { $unknown += $raw; continue }
        }
    }

    # Decide final mode per your rule:
    # • both run & dry → DRYRUN
    # • run only → RUN
    # • dry only → DRYRUN
    # • unknown flags present with no run/dry → DRYRUN (print short info)
    # • no flags → no mode → caller will show help
    $finalRun = $false
    $finalDry = $false

    if ($modeRun -and $modeDry) {
        $finalDry = $true
    } elseif ($modeRun) {
        $finalRun = $true
    } elseif ($modeDry) {
        $finalDry = $true
    } elseif ($unknown.Count -gt 0) {
        $finalDry = $true
    }

    return @{ Help=$false; Run=$finalRun; Dry=$finalDry; Zip=$zipArg; Unknown=$unknown }
}

function Get-NewestZipInFolder([string]$folder) {
    $zips = Get-ChildItem -Path $folder -Filter "*.zip" -File | Sort-Object LastWriteTime -Descending
    if (-not $zips -or $zips.Count -eq 0) { return $null }
    return $zips[0].FullName
}

function Resolve-ZipPath([string]$zipArg, [string]$folder) {
    if ($zipArg) {
        $p = if ([System.IO.Path]::IsPathRooted($zipArg)) { $zipArg } else { Join-Path $folder $zipArg }
        if (-not (Test-Path -LiteralPath $p -PathType Leaf)) {
            throw "Specified ZIP not found: $p"
        }
        return $p
    }
    else {
        $newest = Get-NewestZipInFolder $folder
        if (-not $newest) { throw "No ZIP files found in: $folder" }
        Write-Host "[Info] Using newest ZIP in folder: $(Split-Path $newest -Leaf)"
        return $newest
    }
}

function Get-CourseContentEntriesFromZip([string]$zipPath) {
    # Return ZIP entries that are files directly under any 'content' folder:  /content/<file>
    Add-Type -AssemblyName System.IO.Compression.FileSystem
    $zip = [System.IO.Compression.ZipFile]::OpenRead($zipPath)
    try {
        $entries = $zip.Entries | Where-Object {
            $full = $_.FullName -replace '\\','/'
            ($full -match '/content/[^/]+$') -and ($_.Length -gt 0)
        }
        return ,($entries)
    } finally {
        $zip.Dispose()
    }
}

function Clear-Destination([string]$dest) {
    if (Test-Path -LiteralPath $dest) {
        Remove-Item -LiteralPath $dest -Recurse -Force
    }
    New-Item -Path $dest -ItemType Directory -Force | Out-Null
}

function Ensure-ExtractRoot([string]$path) {
    if (-not (Test-Path -LiteralPath $path)) {
        New-Item -Path $path -ItemType Directory -Force | Out-Null
    }
}

function Get-TopLevelExtractedFolder([string]$root) {
    $top = Get-ChildItem -Path $root -Directory | Select-Object -First 1
    if (-not $top) { throw "Could not find a top-level folder inside extracted zip." }
    return $top.FullName
}

function Get-NextDuplicateName([string]$destinationRoot,[string]$baseName,[string]$extension) {
    $existing = Get-ChildItem -LiteralPath $destinationRoot -File -ErrorAction SilentlyContinue |
        Where-Object { $_.BaseName -match ("^" + [regex]::Escape($baseName) + "(?:-(\d+))?$") }

    if (-not $existing -or $existing.Count -eq 0) {
        return (Join-Path $destinationRoot ($baseName + $extension))
    }

    $max = 0
    foreach ($f in $existing) {
        if ($f.BaseName -match "-(\d+)$") {
            $n = [int]$Matches[1]
            if ($n -gt $max) { $max = $n }
        }
    }
    $next = $max + 1
    $newName = "{0}-{1}{2}" -f $baseName, $next, $extension
    return (Join-Path $destinationRoot $newName)
}

# ---------- ENTRY ----------
$parsed = Parse-Args $args

if ($parsed.Help -or (-not $parsed.Run -and -not $parsed.Dry -and $parsed.Unknown.Count -eq 0 -and $args.Count -eq 0)) {
    Show-Usage
    exit 0
}

# Unknown flags with no explicit mode → DRYRUN (print a short info line)
if (-not $parsed.Run -and -not $parsed.Dry -and $parsed.Unknown.Count -gt 0) {
    Write-Host "[Info] Running in DRYRUN mode (argument interpretation)."
    $parsed.Dry = $true
}

# Resolve ZIP (needed by both dryrun and run)
try {
    $zipPath = Resolve-ZipPath -zipArg $parsed.Zip -folder $ScriptRoot
} catch {
    Write-Error $_.Exception.Message
    exit 1
}

if ($parsed.Dry) {
    Write-Host "`n[Dry Run] Listing files directly inside 'content' folders in ZIP:`n"
    try {
        $entries = Get-CourseContentEntriesFromZip -zipPath $zipPath
        if (-not $entries -or $entries.Count -eq 0) {
            Write-Host "  (none found)"
        } else {
            foreach ($e in $entries) {
                Write-Host ("  {0}" -f ($e.FullName -replace '\\','/'))
            }
        }
        Write-Host "`n[Dry Run] No extraction or copying performed."
        exit 0
    } catch {
        Write-Error "Failed to read ZIP: $($_.Exception.Message)"
        exit 1
    }
}

if ($parsed.Run) {
    # Prepare destination (CLEAR)
    try {
        Clear-Destination -dest $DestinationRoot
    } catch {
        Write-Error "Failed to prepare destination: $($_.Exception.Message)"
        exit 1
    }

    # Ensure extract root exists, then expand archive
    Ensure-ExtractRoot -path $ExtractRoot
    try {
        Write-Host "[Info] Expanding archive..."
        Expand-Archive -Path $zipPath -DestinationPath $ExtractRoot -Force -ErrorAction Stop
    } catch {
        Write-Error "Failed to expand ZIP: $($_.Exception.Message)"
        exit 1
    }

    # Find the top-level folder created by the ZIP
    try {
        $TopFolder = Get-TopLevelExtractedFolder -root $ExtractRoot
    } catch {
        Write-Error $_.Exception.Message
        exit 1
    }

    # Traverse for 'content' directories and copy immediate files
    $total = 0
    $contentDirs = Get-ChildItem -Path $TopFolder -Recurse -Directory | Where-Object { $_.Name -eq "content" }
    foreach ($dir in $contentDirs) {
        $files = Get-ChildItem -LiteralPath $dir.FullName -File -ErrorAction SilentlyContinue
        foreach ($file in $files) {
            $base = $file.BaseName
            $ext  = $file.Extension

            $targetPath = Join-Path $DestinationRoot ($base + $ext)
            if (Test-Path -LiteralPath $targetPath) {
                $targetPath = Get-NextDuplicateName -destinationRoot $DestinationRoot -baseName $base -extension $ext
            }

            Copy-Item -LiteralPath $file.FullName -Destination $targetPath -Force
            $total++
        }
    }

    Write-Host "`n[Done] Copied $total file(s) into '$DestinationRoot'."
    exit 0
}

# If we get here, something unexpected occurred → default to DRYRUN fallback
Write-Host "[Info] Running in DRYRUN mode (argument interpretation)."
$parsed.Dry = $true
# Re-run dryrun branch
& $MyInvocation.MyCommand.Path --dryrun @($parsed.Zip ? @('--zip', $parsed.Zip) : @())
