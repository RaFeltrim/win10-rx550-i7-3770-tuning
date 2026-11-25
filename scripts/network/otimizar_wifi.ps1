param(
    [switch]$ApplyCloudflareDns
)

$ErrorActionPreference = "Stop"

# 1. Identificar adaptador Wi-Fi ativo (Intelbras / Realtek RTL8192EU)
$wifi = Get-NetAdapter | Where-Object {
    $_.Status -eq 'Up' -and ($_.Name -match 'Wi-Fi|Wireless' -or $_.InterfaceDescription -match 'Wireless|Wi-Fi|802\.11|RTL8192EU|Intelbras')
} | Select-Object -First 1

if (-not $wifi) {
    throw "Nenhum adaptador Wi-Fi ativo encontrado."
}

Write-Host "[INFO] Adaptador encontrado: $($wifi.Name) ($($wifi.InterfaceDescription))"
$guid = $wifi.InterfaceGuid

# 2. Desativar economia de energia do adaptador (PowerShell + PnPCapabilities = 24 no registro)
Disable-NetAdapterPowerManagement -Name $wifi.Name -ErrorAction SilentlyContinue
$netClass = "HKLM:\SYSTEM\CurrentControlSet\Control\Class\{4d36e968-e325-11ce-bfc1-08002be10318}"
$netClass4d36e972 = "HKLM:\SYSTEM\CurrentControlSet\Control\Class\{4d36e972-e325-11ce-bfc1-08002be10318}"
$nicKey = Get-ChildItem $netClass4d36e972 -ErrorAction SilentlyContinue | Where-Object {
    $_.PSChildName -match '^\d{4}$' -and (Get-ItemProperty $_.PSPath -Name NetCfgInstanceId -ErrorAction SilentlyContinue).NetCfgInstanceId -eq $guid
} | Select-Object -First 1

if ($nicKey) {
    # PnPCapabilities = 24 (0x18) desmarca "O computador pode desligar o dispositivo para economizar energia"
    New-ItemProperty -Path $nicKey.PSPath -Name "PnPCapabilities" -Value 24 -PropertyType DWord -Force | Out-Null
    Write-Host "[OK] Economia de energia desativada (PnPCapabilities = 24) em $($nicKey.PSChildName)"
}

# 3. Desativar USB Selective Suspend no plano de energia ativo (AC e DC)
powercfg -setacvalueindex SCHEME_CURRENT 2a737441-1930-4402-8d77-b2bebba308a3 48e6b7a6-50f5-4782-a5d4-53bb8f07e226 0
powercfg -setdcvalueindex SCHEME_CURRENT 2a737441-1930-4402-8d77-b2bebba308a3 48e6b7a6-50f5-4782-a5d4-53bb8f07e226 0
powercfg /setactive SCHEME_CURRENT
Write-Host "[OK] USB Selective Suspend desativado (0) no plano atual"

# 4. Reducao de latencia (Multimedia\SystemProfile)
$sysProf = "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile"
New-ItemProperty -Path $sysProf -Name "NetworkThrottlingIndex" -Value ([uint32]::MaxValue) -PropertyType DWord -Force | Out-Null
New-ItemProperty -Path $sysProf -Name "SystemResponsiveness" -Value 0 -PropertyType DWord -Force | Out-Null
Write-Host "[OK] NetworkThrottlingIndex = 0xffffffff e SystemResponsiveness = 0"

# 5. Desativar Algoritmo de Nagle na interface Wi-Fi ativa
$tcpIfPath = "HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters\Interfaces\$guid"
if (Test-Path $tcpIfPath) {
    New-ItemProperty -Path $tcpIfPath -Name "TcpAckFrequency" -Value 1 -PropertyType DWord -Force | Out-Null
    New-ItemProperty -Path $tcpIfPath -Name "TCPNoDelay" -Value 1 -PropertyType DWord -Force | Out-Null
    Write-Host "[OK] Algoritmo de Nagle desativado (TcpAckFrequency=1, TCPNoDelay=1) em $guid"
}

# 6. Propriedades avancadas do adaptador (Roaming / QoS)
$roamProp = Get-NetAdapterAdvancedProperty -Name $wifi.Name -ErrorAction SilentlyContinue | Where-Object { $_.DisplayName -match 'Roam' -or $_.RegistryKeyword -match 'Roam' }
if ($roamProp) {
    Set-NetAdapterAdvancedProperty -Name $wifi.Name -RegistryKeyword $roamProp.RegistryKeyword -RegistryValue 1 -ErrorAction SilentlyContinue
    Write-Host "[OK] Roaming ajustado para minimo"
} else {
    Write-Host "[INFO] Driver Realtek RTL8192EU nao expoe Roaming Aggressiveness via Set-NetAdapterAdvancedProperty; garantindo WlanSvc em Automatico."
}
Set-Service -Name "WlanSvc" -StartupType Automatic -ErrorAction SilentlyContinue

# 7. DNS Cloudflare (opcional, somente se confirmado)
if ($ApplyCloudflareDns) {
    Set-DnsClientServerAddress -InterfaceAlias $wifi.Name -ServerAddresses @("1.1.1.1", "1.0.0.1")
    Write-Host "[OK] DNS do Wi-Fi alterado para Cloudflare (1.1.1.1 / 1.0.0.1)"
} else {
    Write-Host "[INFO] DNS atual do Wi-Fi mantido sem alteracao."
}

Write-Host "`nConcluido!"
