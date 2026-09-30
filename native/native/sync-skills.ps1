[CmdletBinding()]
param([Parameter(Mandatory=$true)][string]$OpenClawRoot, [string]$BundleDir = "$PSScriptRoot\skills")
$ErrorActionPreference = 'Stop'
$destination = Join-Path $OpenClawRoot 'workspace\skills'
New-Item -ItemType Directory -Force -Path $destination | Out-Null
$count = 0
Get-ChildItem -LiteralPath $BundleDir -Directory | ForEach-Object {
  $target = Join-Path $destination $_.Name
  if (Test-Path $target) { Copy-Item -LiteralPath (Join-Path $_.FullName '*') -Destination $target -Recurse -Force }
  else { Copy-Item -LiteralPath $_.FullName -Destination $destination -Recurse -Force }
  $count++
}
if ($count -eq 0) { throw 'No bundled skills found.' }
Write-Host "skills_sync=ok total=$count"
