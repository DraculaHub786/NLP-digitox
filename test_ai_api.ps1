# AI API Diagnostic Script
# Run this to test if your API key works

Write-Host "`n🔍 AI API Diagnostic Tool" -ForegroundColor Cyan
Write-Host "====================================`n" -ForegroundColor Cyan

# Extract API key from the service file
$servicePath = "lib\core\services\ai_sentiment_service.dart"
if (Test-Path $servicePath) {
    $content = Get-Content $servicePath -Raw
    if ($content -match "_apiKey = '([^']+)'") {
        $apiKey = $matches[1]
        Write-Host "✓ Found API key in service file" -ForegroundColor Green
        
        # Check if it's a placeholder
        if ($apiKey -like "*YOUR_*" -or $apiKey.Length -lt 30) {
            Write-Host "✗ API key is a placeholder or invalid!" -ForegroundColor Red
            Write-Host "  Get a new key at: https://aistudio.google.com/app/apikey`n" -ForegroundColor Yellow
            exit 1
        }
        
        # Check if it starts with AIza
        if ($apiKey -notlike "AIza*") {
            Write-Host "⚠ Warning: API key doesn't start with 'AIza'" -ForegroundColor Yellow
            Write-Host "  This might not be a valid Gemini API key`n" -ForegroundColor Yellow
        } else {
            Write-Host "  Key starts with: $($apiKey.Substring(0,10))..." -ForegroundColor Gray
        }
        
        # Test the API key with a simple request
        Write-Host "`n🧪 Testing API key with Google Gemini...`n" -ForegroundColor Cyan
        
        $url = "https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent?key=$apiKey"
        $body = @{
            contents = @(
                @{
                    parts = @(
                        @{
                            text = "Say 'Hello' if you're working"
                        }
                    )
                }
            )
        } | ConvertTo-Json -Depth 10
        
        try {
            $response = Invoke-WebRequest -Uri $url -Method POST -Body $body -ContentType "application/json" -ErrorAction Stop
            
            if ($response.StatusCode -eq 200) {
                Write-Host "✓ API KEY WORKS! ✓" -ForegroundColor Green -BackgroundColor Black
                Write-Host "`nAPI Response:" -ForegroundColor Green
                $jsonResponse = $response.Content | ConvertFrom-Json
                if ($jsonResponse.candidates) {
                    $text = $jsonResponse.candidates[0].content.parts[0].text
                    Write-Host "  $text" -ForegroundColor Gray
                }
                Write-Host "`n✅ Your AI integration should work fine!`n" -ForegroundColor Green
            }
        } catch {
            $statusCode = $_.Exception.Response.StatusCode.value__
            $errorBody = $_.ErrorDetails.Message
            
            Write-Host "✗ API TEST FAILED" -ForegroundColor Red -BackgroundColor Black
            Write-Host "`nStatus Code: $statusCode" -ForegroundColor Yellow
            Write-Host "Error: $errorBody`n" -ForegroundColor Red
            
            # Provide specific solutions
            switch ($statusCode) {
                400 {
                    Write-Host "❌ BAD REQUEST (400)" -ForegroundColor Red
                    Write-Host "  Issue: Invalid model name or request format" -ForegroundColor Yellow
                    Write-Host "  Solution: Model name should be 'gemini-1.5-flash'`n" -ForegroundColor Yellow
                }
                401 {
                    Write-Host "❌ INVALID API KEY (401)" -ForegroundColor Red
                    Write-Host "  Issue: Your API key is invalid or disabled" -ForegroundColor Yellow
                    Write-Host "  Solution:" -ForegroundColor Yellow
                    Write-Host "    1. Get new key: https://aistudio.google.com/app/apikey" -ForegroundColor Cyan
                    Write-Host "    2. Update both service files (sentiment + chatbot)" -ForegroundColor Cyan
                    Write-Host "    3. Run: flutter run`n" -ForegroundColor Cyan
                }
                403 {
                    Write-Host "❌ FORBIDDEN (403)" -ForegroundColor Red
                    Write-Host "  Issue: API key doesn't have access to Gemini API" -ForegroundColor Yellow
                    Write-Host "  Solution: Enable Gemini API in Google Cloud Console`n" -ForegroundColor Yellow
                }
                404 {
                    Write-Host "❌ MODEL NOT FOUND (404)" -ForegroundColor Red
                    Write-Host "  Issue: Wrong model name" -ForegroundColor Yellow
                    Write-Host "  Solution: Use 'gemini-1.5-flash' not 'gemini-2.0-flash'`n" -ForegroundColor Yellow
                }
                429 {
                    Write-Host "❌ RATE LIMIT / QUOTA EXCEEDED (429)" -ForegroundColor Red
                    Write-Host "  Issue: Too many requests" -ForegroundColor Yellow
                    Write-Host "  Free Tier Limits:" -ForegroundColor Yellow
                    Write-Host "    • 60 requests per minute" -ForegroundColor Gray
                    Write-Host "    • 1,500 requests per day" -ForegroundColor Gray
                    Write-Host "  Solutions:" -ForegroundColor Yellow
                    Write-Host "    1. Wait 60 seconds and try again" -ForegroundColor Cyan
                    Write-Host "    2. Generate a new API key (fresh quota)" -ForegroundColor Cyan
                    Write-Host "    3. Check usage: https://aistudio.google.com/" -ForegroundColor Cyan
                    Write-Host "    4. Wait until tomorrow (quota resets daily)`n" -ForegroundColor Cyan
                }
                503 {
                    Write-Host "❌ SERVICE UNAVAILABLE (503)" -ForegroundColor Red
                    Write-Host "  Issue: Gemini API is temporarily down" -ForegroundColor Yellow
                    Write-Host "  Solution: Wait a few minutes and try again`n" -ForegroundColor Yellow
                }
                default {
                    Write-Host "❌ UNKNOWN ERROR ($statusCode)" -ForegroundColor Red
                    Write-Host "  Check: https://ai.google.dev/docs`n" -ForegroundColor Yellow
                }
            }
        }
        
    } else {
        Write-Host "✗ Could not find API key in service file" -ForegroundColor Red
        Write-Host "  Check: $servicePath`n" -ForegroundColor Yellow
    }
} else {
    Write-Host "✗ Service file not found: $servicePath" -ForegroundColor Red
    Write-Host "  Are you in the project root directory?`n" -ForegroundColor Yellow
}

Write-Host "====================================`n" -ForegroundColor Cyan
Write-Host "📚 Need more help? Check AI_API_FIXES.md" -ForegroundColor Gray
Write-Host ""
