# Compile LaTeX (.tex) file using XeLaTeX
# Usage: compile_tex.ps1 -FilePath <path-to-tex-file>

param(
    [Parameter(Mandatory=$true)]
    [string]$FilePath
)

# Verify file exists
if (-not (Test-Path $FilePath)) {
    Write-Host "ERROR: File not found: $FilePath" -ForegroundColor Red
    exit 1
}

# Get file info
$file = Get-Item $FilePath
$fileName = $file.Name
$fileDir = $file.DirectoryName
$fileBaseName = $file.BaseName

Write-Host "Compiling $fileName with XeLaTeX..." -ForegroundColor Cyan

# Change to file directory (xelatex outputs to current directory)
Push-Location $fileDir

try {
    # First pass
    Write-Host "`n=== First XeLaTeX pass ===" -ForegroundColor Yellow
    $result1 = xelatex -interaction=nonstopmode $fileName 2>&1
    
    if ($LASTEXITCODE -ne 0) {
        Write-Host "ERROR: First XeLaTeX pass failed" -ForegroundColor Red
        Write-Host $result1
        exit 1
    }
    
    # Second pass (for cross-references)
    Write-Host "`n=== Second XeLaTeX pass ===" -ForegroundColor Yellow
    $result2 = xelatex -interaction=nonstopmode $fileName 2>&1
    
    if ($LASTEXITCODE -ne 0) {
        Write-Host "ERROR: Second XeLaTeX pass failed" -ForegroundColor Red
        Write-Host $result2
        exit 1
    }
    
    # Check if PDF was created
    $pdfPath = Join-Path $fileDir "$fileBaseName.pdf"
    if (Test-Path $pdfPath) {
        $pdfSize = (Get-Item $pdfPath).Length
        $pdfSizeKB = [math]::Round($pdfSize / 1KB, 1)
        Write-Host "`nSUCCESS: PDF generated at $pdfPath ($pdfSizeKB KB)" -ForegroundColor Green
        
        # Open PDF (optional - comment out if not desired)
        # Start-Process $pdfPath
    } else {
        Write-Host "`nWARNING: XeLaTeX completed but PDF not found at $pdfPath" -ForegroundColor Yellow
    }
    
} finally {
    Pop-Location
}

exit 0
