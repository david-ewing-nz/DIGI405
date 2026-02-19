# Monitor M2 knitting and auto-update PowerPoint when complete
# Runs autonomously while user is away

$ErrorActionPreference = "Continue"
$maxAttempts = 60  # Check for up to 60 cycles (5 minutes)
$checkInterval = 5  # seconds between checks

Write-Host "`n=== M2 Knitting Monitor Started ===" -ForegroundColor Cyan
Write-Host "Monitoring for: figs/M2_tau_u_overlay_comparison.png"
Write-Host "Will check every $checkInterval seconds for up to $($maxAttempts * $checkInterval / 60) minutes`n"

$attempt = 0
$lastModified = $null

while ($attempt -lt $maxAttempts) {
    $attempt++
    $timestamp = Get-Date -Format "HH:mm:ss"
    
    # Check if plot exists
    if (Test-Path "figs/M2_tau_u_overlay_comparison.png") {
        $currentModified = (Get-Item "figs/M2_tau_u_overlay_comparison.png").LastWriteTime
        
        if ($lastModified -eq $null) {
            $lastModified = $currentModified
            Write-Host "[$timestamp] Check $attempt : Plot exists (baseline: $($currentModified.ToString('HH:mm:ss')))"
        }
        elseif ($currentModified -gt $lastModified) {
            Write-Host "`n[$timestamp] SUCCESS! Plot regenerated at $($currentModified.ToString('HH:mm:ss'))" -ForegroundColor Green
            
            # Generate complete presentation
            Write-Host "`nGenerating comprehensive PowerPoint presentation..." -ForegroundColor Yellow
            & D:/github/VI1/.venv/Scripts/python.exe scripts/create_presentation_with_ratings.py
            
            if ($LASTEXITCODE -eq 0) {
                Write-Host "`nPresentation successfully generated!" -ForegroundColor Green
                Write-Host "Location: figs/VI_Analysis_Presentation_Complete.pptx"
            }
            else {
                Write-Host "`nWarning: Presentation generation encountered issues" -ForegroundColor Yellow
            }
            
            Write-Host "`n=== Monitoring Complete ===" -ForegroundColor Cyan
            exit 0
        }
        else {
            Write-Host "[$timestamp] Check $attempt : No update yet (last modified: $($lastModified.ToString('HH:mm:ss')))"
        }
    }
    else {
        Write-Host "[$timestamp] Check $attempt : Plot not yet created"
    }
    
    Start-Sleep -Seconds $checkInterval
}

Write-Host "`n[$timestamp] Timeout reached after $attempt checks" -ForegroundColor Yellow
Write-Host "M2 knitting may still be in progress or encountered errors."
Write-Host "Check the knitting terminal for status.`n" -ForegroundColor Yellow

exit 1
