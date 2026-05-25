param(
  [string]$Device = "chrome",
  [int]$WebPort = 5000,
  [string[]]$ExtraArgs = @()
)

$projectRoot = Resolve-Path (Join-Path $PSScriptRoot "..")
$envFile = Join-Path $projectRoot ".env"

if (-not (Test-Path $envFile)) {
  Write-Host "Missing .env at $envFile" -ForegroundColor Red
  Write-Host "Create it from .env.example and fill in your Supabase values."
  exit 1
}

$defineArgs = @()

Get-Content $envFile | ForEach-Object {
  $line = $_.Trim()
  if (-not $line) { return }
  if ($line.StartsWith("#")) { return }

  $parts = $line -split "=", 2
  if ($parts.Length -ne 2) { return }

  $key = $parts[0].Trim()
  $value = $parts[1].Trim().Trim('"').Trim("'")
  if (-not $key -or -not $value) { return }

  $defineArgs += "--dart-define=$key=$value"
}

if ($defineArgs.Count -eq 0) {
  Write-Host "No values found in .env to pass as --dart-define." -ForegroundColor Yellow
}

Push-Location $projectRoot
try {
  $argsList = @("run", "-d", $Device, "--web-port=$WebPort") + $defineArgs + $ExtraArgs
  flutter @argsList
} finally {
  Pop-Location
}
