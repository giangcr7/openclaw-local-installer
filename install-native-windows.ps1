[CmdletBinding()]
param(
  [Parameter(Mandatory=$true)][string]$Name,
  [Parameter(Mandatory=$true)][string]$OwnerIds,
  [string]$GroupId = '',
  [string]$AssistantName = 'Trợ lý OpenClaw',
  [string]$BaseUrl = 'https://provider.example/v1',
  [string]$Model = '',
  [string]$OpenClawVersion = '2026.9.4',
  [switch]$DryRun
)
$ErrorActionPreference = 'Stop'
if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) { throw 'Run PowerShell as Administrator.' }
if ($Name -notmatch '^[a-z][a-z0-9_-]{0,63}$') { throw 'Name must use lowercase letters, numbers, underscore or hyphen.' }
if ([string]::IsNullOrWhiteSpace($Model)) { throw 'Model is required.' }
$owners = @($OwnerIds -split ',' | ForEach-Object { $_.Trim() } | Where-Object { $_ -match '^[1-9][0-9]*$' })
if ($owners.Count -eq 0) { throw 'At least one positive Telegram owner ID is required.' }
if ($DryRun) { Write-Host "DRY-RUN: native OpenClaw $OpenClawVersion for $Name; no files or services changed."; exit 0 }
$telegramToken = Read-Host 'Telegram Bot Token' -AsSecureString
$providerKey = Read-Host 'Provider API Key' -AsSecureString
function Unprotect([Security.SecureString]$Value) { $b=[Runtime.InteropServices.Marshal]::SecureStringToBSTR($Value); try { [Runtime.InteropServices.Marshal]::PtrToStringBSTR($b) } finally { [Runtime.InteropServices.Marshal]::ZeroFreeBSTR($b) } }
$tg = Unprotect $telegramToken
$key = Unprotect $providerKey
$root = Join-Path $env:USERPROFILE '.openclaw'
$workspace = Join-Path $root 'workspace'
New-Item -ItemType Directory -Force -Path $root,$workspace,(Join-Path $workspace 'skills') | Out-Null
if (-not (Get-Command node -ErrorAction SilentlyContinue)) {
  if (Get-Command winget -ErrorAction SilentlyContinue) { winget install --id OpenJS.NodeJS.LTS --exact --silent --accept-package-agreements --accept-source-agreements }
  else { throw 'Node.js is missing and winget is unavailable.' }
}
if (-not (Get-Command python -ErrorAction SilentlyContinue)) {
  if (Get-Command winget -ErrorAction SilentlyContinue) { winget install --id Python.Python.3.12 --exact --silent --accept-package-agreements --accept-source-agreements }
  else { throw 'Python is missing and winget is unavailable.' }
}
if (-not (Get-Command ffmpeg -ErrorAction SilentlyContinue)) {
  if (Get-Command winget -ErrorAction SilentlyContinue) { winget install --id Gyan.FFmpeg.Shared --exact --silent --accept-package-agreements --accept-source-agreements }
  else { Write-Warning 'FFmpeg is missing; media modules will need FFmpeg installed later.' }
}
if (-not (Get-Command npm -ErrorAction SilentlyContinue)) { throw 'npm is unavailable after Node.js installation.' }
$current = (& npm list --global openclaw --depth=0 2>$null | Out-String)
if ($current -notmatch "openclaw@$OpenClawVersion") { npm install --global "openclaw@$OpenClawVersion" }
$tokenPath = Join-Path $root 'telegram.token'
[IO.File]::WriteAllText($tokenPath, "$tg`n", [Text.UTF8Encoding]::new($false))
$configPath = Join-Path $root 'openclaw.json'
if (Test-Path $configPath) { Copy-Item $configPath "$configPath.backup-$(Get-Date -Format yyyyMMddHHmmss)" }
$account = @{
  enabled=$true; tokenFile=$tokenPath; dmPolicy='allowlist'; allowFrom=$owners
  groupPolicy='allowlist'; groupAllowFrom=$owners
}
if ($GroupId) { $account.groups=@{ $GroupId=@{ requireMention=$false; allowFrom=$owners } } }
$groupTools = @{}
foreach ($owner in $owners) { $groupTools["channel:telegram:$owner"] = @{ alsoAllow=@('exec','process') } }
if ($GroupId) { $account.groups[$GroupId].toolsBySender = $groupTools }
$config = @{
  gateway=@{ mode='local'; bind='loopback'; auth=@{ mode='token'; token=(-join ((1..64) | ForEach-Object { '{0:x}' -f (Get-Random -Maximum 16) })) } }
  secrets=@{ providers=@{ customer=@{ source='file'; path=(Join-Path $root 'member-provider.secret'); mode='singleValue' } } }
  models=@{ providers=@{ customer=@{ baseUrl=$BaseUrl; apiKey=@{ source='file'; provider='customer'; id='value' }; api='openai-completions'; models=@(@{ id=$Model; name=$Model }) } } }
  agents=@{ defaults=@{ workspace=$workspace; model=@{ primary="customer/$Model" } }; entries=@{ main=@{ name=$AssistantName } } }
  channels=@{ telegram=@{ enabled=$true; defaultAccount=$Name; accounts=@{ $Name=$account } } }
  bindings=@(@{ agentId='main'; match=@{ channel='telegram'; accountId=$Name } })
  commands=@{ ownerAllowFrom=@($owners | ForEach-Object { "telegram:$_" }) }
  tools=@{ exec=@{ host='gateway'; mode='full'; strictInlineEval=$false }; process=@{ } }
  meta=@{ member=$Name }
} | ConvertTo-Json -Depth 20
# Install the background daemon before writing the final customer config.
& openclaw onboard --non-interactive --accept-risk --mode local --auth-choice skip --skip-channels --skip-search --skip-skills --install-daemon --skip-health --workspace $workspace --gateway-bind loopback --gateway-auth token --gateway-port 18789 --gateway-token chatbot *> $null
[IO.File]::WriteAllText($configPath, "$config`n", [Text.UTF8Encoding]::new($false))
& powershell -NoProfile -ExecutionPolicy Bypass -File (Join-Path $PSScriptRoot 'native\sync-skills.ps1') -OpenClawRoot $root -BundleDir (Join-Path $PSScriptRoot 'native\skills')
$ensure = Join-Path $PSScriptRoot 'native\skills\tao-tro-ly-openclaw-windows-macos-linux\scripts\ensure_default_telegram_owner.py'
$training = Join-Path $PSScriptRoot 'native\skills\sync-openclaw-owner-training\scripts\sync_owner_training_policy.py'
$backup = Join-Path $root 'backups\onboarding'
$ownerArgs = @('--openclaw-root',$root,'--account-id',$Name,'--agent-id','main','--apply','--backup-dir',$backup)
foreach ($owner in $owners) { $ownerArgs += @('--owner-id',$owner) }
& python $ensure @ownerArgs
& python $training --openclaw-root $root --workspace $workspace --apply --backup-dir $backup
& python (Join-Path $PSScriptRoot 'native\finalize_permissions.py') --config $configPath --owners ($owners -join ',')
& openclaw config validate --json
& openclaw skills check
& openclaw gateway restart *> $null
& openclaw --version
& openclaw gateway status
Write-Host "NATIVE INSTALL COMPLETE: $root"
Write-Host 'Dashboard: http://127.0.0.1:18789/'
