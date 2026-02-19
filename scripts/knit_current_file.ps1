# Knit the currently active R Markdown file
# Clean build: source in R/, build in temp, output in report/
# Archive: timestamped snapshots of Rmd + PDF before each build
param(
    [Parameter(Mandatory=$true)]
    [string]$FilePath,
    
    [Parameter(Mandatory=$false)]
    [string]$OutputFormat = "default"  # "default", "html_document", "pdf_document"
)

$ext = [IO.Path]::GetExtension($FilePath)
if ($ext -ne ".Rmd") {
    $candidateRmd = [IO.Path]::ChangeExtension($FilePath, ".Rmd")
    if (Test-Path $candidateRmd) {
        Write-Host "Note: Input is not .Rmd; using $candidateRmd" -ForegroundColor Yellow
        $FilePath = $candidateRmd
    } else {
        Write-Host "Error: File must be .Rmd (or a matching .Rmd must exist)." -ForegroundColor Red
        exit 1
    }
}

$fileName = Split-Path -Leaf $FilePath
$fileDir = Split-Path -Parent $FilePath
$projectRoot = Split-Path -Parent $fileDir
$baseName = $fileName -replace '\.Rmd$', ''

Write-Host "Knitting $fileName..." -ForegroundColor Cyan

$reportDir = Join-Path $projectRoot "report"

# Create temp build folder with R/ subfolder (replicates project structure)
$tempDir = Join-Path $env:TEMP "VI1_knit_$(Get-Date -Format 'yyyyMMdd_HHmmss')"
$tempRDir = Join-Path $tempDir "R"
$tempFigsDir = Join-Path $tempDir "figs"
$tempReportDir = Join-Path $tempDir "report"
$tempResultsDir = Join-Path $tempDir "results"

New-Item -ItemType Directory -Path $tempRDir -Force | Out-Null
New-Item -ItemType Directory -Path $tempFigsDir -Force | Out-Null
New-Item -ItemType Directory -Path $tempReportDir -Force | Out-Null
New-Item -ItemType Directory -Path $tempResultsDir -Force | Out-Null

$runStart = Get-Date

