# Extract text from screenshot images using Windows OCR
# Requires Windows 10 or later

Add-Type -AssemblyName System.Runtime.WindowsRuntime
$null = [Windows.Storage.StorageFile, Windows.Storage, ContentType = WindowsRuntime]
$null = [Windows.Media.Ocr.OcrEngine, Windows.Foundation, ContentType = WindowsRuntime]
$null = [Windows.Foundation.IAsyncOperation`1, Windows.Foundation, ContentType = WindowsRuntime]
$null = [Windows.Graphics.Imaging.BitmapDecoder, Windows.Graphics, ContentType = WindowsRuntime]

# Helper function to await async operations
Function Await($WinRtTask, $ResultType) {
    $asTask = ([System.WindowsRuntimeSystemExtensions].GetMethods() | Where-Object { 
        $_.Name -eq 'AsTask' -and $_.GetParameters().Count -eq 1 -and $_.GetParameters()[0].ParameterType.Name -eq 'IAsyncOperation`1' 
    })
    
    if ($asTask.Count -eq 0) {
        throw "AsTask method not found"
    }
    
    $asTaskGeneric = $asTask[0].MakeGenericMethod($ResultType)
    $netTask = $asTaskGeneric.Invoke($null, @($WinRtTask))
    $netTask.GetAwaiter().GetResult()
}

# Initialize OCR engine
$ocrEngine = [Windows.Media.Ocr.OcrEngine]::TryCreateFromUserProfileLanguages()

if ($null -eq $ocrEngine) {
    Write-Error "OCR engine not available. Please ensure Windows OCR language packs are installed."
    exit 1
}

# Get all screenshot files
$figsPath = Join-Path $PSScriptRoot "..\figs"
$imageFiles = Get-ChildItem -Path $figsPath -Filter "Screenshot*.png" | Sort-Object Name

$results = @()
$counter = 0

Write-Host "Found $($imageFiles.Count) images to process"
Write-Host ""

foreach ($imageFile in $imageFiles) {
    $counter++
    Write-Host "Processing $counter/$($imageFiles.Count): $($imageFile.Name)"
    
    try {
        # Load image file
        $file = Await ([Windows.Storage.StorageFile]::GetFileFromPathAsync($imageFile.FullName)) ([Windows.Storage.StorageFile])
        
        # Open stream
        $stream = Await ($file.OpenAsync([Windows.Storage.FileAccessMode]::Read)) ([Windows.Storage.Streams.IRandomAccessStream])
        
        # Create decoder
        $decoder = Await ([Windows.Graphics.Imaging.BitmapDecoder]::CreateAsync($stream)) ([Windows.Graphics.Imaging.BitmapDecoder])
        
        # Get bitmap
        $bitmap = Await ($decoder.GetSoftwareBitmapAsync()) ([Windows.Graphics.Imaging.SoftwareBitmap])
        
        # Perform OCR
        $ocrResult = Await ($ocrEngine.RecognizeAsync($bitmap)) ([Windows.Media.Ocr.OcrResult])
        
        # Extract text
        $text = $ocrResult.Text
        
        $results += [PSCustomObject]@{
            Index = $counter
            Filename = $imageFile.Name
            Text = $text
        }
        
        # Cleanup
        $stream.Dispose()
        
    } catch {
        Write-Warning "Error processing $($imageFile.Name): $_"
        $results += [PSCustomObject]@{
            Index = $counter
            Filename = $imageFile.Name
            Text = "[ERROR: Could not extract text - $_]"
        }
    }
}

# Save results to file
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
Write-Host "Done! Processed $($results.Count) images."
Write-Host "Output saved to: $outputFile"
