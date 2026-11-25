# 03 — Otimização da CPU e Memória (Intel Core i7-3770 · Ivy Bridge)

## 1. Diagnóstico Inicial

- **CPU**: Intel Core i7-3770 (`3.40 GHz` base / `3.90 GHz` Turbo, `4C/8T`) em placa-mãe ASUS P8H61-M LE/BR com `16 GB` DDR3-1600 Dual Channel.
- **Baseline CPU-Z Bench (v17.01.64)**: Single Thread `373.4` · Multi Thread `1813.9`.
- **Estado Inicial**: Plano *Alto desempenho*, `SystemResponsiveness = 20`, `FeatureSettingsOverride` ausente (mitigações Spectre/Meltdown ativas por software em Ivy Bridge), `MemoryCompression` já desativada (`False`), `useplatformclock` (HPET) não forçado.

## 2. Otimizações Aplicadas ([apply_cpu_tweaks.ps1](../scripts/cpu/apply_cpu_tweaks.ps1))

1. **Plano de Energia "Desempenho Máximo" + Core Parking 0%**:
   - Duplicado e ativado o esquema oculto `Ultimate Performance` (`e9a42b02-d5df-448d-aa00-03f14749eb61`).
   - `CPMINCORES = 100`, `PROCTHROTTLEMIN = 100`, `PROCTHROTTLEMAX = 100`.
2. **Mitigações Spectre / Meltdown (`FeatureSettingsOverride = 3`)**:
   - Em `HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management`: `FeatureSettingsOverride = 3` e `FeatureSettingsOverrideMask = 3`.
   - *Contexto*: Ivy Bridge não possui mitigação em hardware (eIBRS); desativar KVA Shadowing / Retpoline reduz overhead de syscalls em jogos, assumindo o trade-off de segurança de um PC doméstico de jogos.
3. **MMCSS (`SystemProfile` & `Tasks\Games`)**:
   - `SystemResponsiveness = 10` (posteriormente ajustado para `0` na etapa de rede).
   - `Tasks\Games`: `GPU Priority = 8`, `Priority = 6`, `Scheduling Category = "High"`, `SFIO Priority = "High"`.

## 3. Resultados Medidos (CPU-Z Bench)

- **Single Thread**: `373.4` → **`388.2`** (**`+3,96%`**)
- **Multi Thread**: `1813.9` → `1793.9` (`-1,10%`, variação normal pós-boot / limite de TDP do VRM H61)

## 4. Reversão

```powershell
reg import "C:\CPU_Otimizacao\backup_cpu_mem.reg"
powercfg /setactive 8c5e7fda-e8bf-4a96-9a85-a6e23a8c635c
reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile" /v SystemResponsiveness /t REG_DWORD /d 20 /f
```
