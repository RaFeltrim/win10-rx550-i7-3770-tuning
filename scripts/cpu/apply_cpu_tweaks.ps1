$ErrorActionPreference = "Continue"
$log = "C:\CPU_Otimizacao\apply_cpu_log.txt"
"=== Otimizacao CPU i7-3770 - $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss') ===" | Out-File $log -Encoding UTF8

# 1. Ponto de Restauracao (caso ainda nao tenha sido criado hoje)
try {
    Enable-ComputerRestore -Drive "C:\" -ErrorAction SilentlyContinue
    Checkpoint-Computer -Description "Pre-Otimizacao-i7-3770" -RestorePointType "MODIFY_SETTINGS" -ErrorAction Stop
    "Ponto de Restauracao 'Pre-Otimizacao-i7-3770' criado." | Tee-Object -FilePath $log -Append
} catch {
    "Aviso Ponto de Restauracao: $($_.Exception.Message)" | Tee-Object -FilePath $log -Append
}

# 2. Plano de Energia "Desempenho Maximo" (Ultimate Performance) + Core Parking 0%
$dupOut = powercfg -duplicatescheme e9a42b02-d5df-448d-aa00-03f14749eb61 2>&1 | Out-String
if ($dupOut -match "([0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12})") {
    $ultGuid = $matches[1]
    powercfg /setactive $ultGuid
    "Plano Desempenho Maximo ativado: $ultGuid" | Tee-Object -FilePath $log -Append
} else {
    "Aviso ao duplicar Ultimate Performance: $dupOut" | Tee-Object -FilePath $log -Append
}

# Desativar Core Parking (CPMINCORES = 100) e fixar Min/Max Processor State = 100%
powercfg -attributes SUB_PROCESSOR CPMINCORES -ATTRIB_HIDE 2>$null
powercfg -setacvalueindex SCHEME_CURRENT SUB_PROCESSOR CPMINCORES 100
powercfg -setdcvalueindex SCHEME_CURRENT SUB_PROCESSOR CPMINCORES 100
powercfg -setacvalueindex SCHEME_CURRENT SUB_PROCESSOR PROCTHROTTLEMIN 100
powercfg -setdcvalueindex SCHEME_CURRENT SUB_PROCESSOR PROCTHROTTLEMIN 100
powercfg -setacvalueindex SCHEME_CURRENT SUB_PROCESSOR PROCTHROTTLEMAX 100
powercfg -setdcvalueindex SCHEME_CURRENT SUB_PROCESSOR PROCTHROTTLEMAX 100
powercfg /setactive SCHEME_CURRENT
"Core Parking desativado (CPMINCORES=100) e Min/Max CPU = 100%." | Tee-Object -FilePath $log -Append

# 3. Mitigacoes Spectre / Meltdown (FeatureSettingsOverride = 3, Mask = 3)
$memReg = "HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management"
New-ItemProperty -Path $memReg -Name "FeatureSettingsOverride" -Value 3 -PropertyType DWord -Force | Out-Null
New-ItemProperty -Path $memReg -Name "FeatureSettingsOverrideMask" -Value 3 -PropertyType DWord -Force | Out-Null
"Spectre/Meltdown desativados (FeatureSettingsOverride=3, FeatureSettingsOverrideMask=3)." | Tee-Object -FilePath $log -Append

# 4. Compressao de Memoria e MMCSS (SystemResponsiveness = 10 + Games priority)
$mm = Get-MMAgent
"Status MemoryCompression antes: $($mm.MemoryCompression)" | Tee-Object -FilePath $log -Append
if ($mm.MemoryCompression) {
    Disable-MMAgent -MemoryCompression
    "MemoryCompression desativada via Disable-MMAgent." | Tee-Object -FilePath $log -Append
}

$sysProf = "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile"
New-ItemProperty -Path $sysProf -Name "SystemResponsiveness" -Value 10 -PropertyType DWord -Force | Out-Null
$gamesProf = "$sysProf\Tasks\Games"
if (Test-Path $gamesProf) {
    New-ItemProperty -Path $gamesProf -Name "GPU Priority" -Value 8 -PropertyType DWord -Force | Out-Null
    New-ItemProperty -Path $gamesProf -Name "Priority" -Value 6 -PropertyType DWord -Force | Out-Null
    New-ItemProperty -Path $gamesProf -Name "Scheduling Category" -Value "High" -PropertyType String -Force | Out-Null
    New-ItemProperty -Path $gamesProf -Name "SFIO Priority" -Value "High" -PropertyType String -Force | Out-Null
}
"MMCSS ajustado: SystemResponsiveness=10 e perfil Games=High." | Tee-Object -FilePath $log -Append

# 5. Verificacao de HPET (useplatformclock)
$bcd = bcdedit /enum "{current}" 2>&1 | Out-String
if ($bcd -match "useplatformclock\s+Yes") {
    bcdedit /deletevalue useplatformclock | Out-Null
    "HPET forcado (useplatformclock Yes) detectado e removido." | Tee-Object -FilePath $log -Append
} else {
    "HPET (useplatformclock) nao estava forcado no BCD; mantido padrao TSC." | Tee-Object -FilePath $log -Append
}

"Concluido! Reinicie o Windows para aplicar todas as alteracoes." | Tee-Object -FilePath $log -Append
