try {
  $resp = Invoke-RestMethod -Uri "https://api.groq.com/openai/v1/models" `
    -Headers @{ "Authorization" = "Bearer $env:GROQ_API_KEY" } `
    -TimeoutSec 30
  $resp.data | ForEach-Object { Write-Host $_.id }
} catch {
  $status = $_.Exception.Response.StatusCode.value__
  Write-Host "MODELS_FAIL status=$status"
  Write-Host $_.ErrorDetails.Message
}
