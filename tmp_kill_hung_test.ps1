$procs = Get-CimInstance Win32_Process -Filter "Name='dart.exe'"
foreach ($p in $procs) {
  $cmd = $p.CommandLine
  if ($cmd -and $cmd.Contains('test') -and $cmd.Contains('--packages')) {
    Write-Output ("KILL {0} :: {1}" -f $p.ProcessId, $cmd)
    Stop-Process -Id $p.ProcessId -Force -ErrorAction SilentlyContinue
  }
}
Write-Output "done"
