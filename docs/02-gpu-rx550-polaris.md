# 02 — Otimização da GPU (AMD Radeon RX 550 4GB · Polaris 12 / Lexa)

## 1. Diagnóstico Inicial

- **Dispositivo**: `Radeon RX550/550 Series` (`PCI\VEN_1002&DEV_699F`, subchave `0000`)
- **Driver**: `31.0.21925.1001` (Adrenalin `26.5.2`)
- **Barramento PCIe**: `PCIe x8 3.0` (`MaxLinkSpeed = 3`, `MaxLinkWidth = 8`), com ASPM desligado no plano *Alto desempenho*.
- **Problema identificado no Baseline**: Mesmo com `100%` de carga OpenGL, o clock médio ficava em **`561 MHz`** (máximo `716 MHz`, muito abaixo dos `1071 MHz` nominais) devido ao gerenciamento agressivo de DPM, Deep Sleep e Clock/Power Gating, derrubando o `1% Low` para `58,73 FPS`.

## 2. Ajustes Aplicados ([apply_rx550_tweaks.ps1](../scripts/gpu/apply_rx550_tweaks.ps1))

Baseado em [imribiy/amd-gpu-tweaks](https://github.com/imribiy/amd-gpu-tweaks) (70 valores aplicados na subchave `\0000`):

- **ULPS desativado**: `EnableUlps = 0`, `EnableUlps_NA = "0"`, `PP_DisableULPS = 1`, `KMD_EnableULPS = 0`, `KMD_ForceD3ColdSupport = 0`.
- **Deep Sleep, Clock Gating & Power Gating**: `PP_SclkDeepSleepDisable = 1`, `PP_GfxOffControl = 0`, `PP_EnableRaceToIdle = 0`, `PP_Force3DPerformanceMode = 1`, `PP_ForceHighDPMLevel = 1`, `DalDisableDeepSleep = 1`, `DisableGfxClockGating = 1`, `DisablePowerGating = 1`, etc.
- **Latência & Stutter**: `KMD_DeLagEnabled = 1`, `StutterMode = 0`, `DalDisableStutter = 1`, `DisableFBCSupport = 1`.
- **Shader Cache**: `UMD\ShaderCache = 32 00` (`REG_BINARY`).
- **MPO (Multi-Plane Overlay) desativado**: `HKLM\SOFTWARE\Microsoft\Windows\Dwm\OverlayTestMode = 5`.
- **Telemetria & Serviços**: `ReportAnalytics = 0`, `NotifySubscription = 0`, `AllowSubscription = 0`, `ShowReleaseNotes = 0` e desativação de `AMD Crash Defender Service` / `amdfendr` / `amdfendrmgr` (`Start = 4`).
- **Segurança Térmica**: `PP_ThermalAutoThrottlingEnable = 0` foi **omitido intencionalmente** para preservar a proteção térmica da placa.

> **Lição aprendida (TDR Event 4101):** Reiniciar o driver "a quente" via `pnputil /restart-device` logo após gravar 70 chaves de DPM/Clock Gating provocou TDR (`amdwddmg` parou de responder). Após reinicialização limpa do Windows, o driver operou com **0 TDRs**. Por isso, [otimizar_rx550.ps1](../scripts/gpu/otimizar_rx550.ps1) não executa `pnputil` e recomenda reiniciar o Windows.

## 3. Overclock / Undervolt Seguro (MSI Afterburner)

Perfil validado na RX 550 4GB (memória Hynix):
- **Core Clock**: `1071 MHz` → **`1205 MHz`**
- **Memory Clock**: `1500 MHz` → **`1698 MHz`**
- **Power Limit**: **`+20%`**
- **Fan**: `86%` (temperatura máxima estabilizada em **`72,0 °C`** sob carga)

## 4. Reversão

```cmd
reg import "C:\GPU_Otimizacao\backup_gpu.reg"
reg delete "HKLM\SOFTWARE\Microsoft\Windows\Dwm" /v OverlayTestMode /f
sc config "AMD Crash Defender Service" start= auto
```
