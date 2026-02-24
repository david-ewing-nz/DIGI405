# PowerShell script to extract text from images using free OCR API
# Uses OCR.space free API (no key required for basic usage)

$figsPath = Join-Path $PSScriptRoot "..\figs"
$imageFiles = Get-ChildItem -Path $figsPath -Filter "Screenshot*.png" | Sort-Object Name

Write-Host "Found $($imageFiles.Count) images to process"
Write-Host "Using OCR.space free API service"
Write-Host ""

$results = @()
$counter = 0

foreach ($imageFile in $imageFiles) {
    $counter++
    Write-Host "Processing $counter/$($imageFiles.Count): $($imageFile.Name)"
    
    try {
        # Read image as base64
        $imageBytes = [System.IO.File]::ReadAllBytes($imageFile.FullName)
        $base64 = [Convert]::ToBase64String($imageBytes)
        
        # Prepare form data
        $boundary = [System.Guid]::NewGuid().ToString()
        $LF = "`r`n"
        
        $bodyLines = @(
            "--$boundary",
            "Content-Disposition: form-data; name=`"base64Image`"",
            "",
            "data:image/png;base64,$base64",
            "--$boundary",
            "Content-Disposition: form-data; name=`"language`"",
            "",
            "eng",
            "--$boundary",
            "Content-Disposition: form-data; name=`"isOverlayRequired`"",
            "",
            "false",
            "--$boundary--"
        )
        
        $body = $bodyLines -join $LF
        
        # Call OCR API
        $response = Invoke-RestMethod -Uri "https://api.ocr.space/parse/image" `
            -Method Post `
            -ContentType "multipart/form-data; boundary=$boundary" `
            -Body $body `
            -TimeoutSec 30
        
        if ($response.IsErroredOnProcessing -eq $false -and $response.ParsedResults) {
            $text = $response.ParsedResults[0].ParsedText
            
            $results += [PSCustomObject]@{
                Index = $counter
                Filename = $imageFile.Name
                Text = $text.Trim()
            }
            
            Write-Host "  ✓ Success" -ForegroundColor Green
        } else {
            $errorMsg = if ($response.ErrorMessage) { $response.ErrorMessage[0] } else { "Unknown error" }
            Write-Warning "  ✗ OCR failed: $errorMsg"
            
            $results += [PSCustomObject]@{
                Index = $counter
                Filename = $imageFile.Name
                Text = "[ERROR: OCR failed - $errorMsg]"
            }
        }
        
        # Rate limiting - free API allows 10 requests per 10 seconds
        Start-Sleep -Milliseconds 1100
        
    } catch {
        Write-Warning "  ✗ Error: $_"
        $results += [PSCustomObject]@{
            Index = $counter
            Filename = $imageFile.Name
            Text = "[ERROR: $_]"
        }
    }
}

# Save results
$outputFile = Join-Path $PSScriptRoot "..\extracted_text.txt"

$output = ""
foreach ($result in $results) {
    $output += "`n" + ("=" * 80) + "`n"
    $output += "IMAGE $($result.Index): $($result.Filename)`n"
    $output += ("=" * 80) + "`n`n"
    $output += $result.Text + "`n`n"
}

$output | Out-File -FilePath $outputFile -Encoding UTF8

Write-Host ""
Write-Host "Done! Processed $($results.Count) images." -ForegroundColor Green
Write-Host "Output saved to: $outputFile"
