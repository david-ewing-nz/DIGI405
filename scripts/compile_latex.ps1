param(
    [Parameter(Mandatory=$true)]
    [string]$FilePath
)

$ErrorActionPreference = "Continue"

# Get file info
$file = Get-Item $FilePath
$baseName = $file.BaseName
$directory = $file.DirectoryName

Write-Host "Compiling LaTeX file: $($file.Name)" -ForegroundColor Cyan
Write-Host "Working directory: $directory" -ForegroundColor Gray

# Change to file directory
Set-Location $directory

# Run xelatex twice (for references and cross-references)
Write-Host "`nFirst pass..." -ForegroundColor Yellow
xelatex -interaction=nonstopmode "$baseName.tex" 2>&1 | Out-Host

Write-Host "`nSecond pass..." -ForegroundColor Yellow
xelatex -interaction=nonstopmode "$baseName.tex" 2>&1 | Out-Host

# Check if PDF was created
$pdfPath = Join-Path $directory "$baseName.pdf"
if (Test-Path $pdfPath) {
    $pdfSize = (Get-Item $pdfPath).Length / 1KB
    Write-Host "`nSuccess: PDF created at $pdfPath ($([math]::Round($pdfSize, 1)) KB)" -ForegroundColor Green
    
    # Show timestamp
    $timestamp = (Get-Item $pdfPath).LastWriteTime
    Write-Host "PDF timestamp: $timestamp" -ForegroundColor Gray
    
    exit 0
} else {
    Write-Host "`nError: PDF was not created" -ForegroundColor Red
    exit 1
}
