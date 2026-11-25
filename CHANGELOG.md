# Changelog

Todas as alterações notáveis deste repositório estão documentadas abaixo, seguindo o padrão [Conventional Commits](https://www.conventionalcommits.org/).

## [1.0.0] - 2026-11-24

### Adicionado
- **GPU (RX 550 4GB Polaris 12)**: scripts `apply_rx550_tweaks.ps1` e `otimizar_rx550.ps1`, leitor ADL (`adl_read.cs`) e benchmark OpenGL (`gpu_bench.cs`), com ganho medido de `+177,2%` em FPS médio e `+240,8%` em 1% Low após ajustes e OC `1205/1698 MHz`.
- **CPU (Core i7-3770 Ivy Bridge)**: script `apply_cpu_tweaks.ps1` com plano *Desempenho Máximo*, Core Parking desativado, `FeatureSettingsOverride = 3` e MMCSS Games (`+3,96%` em Single Thread no CPU-Z Bench).
- **Debloat Windows 10**: documentação de execução segura via `Raphire/Win11Debloat` preservando Store, Xbox Game Bar, impressoras e OneDrive.
- **Rede Wi-Fi (Realtek RTL8192EU)**: script `otimizar_wifi.ps1` desativando `USB Selective Suspend`, `PnPCapabilities = 24`, Algoritmo de Nagle, `NetworkThrottlingIndex = 0xFFFFFFFF` e DNS Cloudflare.
- **Armazenamento (3x SSDs)**: script `otimizar_discos.ps1` com TRIM ativo, `ReTrim` em `C:`, `D:` e `E:`, `disk-timeout = 0`, `powercfg -h off` e limpeza de `~805,22 MB`.
- **CI & Governança**: workflow GitHub Actions para validação de sintaxe PowerShell e integridade de documentação, além de `LICENSE` (MIT) e template de PR.