try {
    # Copy Rmd to temp/R/ (maintains same relative path structure as real project)
    Copy-Item $FilePath -Destination $tempRDir
    
    # Also copy local assets from the Rmd's folder (images/tex/pdf)
    Get-ChildItem $fileDir -File | Where-Object { $_.Extension -in (".png", ".jpg", ".jpeg", ".pdf", ".tex") } | ForEach-Object {
        Copy-Item $_.FullName -Destination $tempRDir -Force
    }
    
    # Replace MARGIN_STRING with filename and timestamp in the copied Rmd
    $tempRmdPath = Join-Path $tempRDir $fileName
    $timestamp = Get-Date -Format 'yyyy-MM-dd HH:mm:ss'
    
    # Create LaTeX-safe version (escape underscores, use \DTMnow for PDF timestamp)
    $fileNameEscaped = $fileName -replace '_', '\_'
    $marginStringLaTeX = "{$fileNameEscaped \textbar{} Compiled: \DTMnow}"
    
    # Plain version for HTML
    $marginStringHTML = "$fileName | Compiled: $timestamp"
    
    $rmdContent = Get-Content $tempRmdPath -Raw -Encoding UTF8
    # Replace in subtitle (HTML context)
    $rmdContent = $rmdContent -replace "subtitle: 'MARGIN_STRING'", "subtitle: '$marginStringHTML'"
    # Replace in LaTeX command (PDF context) - single quotes protect YAML from special chars
    $rmdContent = $rmdContent -replace "'\\newcommand\{\\mymarginlabel\}\{MARGIN_STRING\}'", "'\newcommand{\mymarginlabel}$marginStringLaTeX'"
    Set-Content -Path $tempRmdPath -Value $rmdContent -Encoding UTF8
    
    Write-Host "Replaced MARGIN_STRING with: $marginStringHTML" -ForegroundColor Gray
    
    # Copy all .R source files from project R/ to temp/R/ (for sourcing)
    $projectRDir = Join-Path $projectRoot "R"
    Get-ChildItem $projectRDir -Filter "*.R" | ForEach-Object {
        Copy-Item $_.FullName -Destination $tempRDir -Force
    }

    # Keep temp figs/results empty before render
    $projectFigsDir = Join-Path $projectRoot "figs"
    
    # Set working directory to temp/R/ (so YAML's ../figs and ../report work)
    Set-Location $tempRDir
    
    # Run Rscript from temp/R/ folder (default output format from YAML)
    if ($OutputFormat -eq "default") {
        $output = Rscript -e "rmarkdown::render('$fileName')" 2>&1
    } else {
        $output = Rscript -e "rmarkdown::render('$fileName', output_format = '$OutputFormat')" 2>&1
    }
    
    # Display output
    $output | Out-Host
    
    # Check for HTML or PDF in temp/report/ or temp/R/ (fallback)
    $htmlName = $baseName + '.html'
    $pdfName = $baseName + '.pdf'
    
    $tempHtmlPath1 = Join-Path $tempDir "report\$htmlName"
    $tempHtmlPath2 = Join-Path $tempDir "R\$htmlName"
    $tempPdfPath1 = Join-Path $tempDir "report\$pdfName"
    $tempPdfPath2 = Join-Path $tempDir "R\$pdfName"
    
    $outputCreated = $false
    $outputPath = $null
    $outputName = $null
    $outputType = $null
    
    if (Test-Path $tempHtmlPath1) {
        $outputPath = $tempHtmlPath1
        $outputName = $htmlName
        $outputType = "HTML"
        $outputCreated = $true
    } elseif (Test-Path $tempHtmlPath2) {
        $outputPath = $tempHtmlPath2
        $outputName = $htmlName
        $outputType = "HTML"
        $outputCreated = $true
        Write-Host "Note: HTML found in temp/R/ instead of temp/report/" -ForegroundColor Yellow
    } elseif (Test-Path $tempPdfPath1) {
        $outputPath = $tempPdfPath1
        $outputName = $pdfName
        $outputType = "PDF"
        $outputCreated = $true
    } elseif (Test-Path $tempPdfPath2) {
        $outputPath = $tempPdfPath2
        $outputName = $pdfName
        $outputType = "PDF"
        $outputCreated = $true
        Write-Host "Note: PDF found in temp/R/ instead of temp/report/" -ForegroundColor Yellow
    }
    
    if ($outputCreated) {
        # Copy output file to project report/
        Copy-Item $outputPath -Destination $reportDir -Force
        
        # Also copy from temp/report/ if it exists (for compatibility)
        $tempReportDir = Join-Path $tempDir "report"
        if (Test-Path $tempReportDir) {
            Get-ChildItem $tempReportDir -Include *.pdf, *.html | ForEach-Object {
                Copy-Item $_.FullName -Destination $reportDir -Force
            }
        }
        
        # Do not copy PNG or RDS outputs into project folders
        $tempFigsDir = Join-Path $tempDir "figs"
        $tempResultsDir = Join-Path $tempDir "results"
        
        Write-Host "`nSuccess: $outputType created at report/$outputName" -ForegroundColor Green
        
        # Create archive AFTER successful build
        $timestamp = Get-Date -Format 'yyyy-MM-dd_HHmmss'
        $archiveDir = Join-Path $projectRoot "archive\${timestamp}_${baseName}"
        $archiveRDir = Join-Path $archiveDir "R"
        $archiveReportDir = Join-Path $archiveDir "report"
        $archiveFigsDir = Join-Path $archiveDir "figs"
        $archiveResultsDir = Join-Path $archiveDir "results"
        
        New-Item -ItemType Directory -Path $archiveRDir -Force | Out-Null
        New-Item -ItemType Directory -Path $archiveReportDir -Force | Out-Null
        New-Item -ItemType Directory -Path $archiveFigsDir -Force | Out-Null
        New-Item -ItemType Directory -Path $archiveResultsDir -Force | Out-Null
        
        # Archive source Rmd to R/ folder (VI-Unified is self-contained)
        Copy-Item $FilePath -Destination $archiveRDir
        
        # Archive newly created output file to report/ folder
        $outputFilePath = Join-Path $reportDir $outputName
        if (Test-Path $outputFilePath) {
            Copy-Item $outputFilePath -Destination $archiveReportDir
        }
        
        # Do not archive PNG or RDS outputs
        
        Write-Host "Archived: archive/${timestamp}_${baseName}/" -ForegroundColor Gray
        
        # Check file timestamps
        Write-Host "`n=== File timestamps ===" -ForegroundColor Cyan
        
        $outputFilePath = Join-Path $reportDir $outputName
        if (Test-Path $outputFilePath) {
            $sizeLabel = if ($outputType -eq "HTML") { "Size(KB)" } else { "Size(KB)" }
            Get-Item $outputFilePath | Format-List @{N="${outputType}_Time";E={$_.LastWriteTime.ToString('HH:mm:ss')}}, @{N=$sizeLabel;E={[math]::Round($_.Length/1KB,1)}}
        }
        
        # Check PNG and RDS timestamps in temp folders (full date+time, no truncation)
        $pngCount = 0
        if (Test-Path $tempFigsDir) {
            $pngItems = Get-ChildItem $tempFigsDir -Filter "*.png" | Sort-Object LastWriteTime -Descending
            $pngCount = $pngItems.Count
            if ($pngCount -gt 0) {
                $pngItems |
                    Select-Object @{N='PNG_File';E={$_.Name}}, @{N='DateTime';E={$_.LastWriteTime.ToString('yyyy-MM-dd HH:mm:ss')}}, @{N='Size(KB)';E={[math]::Round($_.Length/1KB,1)}} |
                    Format-Table -AutoSize | Out-String -Width 300 | Write-Host
            } else {
                Write-Host "No PNG files in temp/figs." -ForegroundColor Yellow
            }
        } else {
            Write-Host "temp/figs folder not found." -ForegroundColor Yellow
        }

        $rdsCount = 0
        if (Test-Path $tempResultsDir) {
            $rdsItems = Get-ChildItem $tempResultsDir -Filter "*.rds" | Sort-Object LastWriteTime -Descending
            $rdsCount = $rdsItems.Count
            if ($rdsCount -gt 0) {
                $rdsItems |
                    Select-Object @{N='RDS_File';E={$_.Name}}, @{N='DateTime';E={$_.LastWriteTime.ToString('yyyy-MM-dd HH:mm:ss')}}, @{N='Size(KB)';E={[math]::Round($_.Length/1KB,1)}} |
                    Format-Table -AutoSize | Out-String -Width 300 | Write-Host
            } else {
                Write-Host "No RDS files in temp/results." -ForegroundColor Yellow
            }
        } else {
            Write-Host "temp/results folder not found." -ForegroundColor Yellow
        }

        Write-Host "`nPNG count in temp/figs: $pngCount" -ForegroundColor Cyan
        Write-Host "RDS count in temp/results: $rdsCount" -ForegroundColor Cyan

        # Per-run outputs are listed from temp folders above
        
        # Auto-open generated output file
        if (Test-Path $outputFilePath) {
            Write-Host "`nOpening $outputType file..." -ForegroundColor Cyan
            Start-Process $outputFilePath
        }
        
        exit 0
    } else {
        Write-Host "`nError: Output file was not created" -ForegroundColor Red
        Write-Host "Checking for error files in temp directory..." -ForegroundColor Yellow
        
        # Look for tex and log files to help diagnose
        $tempRDir = Join-Path $tempDir "R"
        if (Test-Path $tempRDir) {
            $texFiles = Get-ChildItem $tempRDir -Filter "*.tex" -ErrorAction SilentlyContinue
            $logFiles = Get-ChildItem $tempRDir -Filter "*.log" -ErrorAction SilentlyContinue
            
            if ($texFiles) {
                Write-Host "Found .tex files - LaTeX compilation failed" -ForegroundColor Yellow
                if ($logFiles) {
                    Write-Host "Check log file: $($logFiles[0].FullName)" -ForegroundColor Cyan
                }
            }
        }
        
        Write-Host "`nTemp directory preserved at: $tempDir" -ForegroundColor Cyan
        exit 1
    }
}
finally {
    # Only clean up temp folder if output was successfully created
    Set-Location $projectRoot
    if ($outputCreated -and (Test-Path $tempDir)) {
        Remove-Item $tempDir -Recurse -Force -ErrorAction SilentlyContinue
    }
}
