# Knit VI-example.Rmd to PDF
Set-Location $PSScriptRoot\..
Write-Host "Knitting R/VI-example.Rmd..." -ForegroundColor Cyan

# Run Rscript (ignore exit code due to warnings)
Rscript -e "rmarkdown::render('R/VI-example.Rmd', output_dir = 'report')" 2>&1 | Out-Host

# Check if PDF was created
if (Test-Path "report/VI-example.pdf") {
    Write-Host "`nSuccess: PDF created at report/VI-example.pdf" -ForegroundColor Green
    exit 0
} else {
    Write-Host "`nError: PDF was not created" -ForegroundColor Red
    exit 1
}
