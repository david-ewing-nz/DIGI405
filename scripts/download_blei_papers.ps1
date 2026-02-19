# PowerShell script to download David Blei's papers from Columbia University
# Creates ./reference/blei/ directory and downloads all PDFs

# Define target directory using string path
$blei_dir = "reference\blei"

# Create directory if it doesn't exist
if (-not (Test-Path $blei_dir)) {
    New-Item -ItemType Directory -Path $blei_dir -Force | Out-Null
    Write-Host "Created directory: $blei_dir" -ForegroundColor Green
}

# Array of PDF URLs extracted from Blei's publications page
$pdf_urls = @(
    "https://www.cs.columbia.edu/~blei/papers/JessonBeltran-VelezBlei2025.pdf",
    "https://www.cs.columbia.edu/~blei/papers/SalazarKucerWangCasletonBlei2025.pdf",
    "https://www.cs.columbia.edu/~blei/papers/NazaretFanLavalleeBurdziakCornishKiseliovasBowmanMasilionisChunEismanWangHongShiLevineMazutisBleiPe'erAzizi2025.pdf",
    "https://www.cs.columbia.edu/~blei/papers/VafaAtheyBlei2025.pdf",
    "https://www.cs.columbia.edu/~blei/papers/SalehiNazaretShahBlei2024.pdf",
    "https://www.cs.columbia.edu/~blei/papers/ShiBeltran-VelezNazaretZhengGarriga-AlonsoJessonMakarBlei2024.pdf",
    "https://www.cs.columbia.edu/~blei/papers/JessonVelezChuKarlekarKossenGalCunninghamBlei2024.pdf",
    "https://www.cs.columbia.edu/~blei/papers/Beltran-VelezGrandeNazaretKucukelbirBlei2024.pdf",
    "https://www.cs.columbia.edu/~blei/papers/CaiModiMargossianGowerBleiSaul2024.pdf",
    "https://www.cs.columbia.edu/~blei/papers/YinWangBlei2024.pdf",
    "https://www.cs.columbia.edu/~blei/papers/MargossianBlei2024a.pdf",
    "https://www.cs.columbia.edu/~blei/papers/NazaretBlei2024.pdf",
    "https://www.cs.columbia.edu/~blei/papers/NazaretHongAziziBlei2024.pdf",
    "https://www.cs.columbia.edu/~blei/papers/BradshawBlei2024.pdf",
    "https://www.cs.columbia.edu/~blei/papers/HeJinNazaretShiChenRampersaudDhillonValdezFriendFanParkMintzLaoCarreraFangMehdiRohdeMcFaline-FigueroaBleiLeongRudenskyPlitasAzizi2024.pdf",
    "https://www.cs.columbia.edu/~blei/papers/CaiModiPillaud-VivienMargossianGowerBleiSaul2024.pdf",
    "https://www.cs.columbia.edu/~blei/papers/VafaPalikotDuKanodiaAtheyBlei2024.pdf",
    "https://www.cs.columbia.edu/~blei/papers/NazaretShiBlei2024.pdf",
    "https://www.cs.columbia.edu/~blei/papers/ParkBlei2024.pdf",
    "https://www.cs.columbia.edu/~blei/papers/de%20BaccoWangBlei2024.pdf",
    "https://www.cs.columbia.edu/~blei/papers/MoranBleiRanganath0.pdf",
    "https://www.cs.columbia.edu/~blei/papers/YinShiWangBlei0.pdf",
    "https://www.cs.columbia.edu/~blei/papers/ZhengVafaBlei2023.pdf",
    "https://www.cs.columbia.edu/~blei/papers/ZhangBleiNaesseth2023.pdf",
    "https://www.cs.columbia.edu/~blei/papers/KugelgenBesserveLiangGreseleKekicBareinboimBleiScholkopf2023.pdf",
    "https://www.cs.columbia.edu/~blei/papers/ModiGowerMargossianYaoBleiSaul2023.pdf",
    "https://www.cs.columbia.edu/~blei/papers/ScherrerShiFederBlei2023b.pdf",
    "https://www.cs.columbia.edu/~blei/papers/FederWaldShiSariaBlei2023.pdf",
    "https://www.cs.columbia.edu/~blei/papers/WuTrippeNaessethBleiCunningham2023.pdf",
    "https://www.cs.columbia.edu/~blei/papers/ShiZhengVafaFederBlei2023.pdf",
    "https://www.cs.columbia.edu/~blei/papers/WangSridharBlei2023.pdf",
    "https://www.cs.columbia.edu/~blei/papers/ModiLiBlei2023.pdf",
    "https://www.cs.columbia.edu/~blei/papers/WangGaoYinZhouBlei2023.pdf",
    "https://www.cs.columbia.edu/~blei/papers/MoranCunninghamBlei2022.pdf",
    "https://www.cs.columbia.edu/~blei/papers/ZhangWangSchuemieBleiHripcsak2022.pdf",
    "https://www.cs.columbia.edu/~blei/papers/SridharBlei2022.pdf",
    "https://www.cs.columbia.edu/~blei/papers/MoranSridharWangBlei2022.pdf",
    "https://www.cs.columbia.edu/~blei/papers/NazaretBlei2022.pdf",
    "https://www.cs.columbia.edu/~blei/papers/MenonBleiVondrick2022.pdf",
    "https://www.cs.columbia.edu/~blei/papers/TanseyToshBlei2022.pdf",
    "https://www.cs.columbia.edu/~blei/papers/TanseyVeitchZhangRabadanBlei2022.pdf",
    "https://www.cs.columbia.edu/~blei/papers/SridharDaumeBlei2022a.pdf",
    "https://www.cs.columbia.edu/~blei/papers/MillerAndersonLeistedtCunninghamHoggBlei2022a.pdf",
    "https://www.cs.columbia.edu/~blei/papers/SridharBaccoBlei2022.pdf",
    "https://www.cs.columbia.edu/~blei/papers/ShiSridharMisraBlei2022.pdf",
    "https://www.cs.columbia.edu/~blei/papers/ShiVeitchBlei2021.pdf",
    "https://www.cs.columbia.edu/~blei/papers/TanseyLiZhangLindermanBleiRabadanWiggins2020.pdf",
    "https://www.cs.columbia.edu/~blei/papers/VafaDengBleiRush2021.pdf",
    "https://www.cs.columbia.edu/~blei/papers/LoperBleiCunninghamPaninski2021.pdf",
    "https://www.cs.columbia.edu/~blei/papers/DonnellyRuizBleiAthey2021.pdf",
    "https://www.cs.columbia.edu/~blei/papers/WangBleiCunningham2021.pdf",
    "https://www.cs.columbia.edu/~blei/papers/WuMillerAndersonPleissBleiCunningham2021a.pdf",
    "https://www.cs.columbia.edu/~blei/papers/ScheinVafaSridharVeitchQuinnMoffetBleiGreen2021.pdf",
    "https://www.cs.columbia.edu/~blei/papers/ParkLeeKimBlei2021.pdf",
    "https://www.cs.columbia.edu/~blei/papers/WangBlei2021.pdf",
    "https://www.cs.columbia.edu/~blei/papers/MorettiZhangNaessethVennerBleiPe'er2021.pdf"
)

