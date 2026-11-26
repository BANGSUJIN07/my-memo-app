# Start button for the memo app: starts the local server if needed, then opens the browser.
# Used by the desktop shortcut. Add -NoBrowser to skip opening the browser (for testing).
param([switch]$NoBrowser)

$port = 5000
$dir = $PSScriptRoot

function Test-Port { [bool](Get-NetTCPConnection -LocalPort $port -State Listen -ErrorAction SilentlyContinue) }

if (-not (Test-Port)) {
  # Server runs in a minimized window. Closing that window stops the server.
  Start-Process powershell -WindowStyle Minimized -ArgumentList @(
    '-NoProfile', '-ExecutionPolicy', 'Bypass', '-File', "`"$dir\serve.ps1`"", '-Port', $port)
  for ($i = 0; $i -lt 40; $i++) {
    Start-Sleep -Milliseconds 300
    if (Test-Port) { break }
  }
}

if (-not $NoBrowser) { Start-Process "http://localhost:$port/" }
