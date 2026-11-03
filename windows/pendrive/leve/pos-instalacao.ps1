# Deixa o Windows 11 leve e pronto para o trabalho. Roda uma vez, no primeiro login (autounattend.xml),
# ou à mão: clique com o botão direito > "Executar com o PowerShell".
# O registro do que foi feito fica na Área de Trabalho: pos-instalacao.txt

$ErrorActionPreference = 'Continue'

# Precisa de administrador
$admin = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole(
	[Security.Principal.WindowsBuiltInRole]::Administrator)
if (-not $admin) {
	Start-Process powershell -Verb RunAs -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`""
	exit
}

$log = Join-Path ([Environment]::GetFolderPath('Desktop')) 'pos-instalacao.txt'
Start-Transcript -Path $log -Append | Out-Null
Write-Host "Deixando o Windows leve. Pode usar o computador, mas não desligue. Leva de 10 a 30 minutos." -ForegroundColor Cyan

function Definir-Registro($caminho, $nome, $valor, $tipo = 'DWord') {
	if (-not (Test-Path $caminho)) { New-Item -Path $caminho -Force | Out-Null }
	Set-ItemProperty -Path $caminho -Name $nome -Value $valor -Type $tipo -Force
}

# 1. Ponto de restauração antes de mexer em tudo
Write-Host "`n== Ponto de restauração"
Enable-ComputerRestore -Drive "$env:SystemDrive\"
Definir-Registro 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\SystemRestore' 'SystemRestorePointCreationFrequency' 0
Checkpoint-Computer -Description 'Antes de deixar leve' -RestorePointType MODIFY_SETTINGS

# 2. Apps que vêm junto e só ocupam espaço (Calculadora, Fotos, Loja, Bloco de Notas etc. ficam)
Write-Host "`n== Removendo apps desnecessários"
$apps = @(
	'Microsoft.BingNews', 'Microsoft.BingWeather', 'Microsoft.BingSearch', 'Microsoft.GamingApp',
	'Microsoft.GetHelp', 'Microsoft.Getstarted', 'Microsoft.MicrosoftOfficeHub',
	'Microsoft.MicrosoftSolitaireCollection', 'Microsoft.People', 'Microsoft.PowerAutomateDesktop',
	'Microsoft.Todos', 'Microsoft.WindowsFeedbackHub', 'Microsoft.WindowsMaps', 'Microsoft.Xbox.TCUI',
	'Microsoft.XboxGamingOverlay', 'Microsoft.XboxGameOverlay', 'Microsoft.XboxIdentityProvider',
	'Microsoft.XboxSpeechToTextOverlay', 'Microsoft.549981C3F5F10', 'Microsoft.OutlookForWindows',
	'Microsoft.Windows.DevHome', 'Microsoft.Copilot', 'MicrosoftTeams', 'MSTeams', 'Clipchamp.Clipchamp',
	'Microsoft.MixedReality.Portal', 'Microsoft.SkypeApp', 'Microsoft.ZuneVideo'
)
foreach ($app in $apps) {
	Get-AppxPackage -AllUsers -Name $app | Remove-AppxPackage -AllUsers -ErrorAction SilentlyContinue
	Get-AppxProvisionedPackage -Online | Where-Object DisplayName -eq $app |
		Remove-AppxProvisionedPackage -Online -ErrorAction SilentlyContinue | Out-Null
	Write-Host "  - $app"
}

# OneDrive sai: os arquivos na nuvem ficam no Google Drive
Write-Host "`n== Removendo o OneDrive"
Stop-Process -Name OneDrive -Force -ErrorAction SilentlyContinue
foreach ($setup in "$env:SystemRoot\System32\OneDriveSetup.exe", "$env:SystemRoot\SysWOW64\OneDriveSetup.exe") {
	if (Test-Path $setup) { Start-Process $setup -ArgumentList '/uninstall' -Wait }
}

# 3. Sem propagandas, sugestões, Bing no menu, widgets, Copilot e telemetria
Write-Host "`n== Desligando propagandas, sugestões e telemetria"
$cdm = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager'
foreach ($chave in 'SilentInstalledAppsEnabled', 'SystemPaneSuggestionsEnabled', 'SoftLandingEnabled',
	'PreInstalledAppsEnabled', 'OemPreInstalledAppsEnabled', 'SubscribedContent-338388Enabled',
	'SubscribedContent-338389Enabled', 'SubscribedContent-353694Enabled', 'SubscribedContent-353696Enabled',
	'SubscribedContent-310093Enabled') {
	Definir-Registro $cdm $chave 0
}
Definir-Registro 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\CloudContent' 'DisableWindowsConsumerFeatures' 1
Definir-Registro 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\CloudContent' 'DisableSoftLanding' 1
Definir-Registro 'HKCU:\Software\Policies\Microsoft\Windows\Explorer' 'DisableSearchBoxSuggestions' 1
Definir-Registro 'HKLM:\SOFTWARE\Policies\Microsoft\Dsh' 'AllowNewsAndInterests' 0
Definir-Registro 'HKCU:\Software\Policies\Microsoft\Windows\WindowsCopilot' 'TurnOffWindowsCopilot' 1
Definir-Registro 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\AdvertisingInfo' 'DisabledByGroupPolicy' 1
Definir-Registro 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection' 'AllowTelemetry' 0
Definir-Registro 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced' 'Start_IrisRecommendations' 0
Definir-Registro 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced' 'HideFileExt' 0
Definir-Registro 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Search' 'SearchboxTaskbarMode' 1
foreach ($servico in 'DiagTrack', 'dmwappushservice') {
	Stop-Service $servico -Force -ErrorAction SilentlyContinue
	Set-Service $servico -StartupType Disabled -ErrorAction SilentlyContinue
}
# Edge não fica rodando escondido em segundo plano
Definir-Registro 'HKLM:\SOFTWARE\Policies\Microsoft\Edge' 'StartupBoostEnabled' 0
Definir-Registro 'HKLM:\SOFTWARE\Policies\Microsoft\Edge' 'BackgroundModeEnabled' 0

# 4. Convivência com o outro sistema no mesmo note
Write-Host "`n== Ajustes para dois sistemas no mesmo note"
# Relógio: o Linux guarda a hora em UTC; sem isto a hora fica errada ao trocar de sistema
Definir-Registro 'HKLM:\SYSTEM\CurrentControlSet\Control\TimeZoneInformation' 'RealTimeIsUniversal' 1
# Sem "inicialização rápida" (hibernação): ela trava o disco e atrapalha o outro sistema. Libera ~6 GB.
powercfg /hibernate off

# 5. Apps do trabalho (precisa de internet)
Write-Host "`n== Esperando a internet"
$limite = (Get-Date).AddMinutes(15)
while (-not (Test-Connection -ComputerName www.microsoft.com -Count 1 -Quiet) -and (Get-Date) -lt $limite) {
	Write-Host "  sem internet ainda... conecte no Wi-Fi"
	Start-Sleep -Seconds 20
}

Write-Host "`n== Preparando o instalador de apps (winget)"
$limite = (Get-Date).AddMinutes(10)
while (-not (Get-Command winget -ErrorAction SilentlyContinue) -and (Get-Date) -lt $limite) {
	Add-AppxPackage -RegisterByFamilyName -MainPackage Microsoft.DesktopAppInstaller_8wekyb3d8bbwe -ErrorAction SilentlyContinue
	Start-Sleep -Seconds 15
}

Write-Host "`n== Instalando os apps"
$programas = @(
	@{ Nome = 'Google Chrome'; Id = 'Google.Chrome'; Fonte = 'winget' },
	@{ Nome = 'WhatsApp'; Id = '9NKSQGP7F2NH'; Fonte = 'msstore' },
	@{ Nome = 'Canva'; Id = 'Canva.Canva'; Fonte = 'winget' },
	@{ Nome = 'Google Drive'; Id = 'Google.GoogleDrive'; Fonte = 'winget' },
	@{ Nome = 'Bambu Studio'; Id = 'Bambulab.Bambustudio'; Fonte = 'winget' },
	@{ Nome = 'VLC'; Id = 'VideoLAN.VLC'; Fonte = 'winget' },
	@{ Nome = '7-Zip'; Id = '7zip.7zip'; Fonte = 'winget' }
)
$falharam = @()
foreach ($p in $programas) {
	Write-Host "  - $($p.Nome)"
	winget install --id $p.Id --source $p.Fonte --exact --silent --accept-package-agreements --accept-source-agreements
	if ($LASTEXITCODE -ne 0 -and $LASTEXITCODE -ne -1978335189) { $falharam += $p.Nome }  # -1978335189 = já instalado
}

Write-Host "`n== Atualizando o que já veio instalado"
winget upgrade --all --silent --accept-package-agreements --accept-source-agreements

Stop-Transcript | Out-Null

Add-Type -AssemblyName PresentationFramework
$texto = "Pronto! O Windows está leve e com os apps instalados.`n`nReinicie o computador para terminar."
if ($falharam.Count -gt 0) {
	$texto += "`n`nNão consegui instalar: $($falharam -join ', '). Instale pela Microsoft Store ou pelo site."
}
$texto += "`n`nO registro completo está na Área de Trabalho: pos-instalacao.txt"
[System.Windows.MessageBox]::Show($texto, 'Windows leve') | Out-Null
