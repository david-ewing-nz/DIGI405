# Convert Jupyter Notebook to PDF
# Usage: .\convert_notebook_to_pdf.ps1 [notebook_path]

param(
    [string]$NotebookPath = "..\code\rnz_climate_analysis.ipynb"
)

# Convert to absolute path
$NotebookPath = Resolve-Path $NotebookPath -ErrorAction Stop

Write-Host "Converting notebook to PDF: $NotebookPath" -ForegroundColor Cyan

# Check if notebook exists
if (-not (Test-Path $NotebookPath)) {
    Write-Error "Notebook not found: $NotebookPath"
    exit 1
}

# Method 1: Try using nbconvert with LaTeX (best quality)
Write-Host "`nAttempting conversion using nbconvert..." -ForegroundColor Yellow
try {
    jupyter nbconvert --to pdf "$NotebookPath" 2>&1 | Write-Host
    
    if ($LASTEXITCODE -eq 0) {
        $PdfPath = $NotebookPath -replace '\.ipynb$', '.pdf'
        Write-Host "`nSuccess! PDF created at: $PdfPath" -ForegroundColor Green
        exit 0
    }
} catch {
    Write-Host "nbconvert failed: $_" -ForegroundColor Red
}

# Method 2: Try using webpdf (if LaTeX not available)
Write-Host "`nAttempting conversion using webpdf..." -ForegroundColor Yellow
try {
    jupyter nbconvert --to webpdf "$NotebookPath" 2>&1 | Write-Host
    
    if ($LASTEXITCODE -eq 0) {
        $PdfPath = $NotebookPath -replace '\.ipynb$', '.pdf'
        Write-Host "`nSuccess! PDF created at: $PdfPath" -ForegroundColor Green
        exit 0
    }
} catch {
    Write-Host "webpdf conversion failed: $_" -ForegroundColor Red
}

# Method 3: Instructions for manual export
Write-Host "`nAutomatic conversion failed. Try one of these methods:" -ForegroundColor Yellow
Write-Host "1. Install LaTeX: Install MiKTeX or TeX Live for Windows"
Write-Host "2. Use VS Code: File > Export > Export As PDF"
Write-Host "3. Use browser: Open notebook in Jupyter, File > Download as > PDF via LaTeX"
Write-Host "4. Install pandoc: choco install pandoc" -ForegroundColor Cyan
