# 1. Source file read karein
if (Test-Path "games.json") {
    $rawContent = Get-Content "games.json" -Raw | ConvertFrom-Json
    Write-Host "File loaded. Processing segments..." -ForegroundColor Cyan
} else {
    Write-Host "Error: games.json not found!" -ForegroundColor Red
    exit
}

# 2. Deep Extraction Logic
$allOptimizedHits = @()

foreach ($segment in $rawContent.segments) {
    if ($segment.hits) {
        $optimizedSegmentHits = $segment.hits | ForEach-Object {
            
            # Icon hamesha images array ka pehla (aur aksar sirf) link hota hai
            $iconLink = if ($_.images.Count -ge 1) { $_.images[0] } else { $null }

            [PSCustomObject]@{
                id              = $_.id
                slug            = $_.slug
                title           = $_.title
                description     = $_.description
                howToPlayText   = $_.howToPlayText
                gameURL         = $_.gameURL
                playgamaGameUrl = $_.playgamaGameUrl
                # Sirf icon link ko array format mein rakha ja raha hai
                images          = @($iconLink)
                inGamePurchases = $_.inGamePurchases
            }
        }
        $allOptimizedHits += $optimizedSegmentHits
    }
}

# 3. Naya Clean Structure banana
if ($allOptimizedHits.Count -gt 0) {
    $finalObject = [PSCustomObject]@{
        title = "Optimized Games List"
        total_count = $allOptimizedHits.Count
        hits  = $allOptimizedHits
    }

    # 4. JSON mein convert aur save
    $finalJson = $finalObject | ConvertTo-Json -Depth 10
    $finalJson | Set-Content "games_final_lite.json" -Encoding UTF8

    # --- PERFORMANCE STATS ---
    $oldSize = (Get-Item "games.json").Length / 1MB
    $newSize = (Get-Item "games_final_lite.json").Length / 1MB
    $percentSaved = (($oldSize - $newSize) / $oldSize) * 100

    Write-Host "`n==========================================" -ForegroundColor Magenta
    Write-Host "Success! Data Extracted with Named Images." -ForegroundColor Green
    Write-Host "Total Games Found: $($allOptimizedHits.Count)" -ForegroundColor White
    Write-Host "Original Size: $('{0:N2}' -f $oldSize) MB" -ForegroundColor White
    Write-Host "Optimized Size: $('{0:N2}' -f $newSize) MB" -ForegroundColor Green
    Write-Host "Reduction: $([math]::Round($percentSaved, 2))%" -ForegroundColor Yellow
    Write-Host "==========================================" -ForegroundColor Magenta
} else {
    Write-Host "Error: No hits found inside segments!" -ForegroundColor Red
}