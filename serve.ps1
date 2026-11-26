# Simple local web server (no install needed). Serves files in this folder.
# Usage: powershell -File serve.ps1 -Port 5000   ->  http://localhost:5000/
param([int]$Port = 5000)

$root = $PSScriptRoot.TrimEnd('\') + '\'
$types = @{
  '.html' = 'text/html; charset=utf-8';  '.css'  = 'text/css; charset=utf-8'
  '.js'   = 'application/javascript; charset=utf-8'; '.json' = 'application/json; charset=utf-8'
  '.md'   = 'text/plain; charset=utf-8'; '.txt'  = 'text/plain; charset=utf-8'
  '.png'  = 'image/png'; '.jpg' = 'image/jpeg'; '.svg' = 'image/svg+xml'; '.ico' = 'image/x-icon'
}

$listener = New-Object System.Net.HttpListener
$listener.Prefixes.Add("http://localhost:$Port/")
$listener.Start()
Write-Host "Serving $root at http://localhost:$Port/  (Ctrl+C to stop)"

try {
  while ($listener.IsListening) {
    $ctx = $listener.GetContext()
    # One failed request must never stop the whole server
    try {
      $urlPath = [Uri]::UnescapeDataString($ctx.Request.Url.AbsolutePath)
      if ($urlPath -eq '/') { $urlPath = '/memo.html' }
      try { $file = [IO.Path]::GetFullPath((Join-Path $root $urlPath.TrimStart('/'))) } catch { $file = '' }

      # Only files inside this folder can be opened (blocks ../ tricks)
      if ($file.StartsWith($root, [StringComparison]::OrdinalIgnoreCase) -and (Test-Path -LiteralPath $file -PathType Leaf)) {
        $bytes = [IO.File]::ReadAllBytes($file)
        $ext = [IO.Path]::GetExtension($file).ToLower()
        $ctx.Response.ContentType = if ($types.ContainsKey($ext)) { $types[$ext] } else { 'application/octet-stream' }
        $ctx.Response.Headers.Add('Cache-Control', 'no-store')
        $ctx.Response.ContentLength64 = $bytes.Length
        # HEAD requests only ask for headers, so send no body
        if ($ctx.Request.HttpMethod -ne 'HEAD') { $ctx.Response.OutputStream.Write($bytes, 0, $bytes.Length) }
      } else {
        $ctx.Response.StatusCode = 404
      }
    } catch {
      Write-Host "request error: $($_.Exception.Message)"
    } finally {
      try { $ctx.Response.Close() } catch {}
    }
  }
} finally {
  $listener.Stop()
}
