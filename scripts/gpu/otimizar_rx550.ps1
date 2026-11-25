# Otimizacao segura para Radeon RX 550 (Polaris 12 / Lexa) - Windows 10
$ErrorActionPreference = "Stop"

# 1. Localizar dinamicamente a subchave da GPU AMD e desativar ULPS
$classPath = "HKLM:\SYSTEM\CurrentControlSet\Control\Class\{4d36e968-e325-11ce-bfc1-08002be10318}"
$gpuKey = Get-ChildItem $classPath -ErrorAction SilentlyContinue | Where-Object {
    $_.PSChildName -match '^\d{4}$' -and (
        (Get-ItemProperty $_.PSPath -Name ProviderName -ErrorAction SilentlyContinue).ProviderName -match 'Advanced Micro Devices' -or
        (Get-ItemProperty $_.PSPath -Name DriverDesc -ErrorAction SilentlyContinue).DriverDesc -match 'Radeon|RX'
    )
} | Select-Object -First 1

if (-not $gpuKey) {
    throw "Nenhuma GPU AMD encontrada em $classPath"
}

New-ItemProperty -Path $gpuKey.PSPath -Name "EnableUlps" -Value 0 -PropertyType DWord -Force | Out-Null
New-ItemProperty -Path $gpuKey.PSPath -Name "EnableUlps_NA" -Value "0" -PropertyType String -Force | Out-Null
Write-Host "[OK] ULPS desativado em $($gpuKey.PSChildName)"

# 2. Desativar MPO no DWM (estabilidade de frametime em GPUs Polaris)
$dwmPath = "HKLM:\SOFTWARE\Microsoft\Windows\Dwm"
New-ItemProperty -Path $dwmPath -Name "OverlayTestMode" -Value 5 -PropertyType DWord -Force | Out-Null
Write-Host "[OK] MPO desativado (OverlayTestMode = 5)"

# 3. Verificar plano de energia (manter Desempenho Maximo ou ativar Alto Desempenho)
$activeScheme = (powercfg /getactivescheme) | Out-String
if ($activeScheme -match 'Desempenho M|Ultimate Performance|Alto desempenho|High performance') {
    Write-Host "[OK] Plano de energia mantido: $($activeScheme.Trim())"
} else {
    powercfg /setactive 8c5e7fda-e8bf-4a96-9a85-a6e23a8c635c
    Write-Host "[OK] Plano de energia alterado para Alto Desempenho"
}

# 4. Prioridade de jogos no MMCSS (mantendo Fullscreen Optimizations / Flip Model padrao)
$gamesPath = "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\Games"
if (Test-Path $gamesPath) {
    New-ItemProperty -Path $gamesPath -Name "GPU Priority" -Value 8 -PropertyType DWord -Force | Out-Null
    New-ItemProperty -Path $gamesPath -Name "Priority" -Value 6 -PropertyType DWord -Force | Out-Null
    New-ItemProperty -Path $gamesPath -Name "Scheduling Category" -Value "High" -PropertyType String -Force | Out-Null
    New-ItemProperty -Path $gamesPath -Name "SFIO Priority" -Value "High" -PropertyType String -Force | Out-Null
    Write-Host "[OK] Prioridade MMCSS Games ajustada (GPU Priority=8, Priority=6, High)"
}

Write-Host "`nConcluido! Reinicie o Windows para aplicar todas as alteracoes."
