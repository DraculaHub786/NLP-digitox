$models = @("openai/gpt-oss-20b", "qwen/qwen3.6-27b", "groq/compound-mini", "allam-2-7b", "openai/gpt-oss-120b")
foreach ($m in $models) {
  $body = @{
    model = $m
    messages = @(@{ role = "user"; content = "Say OK" })
    max_tokens = 10
  } | ConvertTo-Json -Depth 10
  try {
    $resp = Invoke-RestMethod -Uri "https://api.groq.com/openai/v1/chat/completions" `
      -Method POST `
      -Headers @{ "Authorization" = "Bearer $env:GROQ_API_KEY" } `
      -ContentType "application/json" `
      -Body $body `
      -TimeoutSec 30
    Write-Host "MODEL_OK: $m -> $($resp.choices[0].message.content)"
  } catch {
    $status = $_.Exception.Response.StatusCode.value__
    Write-Host "MODEL_FAIL: $m status=$status"
    if ($_.ErrorDetails.Message) { Write-Host $_.ErrorDetails.Message }
  }
}

