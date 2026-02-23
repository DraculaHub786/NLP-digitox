# Test Gemini API Key
$apiKey = "AIzaSyBhc83iACHIsNc14hCEdS7_8aYbWH_yhvw"
$url = "https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent?key=$apiKey"

$body = @{
    contents = @(
        @{
            parts = @(
                @{
                    text = "Say 'API is working' if you can read this."
                }
            )
        }
    )
} | ConvertTo-Json -Depth 10

try {
    Write-Host "Testing API key..." -ForegroundColor Yellow
    Write-Host "URL: $url" -ForegroundColor Cyan
    
    $response = Invoke-RestMethod -Uri $url -Method POST -Body $body -ContentType "application/json" -ErrorAction Stop
    
    Write-Host "`n✅ SUCCESS! API Key is working!" -ForegroundColor Green
    Write-Host "Response: $($response.candidates[0].content.parts[0].text)" -ForegroundColor Green
    
} catch {
    Write-Host "`n❌ FAILED! API Key is NOT working!" -ForegroundColor Red
    Write-Host "Error: $($_.Exception.Message)" -ForegroundColor Red
    
    if ($_.Exception.Response) {
        $statusCode = $_.Exception.Response.StatusCode.value__
        Write-Host "Status Code: $statusCode" -ForegroundColor Red
        
        if ($statusCode -eq 404) {
            Write-Host "`n⚠️ The API endpoint was not found (404)" -ForegroundColor Yellow
            Write-Host "This usually means:" -ForegroundColor Yellow
            Write-Host "  1. The API key is invalid or expired" -ForegroundColor Yellow
            Write-Host "  2. The Generative Language API is not enabled in your Google Cloud project" -ForegroundColor Yellow
            Write-Host "  3. The API key restrictions don't allow this API" -ForegroundColor Yellow
        } elseif ($statusCode -eq 403) {
            Write-Host "`n⚠️ Permission denied (403)" -ForegroundColor Yellow
            Write-Host "The API key lacks permission to access the Gemini API" -ForegroundColor Yellow
        } elseif ($statusCode -eq 429) {
            Write-Host "`n⚠️ Rate limit exceeded (429)" -ForegroundColor Yellow
            Write-Host "Too many requests. Wait a minute and try again." -ForegroundColor Yellow
        }
    }
    
    Write-Host "`n📋 What to do:" -ForegroundColor Cyan
    Write-Host "1. Visit: https://aistudio.google.com/app/apikey" -ForegroundColor White
    Write-Host "2. Generate a NEW API key" -ForegroundColor White
    Write-Host "3. Make sure Generative Language API is enabled" -ForegroundColor White
    Write-Host "4. Replace the API key in both service files" -ForegroundColor White
}
