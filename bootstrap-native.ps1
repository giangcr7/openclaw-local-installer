[CmdletBinding()]
param(
  [Parameter(Mandatory=$true)][string]$BundleUrl,
  [Parameter(Mandatory=$true)][string]$Sha256,
  [Parameter(Mandatory=$true)][string]$Name,
  [Parameter(Mandatory=$true)][string]$OwnerIds,
  [string]$GroupId = '', [string]$BaseUrl = 'https://provider.example/v1', [Parameter(Mandatory=$true)][string]$Model,
  [switch]$DryRun
)
$ErrorActionPreference='Stop'
if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) { throw 'Run PowerShell as Administrator.' }
$work = Join-Path $env:TEMP ("openclaw-native-" + [guid]::NewGuid().ToString('N'))
New-Item -ItemType Directory -Path $work | Out-Null
try {
  $archive = Join-Path $work 'native-full-bundle.tar.gz'
  Invoke-WebRequest -Uri $BundleUrl -OutFile $archive
  $actual = (Get-FileHash $archive -Algorithm SHA256).Hash.ToLowerInvariant()
  if ($actual -ne $Sha256.ToLowerInvariant()) { throw "SHA256 mismatch: $actual" }
  tar -xzf $archive -C $work
  $installer = Join-Path $work 'install-native-windows.ps1'
  if ($DryRun) { & $installer -Name $Name -OwnerIds $OwnerIds -GroupId $GroupId -BaseUrl $BaseUrl -Model $Model -DryRun; exit $LASTEXITCODE }
  & $installer -Name $Name -OwnerIds $OwnerIds -GroupId $GroupId -BaseUrl $BaseUrl -Model $Model
  if ($LASTEXITCODE -ne 0) { throw 'Native installer failed.' }
} finally { if (Test-Path $work) { Remove-Item $work -Recurse -Force } }
