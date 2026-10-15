<#
  Baut die Android-Datei (.aab) für Google Play.

  Beispiel:
    powershell -File tool\build_release.ps1 -BuildNumber 2 -RevenueCatAndroidKey goog_XXXX

  Das Skript bricht ab, wenn
    - die Schlüsseldatei android\key.properties oder der Upload-Schlüssel fehlt
      (sonst würde die Datei mit dem Test-Schlüssel signiert und Google Play
      würde sie ablehnen),
    - die Versionsnummer schon vergeben ist,
    - Analyse oder Tests Fehler melden (mit -SkipChecks überspringbar).

  Der RevenueCat-Schlüssel (beginnt mit goog_) ist ein öffentlicher
  App-Schlüssel, kein Geheimnis. Ohne ihn lässt sich nichts kaufen.
  Nichts davon wird ins Git geschrieben.
#>
param(
  [Parameter(Mandatory = $true)][int]$BuildNumber,
  [string]$RevenueCatAndroidKey = '',
  [string]$OutDir = (Join-Path $env:USERPROFILE 'Desktop\Lookin-Upload'),
  [switch]$SkipChecks
)

$ErrorActionPreference = 'Stop'
$root = Split-Path -Parent $PSScriptRoot
Set-Location $root

function Stop-Build([string]$message) {
  Write-Host "ABBRUCH: $message" -ForegroundColor Red
  exit 1
}

# 1. Upload-Schlüssel muss da sein.
$keyFile = Join-Path $root 'android\key.properties'
if (-not (Test-Path $keyFile)) {
  Stop-Build 'android\key.properties fehlt. Ohne Upload-Schlüssel kann Google Play die Datei nicht annehmen.'
}
$storeLine = Select-String -Path $keyFile -Pattern '^storeFile=(.+)$' | Select-Object -First 1
if (-not $storeLine) { Stop-Build 'In key.properties fehlt die Zeile storeFile=.' }
$storePath = $storeLine.Matches[0].Groups[1].Value.Trim()
if (-not [System.IO.Path]::IsPathRooted($storePath)) {
  $storePath = Join-Path (Join-Path $root 'android\app') $storePath
}
if (-not (Test-Path $storePath)) {
  Stop-Build "Die Schlüsseldatei $storePath wurde nicht gefunden."
}

# 2. Versionsnummer muss neu sein (Google Play verlangt jedes Mal eine höhere).
$pubspec = Get-Content (Join-Path $root 'pubspec.yaml') -Raw
if ($pubspec -notmatch '(?m)^version:\s*(\d+\.\d+\.\d+)\+\d+') {
  Stop-Build 'Keine Version in pubspec.yaml gefunden.'
}
$versionName = $Matches[1]
New-Item -ItemType Directory -Force $OutDir | Out-Null
$existing = Get-ChildItem $OutDir -Filter 'lookin-*-versionCode*.aab' -ErrorAction SilentlyContinue
foreach ($file in $existing) {
  if ($file.Name -match 'versionCode(\d+)\.aab$' -and [int]$Matches[1] -ge $BuildNumber) {
    Stop-Build "Es gibt schon $($file.Name). Nimm eine höhere Nummer als $($Matches[1])."
  }
}

if (-not $RevenueCatAndroidKey) {
  Write-Host 'Hinweis: Kein RevenueCat-Schlüssel angegeben. Kaufen ist in dieser Datei nicht möglich.' -ForegroundColor Yellow
} elseif ($RevenueCatAndroidKey -notmatch '^goog_[A-Za-z0-9]+$') {
  Stop-Build 'Der RevenueCat-Schlüssel für Android beginnt mit goog_.'
}

# 3. Prüfungen.
if (-not $SkipChecks) {
  Write-Host '> flutter analyze'
  flutter analyze
  if ($LASTEXITCODE -ne 0) { Stop-Build 'flutter analyze meldet Probleme.' }
  Write-Host '> flutter test'
  flutter test
  if ($LASTEXITCODE -ne 0) { Stop-Build 'Tests schlagen fehl.' }
}

# 4. Bauen.
$arguments = @('build', 'appbundle', '--release', "--build-number=$BuildNumber")
if ($RevenueCatAndroidKey) { $arguments += "--dart-define=REVENUECAT_ANDROID_KEY=$RevenueCatAndroidKey" }
Write-Host "> flutter $($arguments -join ' ' -replace 'goog_[A-Za-z0-9]+', 'goog_***')"
flutter @arguments
if ($LASTEXITCODE -ne 0) { Stop-Build 'Der Build ist fehlgeschlagen.' }

$built = Join-Path $root 'build\app\outputs\bundle\release\app-release.aab'
if (-not (Test-Path $built)) { Stop-Build 'Die gebaute Datei wurde nicht gefunden.' }
$target = Join-Path $OutDir "lookin-$versionName-versionCode$BuildNumber.aab"
Copy-Item $built $target
$size = [math]::Round((Get-Item $target).Length / 1MB, 1)
Write-Host "Fertig: $target ($size MB)" -ForegroundColor Green
Write-Host 'Diese Datei in der Play Console hochladen.'
