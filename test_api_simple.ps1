# Test Gemini API Key
$apiKey = "AIzaSyBhc83iACHIsNc14hCEdS7_8aYbWH_yhvw"
$url = "https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent?key=$apiKey"

$body = @{
    contents = @(
        @{
            parts = @(
                @{
                    text = "Say OK if you can read this"
                }
            )
        }
    )
} | ConvertTo-Json -Depth 10

Write-Host "Testing API key..." -ForegroundColor Yellow

try {
    $response = Invoke-RestMethod -Uri $url -Method POST -Body $body -ContentType "application/json"
    Write-Host "SUCCESS! API is working!" -ForegroundColor Green
    Write-Host "Response: $($response.candidates[0].content.parts[0].text)" -ForegroundColor Green
} catch {
    Write-Host "FAILED! API key is NOT working!" -ForegroundColor Red
    Write-Host "Error: $($_.Exception.Message)" -ForegroundColor Red
    Write-Host ""
    Write-Host "The API key in your code appears to be invalid or expired." -ForegroundColor Yellow
    Write-Host ""
    Write-Host "What to do:" -ForegroundColor Cyan
    Write-Host "1. Go to https://aistudio.google.com/app/apikey"
    Write-Host "2. Generate a NEW API key"
    Write-Host "3. Copy the key"
    Write-Host "4. Replace in lib/core/services/ai_sentiment_service.dart (line 32)"
    Write-Host "5. Replace in lib/core/services/ai_chatbot_service.dart (line 58)"
}
