$manifest = "android/app/src/main/AndroidManifest.xml"
if (!(Test-Path $manifest)) {
  Write-Host "AndroidManifest.xml belum ada, skip patch."
  exit 0
}
$content = Get-Content $manifest -Raw
$permissions = @(
  '<uses-permission android:name="android.permission.INTERNET" />'
)
foreach ($perm in $permissions) {
  $name = ($perm -replace '.*android:name="([^"]+)".*', '$1')
  if ($content -notmatch [regex]::Escape($name)) {
    $content = $content -replace '(<manifest[^>]*>)', "`$1`n    $perm"
  }
}
if ($content -notmatch 'usesCleartextTraffic') {
  $content = $content -replace '<application', '<application android:usesCleartextTraffic="true"'
}
Set-Content $manifest $content -Encoding UTF8
Write-Host "Android INTERNET + cleartext traffic sudah dipatch."
