# Convert all bmatrix to right-aligned array in VI-example.Rmd

$filePath = "d:\github\VI1\R\VI-example.Rmd"
$content = Get-Content $filePath -Raw

# Pattern 1: 2-column matrices (rr)
$content = $content -replace '\\begin\{bmatrix\}(\s*`r[^`]+`[^&]*&[^`]+`[^\\]+\\\\\\\\\s*)+', {
    param($match)
    $lines = $match.Value -split '\\\\\\\\'
    $ncols = 0
    foreach ($line in $lines) {
        $ampCount = ($line -split '&').Count - 1
        if ($ampCount -gt $ncols) { $ncols = $ampCount }
    }
    $ncols += 1  # number of & separators + 1 = number of columns
    $colSpec = 'r' * $ncols
    $match.Value -replace '\\begin\{bmatrix\}', "\left[\begin{array}{$colSpec}"
}

# Pattern 2: Replace all remaining \begin{bmatrix}
# We'll determine column count from first row
$content = $content -replace '\\begin\{bmatrix\}', {
    # Default to 4 columns if can't determine
    '\left[\begin{array}{rrrr}'
}

# Replace all \end{bmatrix} with \end{array}\right]
$content = $content -replace '\\end\{bmatrix\}', '\end{array}\right]'

# Save back
Set-Content -Path $filePath -Value $content -NoNewline

Write-Host "Conversion complete!" -ForegroundColor Green
Write-Host "All bmatrix → right-aligned array format" -ForegroundColor Cyan
