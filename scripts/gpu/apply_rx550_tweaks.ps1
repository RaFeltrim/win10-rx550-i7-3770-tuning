$ErrorActionPreference = "Continue"
$log = "C:\GPU_Otimizacao\apply_log.txt"
"=== Aplicacao de Tweaks RX 550 - $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss') ===" | Out-File $log -Encoding UTF8

$target = "HKLM:\SYSTEM\CurrentControlSet\Control\Class\{4d36e968-e325-11ce-bfc1-08002be10318}\0000"
if (-not (Test-Path $target)) {
    "ERRO: Chave $target nao encontrada!" | Tee-Object -FilePath $log -Append
    exit 1
}

$dwords = @{
    # Telemetria / UI
    "ReportAnalytics" = 0
    "NotifySubscription" = 0
    "AllowSubscription" = 0
    "ShowReleaseNotes" = 0

    # Stutter / Latencia / FBC
    "StutterMode" = 0
    "KMD_EnableAmdFendrOptions" = 0
    "KMD_ChillEnabled" = 0
    "KMD_DeLagEnabled" = 1
    "KMD_FramePacingSupport" = 0
    "KMD_RadeonBoostEnabled" = 0
    "DalDisableStutter" = 1
    "DisableBlockWrite" = 1
    "DisableFBCSupport" = 1
    "DisableFBCForFullScreenApp" = 1

    # Performance 3D e Deep Sleep (PP_ThermalAutoThrottlingEnable OMITIDO por seguranca!)
    "PP_Force3DPerformanceMode" = 1
    "PP_ForceHighDPMLevel" = 1
    "PP_SclkDeepSleepDisable" = 1
    "PP_GfxOffControl" = 0
    "PP_EnableRaceToIdle" = 0

    # ULPS
    "EnableUlps" = 0
    "PP_DisableULPS" = 1
    "KMD_EnableULPS" = 0
    "KMD_ForceD3ColdSupport" = 0

    # ASPM no Driver
    "EnableAspmL0s" = 0
    "EnableAspmL1" = 0
    "EnableAspmL1SS" = 0
    "DisableAspmL0s" = 1
    "DisableAspmL1" = 1

    # Clock Gating
    "DisableGfxClockGating" = 1
    "DisableVceClockGating" = 1
    "DisableSamuClockGating" = 1
    "DisableRomMGCGClockGating" = 1
    "DisableGfxCoarseGrainClockGating" = 1
    "DisableGfxMediumGrainClockGating" = 1
    "DisableGfxFineGrainClockGating" = 1
    "DisableHdpMGClockGating" = 1
    "EnableVceSwClockGating" = 0
    "EnableUvdClockGating" = 0
    "EnableGfxClockGatingThruSmu" = 0
    "EnableSysClockGatingThruSmu" = 0
    "DisableXdmaSclkGating" = 1
    "DalFineGrainClockGating" = 0
    "DisableRomMediumGrainClockGating" = 1
    "DisableNbioMediumGrainClockGating" = 1
    "DisableMcMediumGrainClockGating" = 1
    "IRQMgrDisableIHClockGating" = 1

    # Power Gating
    "DisableGfxMGLS" = 1
    "DisableHdpClockPowerGating" = 1
    "DisableUVDPowerGating" = 1
    "DisableVCEPowerGating" = 1
    "DisableAcpPowerGating" = 1
    "DisableDrmdmaPowerGating" = 1
    "DisableGfxCGPowerGating" = 1
    "DisableStaticGfxMGPowerGating" = 1
    "DisableDynamicGfxMGPowerGating" = 1
    "DisableCpPowerGating" = 1
    "DisableGDSPowerGating" = 1
    "DisableXdmaPowerGating" = 1
    "DisableGFXPipelinePowerGating" = 1
    "DisableQuickGfxMGPowerGating" = 1
    "DisablePowerGating" = 1
    "SMU_DisableMmhubPowerGating" = 1
    "SMU_DisableAthubPowerGating" = 1

    # Display / Spread Spectrum
    "DalForceMaxDisplayClock" = 1
    "DalDisableClockGating" = 1
    "DalDisableDeepSleep" = 1
    "DalDisableDiv2" = 1
    "EnableSpreadSpectrum" = 0
    "EnableVcePllSpreadSpectrum" = 0
}

foreach ($kv in $dwords.GetEnumerator()) {
    New-ItemProperty -Path $target -Name $kv.Key -Value $kv.Value -PropertyType DWord -Force | Out-Null
}
New-ItemProperty -Path $target -Name "EnableUlps_NA" -Value "0" -PropertyType String -Force | Out-Null
"Aplicados $($dwords.Count + 1) valores em $target" | Tee-Object -FilePath $log -Append

# Shader Cache ativo em UMD
$umdPath = "$target\UMD"
if (Test-Path $umdPath) {
    New-ItemProperty -Path $umdPath -Name "ShaderCache" -Value ([byte[]](0x32, 0x00)) -PropertyType Binary -Force | Out-Null
    "ShaderCache configurado em $umdPath (32 00)" | Tee-Object -FilePath $log -Append
}

# MPO Fix (DWM)
$dwmPath = "HKLM:\SOFTWARE\Microsoft\Windows\Dwm"
New-ItemProperty -Path $dwmPath -Name "OverlayTestMode" -Value 5 -PropertyType DWord -Force | Out-Null
"OverlayTestMode = 5 aplicado em $dwmPath" | Tee-Object -FilePath $log -Append

# Servicos AMD Crash Defender / Log
$svcNames = @("AMD Crash Defender Service", "amdfendr", "amdfendrmgr", "amdlog")
foreach ($s in $svcNames) {
    $svcReg = "HKLM:\SYSTEM\CurrentControlSet\Services\$s"
    if (Test-Path $svcReg) {
        New-ItemProperty -Path $svcReg -Name "Start" -Value 4 -PropertyType DWord -Force | Out-Null
        "Servico $s definido para Start=4 (Desativado)" | Tee-Object -FilePath $log -Append
    }
}
Stop-Service -Name "AMD Crash Defender Service" -Force -ErrorAction SilentlyContinue

# Reiniciar driver de video (GPU PNP)
"Reiniciando driver de video..." | Tee-Object -FilePath $log -Append
pnputil /restart-device "PCI\VEN_1002&DEV_699F&SUBSYS_0B041002&REV_C7\4&10698843&0&0008" 2>&1 | Tee-Object -FilePath $log -Append
"Concluido!" | Tee-Object -FilePath $log -Append
