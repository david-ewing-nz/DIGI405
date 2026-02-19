# Knit to PDF specifically
# Usage: .\scripts\knit_pdf.ps1 -FilePath "D:\github\VI1\R\VI-UNIFIED-VBGibbsOnly.Rmd"
param(
    [Parameter(Mandatory=$true)]
    [string]$FilePath
)

$fileName = Split-Path -Leaf $FilePath
Write-Host "Knitting $fileName to PDF..." -ForegroundColor Cyan

# Call the main knit script but override to PDF output
$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$mainScript = Join-Path $scriptDir "knit_current_file.ps1"

# Run with PDF output
& $mainScript -FilePath $FilePath -OutputFormat "pdf_document"