# Download first 50 papers as demo (add more URLs to the array to download all)
$count = 0
$success = 0
$failed = 0

foreach ($url in $pdf_urls) {
    $count++
    
    # Extract filename from URL
    $filename = Split-Path -Leaf $url
    
    # Replace encoded characters
    $filename = $filename -replace "%20", " "
    $filename = $filename -replace "%27", "'"
    
    $output_path = Join-Path $blei_dir $filename
    
    try {
        Write-Host "[$count] Downloading: $filename" -ForegroundColor Yellow
        Invoke-WebRequest -Uri $url -OutFile $output_path -ErrorAction Stop
        Write-Host "     ✓ Saved to: $output_path" -ForegroundColor Green
        $success++
    }
    catch {
        Write-Host "     ✗ Failed: $($_.Exception.Message)" -ForegroundColor Red
        $failed++
    }
    
    # Polite delay between downloads (optional, to avoid server throttling)
    Start-Sleep -Milliseconds 500
}

Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "Download Summary:" -ForegroundColor Cyan
Write-Host "  Total attempted: $count" -ForegroundColor Cyan
Write-Host "  Successful: $success" -ForegroundColor Green
Write-Host "  Failed: $failed" -ForegroundColor $(if ($failed -gt 0) { "Red" } else { "Green" })
Write-Host "  Destination: $blei_dir" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
