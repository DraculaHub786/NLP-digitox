# Script to Update Gemini API Key in Both Service Files

Write-Host "=== Gemini API Key Updater ===" -ForegroundColor Cyan
Write-Host ""

# Prompt for the new API key
$newApiKey = Read-Host "Paste your NEW Gemini API key here (starts with AIza)"

if ($newApiKey -eq "" -or $newApiKey.Length -lt 30) {
    Write-Host "ERROR: Invalid API key. Please run the script again." -ForegroundColor Red
    exit
}

# Trim any extra spaces
$newApiKey = $newApiKey.Trim()

Write-Host ""
Write-Host "Testing API key..." -ForegroundColor Yellow

# Test the API key first
$testUrl = "https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent?key=$newApiKey"
$testBody = @{contents = @(@{parts = @(@{text = "Test"})})} | ConvertTo-Json -Depth 10

try {
    $null = Invoke-RestMethod -Uri $testUrl -Method POST -Body $testBody -ContentType "application/json" -TimeoutSec 5
    Write-Host "SUCCESS! API key is valid and working!" -ForegroundColor Green
    Write-Host ""
} catch {
    Write-Host "ERROR: API key test failed!" -ForegroundColor Red
    Write-Host "Error: $($_.Exception.Message)" -ForegroundColor Red
    Write-Host ""
    Write-Host "Please make sure:" -ForegroundColor Yellow
    Write-Host "1. The API key is correct" -ForegroundColor Yellow
    Write-Host "2. Generative Language API is enabled in Google Cloud Console" -ForegroundColor Yellow
    Write-Host "3. You have internet connection" -ForegroundColor Yellow
    Write-Host ""
    $continue = Read-Host "Do you want to continue updating the files anyway? (y/n)"
    if ($continue -ne "y") {
        Write-Host "Aborted." -ForegroundColor Yellow
        exit
    }
}

# File paths
$file1 = "lib\core\services\ai_sentiment_service.dart"
$file2 = "lib\core\services\ai_chatbot_service.dart"

# Update file 1
Write-Host "Updating $file1..." -ForegroundColor Cyan
$content1 = Get-Content $file1 -Raw
$pattern1 = "static const String _apiKey = '[^']+'; // Replace with your actual API key"
$replacement1 = "static const String _apiKey = '$newApiKey'; // Replace with your actual API key"
$content1 = $content1 -replace $pattern1, $replacement1

# Also try alternative pattern in case the comment is different
$pattern1Alt = "static const String _apiKey = 'AIza[^']*';"
if ($content1 -match $pattern1Alt) {
    $content1 = $content1 -replace $pattern1Alt, "static const String _apiKey = '$newApiKey';"
}

Set-Content $file1 -Value $content1 -NoNewline
Write-Host "Updated $file1" -ForegroundColor Green

# Update file 2
Write-Host "Updating $file2..." -ForegroundColor Cyan
$content2 = Get-Content $file2 -Raw
$pattern2 = "static const String _apiKey = '[^']+'; // Replace with your actual API key"
$replacement2 = "static const String _apiKey = '$newApiKey'; // Replace with your actual API key"
$content2 = $content2 -replace $pattern2, $replacement2

# Also try alternative pattern
$pattern2Alt = "static const String _apiKey = 'AIza[^']*';"
if ($content2 -match $pattern2Alt) {
    $content2 = $content2 -replace $pattern2Alt, "static const String _apiKey = '$newApiKey';"
}

Set-Content $file2 -Value $content2 -NoNewline
Write-Host "Updated $file2" -ForegroundColor Green

Write-Host ""
Write-Host "=== Done! ===" -ForegroundColor Green
Write-Host ""
Write-Host "API key has been updated in both files!" -ForegroundColor Green
Write-Host ""
Write-Host "Next steps:" -ForegroundColor Cyan
Write-Host "1. Run: flutter clean" -ForegroundColor White
Write-Host "2. Run: flutter pub get" -ForegroundColor White
Write-Host "3. Run: flutter run" -ForegroundColor White
Write-Host ""
Write-Host "The AI features should now work!" -ForegroundColor Green
