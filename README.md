<div align="center">

# ⚡ Windows 10 Gaming Tuning — RX 550 & Core i7-3770

### *Otimização de Performance, Latência, Rede e Armazenamento · Hardware Legado & Entrada · 2026*

[![Windows 10 Pro](https://img.shields.io/badge/Windows%2010-Pro%2022H2-0078D6?style=for-the-badge&logo=windows)](https://www.microsoft.com/)
[![AMD Radeon RX 550](https://img.shields.io/badge/GPU-RX%20550%204GB%20Polaris-ED1C24?style=for-the-badge&logo=amd)](https://www.amd.com/)
[![Intel Core i7-3770](https://img.shields.io/badge/CPU-Core%20i7--3770%20Ivy%20Bridge-0071C5?style=for-the-badge&logo=intel)](https://www.intel.com/)
[![CI Validation](https://img.shields.io/badge/CI-PowerShell%20Lint-2ea44f?style=for-the-badge&logo=githubactions)](./.github/workflows/ci.yml)
[![License MIT](https://img.shields.io/badge/License-MIT-8A2BE2?style=for-the-badge)](./LICENSE)
[![Autor Rafael Feltrim](https://img.shields.io/badge/Autor-Rafael%20Feltrim-0A66C2?style=for-the-badge)](https://github.com/RaFeltrim)

<p align="center">
  <strong>Repositório completo de auditoria, scripts PowerShell reversíveis, benchmarks reais (antes vs. depois) e documentação técnica para extração máxima de desempenho e estabilidade em Windows 10 Pro (Build 19045) com Radeon RX 550 4GB (Polaris 12 / Lexa) e Intel Core i7-3770 (Ivy Bridge).</strong>
</p>

[Hardware Alvo](#-hardware-e-ambiente) •
[Estrutura](#-estrutura-do-repositório) •
[Resultados Medidos](#-resultados-reais-antes-vs-depois) •
[Repositórios Base](#-repositórios-de-referência) •
[Como Usar](#-como-usar-com-segurança) •
[Reversão](#-reversão)

</div>

---

## 📌 Hardware e Ambiente

| Componente | Especificação Verificada |
| :--- | :--- |
| **Sistema Operacional** | Microsoft Windows 10 Pro (`10.0.19045`, Build `19045`) |
| **Processador (CPU)** | Intel Core i7-3770 (`4C/8T`, `3.40 GHz` base / `3.90 GHz` Turbo, Ivy Bridge) |
| **Placa-Mãe & Memória** | ASUS P8H61-M LE/BR · `16 GB` DDR3-1600 Dual Channel |
| **Placa de Vídeo (GPU)** | AMD Radeon RX 550 4GB (`VEN_1002&DEV_699F`, Polaris 12 / Lexa, `PCIe x8 3.0`, Driver `31.0.21925.1001` / Adrenalin `26.5.2`) |
| **Rede Wi-Fi** | Adaptador USB Intelbras / `Realtek RTL8192EU Wireless LAN 802.11n USB 2.0` (`300 Mbps`) |
| **Armazenamento** | 3x SSDs SATA (`X12 SSD 240GB` `C:`, `Reeinno ST960GB S7S3` `D:`, `KINGSTON SV300S37A240G` `E:`) |

---

## 🗂️ Estrutura do Repositório

```text
win10-rx550-i7-3770-tuning/
│
├── 📁 .github/
│   ├── PULL_REQUEST_TEMPLATE.md            # Checklist padrão para PRs
│   └── 📁 workflows/
│       └── ci.yml                          # Validação de sintaxe PowerShell e integridade de docs
│
├── 📁 docs/                                # Documentação detalhada por módulo
│   ├── 01-seguranca-e-backups.md           # Pontos de restauração, backups .reg e regras de segurança
│   ├── 02-gpu-rx550-polaris.md             # Tweaks Polaris/Lexa, MPO, ShaderCache e Overclock
│   ├── 03-cpu-i7-3770-ivy-bridge.md        # Plano Desempenho Máximo, Core Parking e Spectre/Meltdown
│   ├── 04-windows10-debloat.md             # Debloat seguro via Raphire/Win11Debloat
│   ├── 05-rede-wifi-intelbras.md           # Nagle, USB Selective Suspend, PnPCapabilities e DNS
│   └── 06-armazenamento-ssds.md            # TRIM, ReTrim nos 3 SSDs, Hibernação e limpeza
│
├── 📁 benchmarks/                          # Logs brutos e metodologia de medição
│   ├── README.md                           # Metodologia OpenGL + ADL e CPU-Z Bench
│   ├── baseline-rx550.txt                  # Coleta inicial (Antes)
│   └── after-rx550.txt                     # Coleta pós-otimização (Depois)
│
├── 📁 scripts/                             # Scripts PowerShell e ferramentas C# (.NET/ADL)
│   ├── README.md                           # Guia de execução dos scripts
│   ├── 📁 gpu/
│   │   ├── apply_rx550_tweaks.ps1          # Tweaks completos Polaris/Lexa (70 DWORDs + DWM + Serviços)
│   │   ├── otimizar_rx550.ps1              # Script enxuto (ULPS + MPO + Energia + MMCSS)
│   │   ├── adl_read.cs                     # Leitor de telemetria via atiadlxx.dll (ADL)
│   │   └── gpu_bench.cs                    # Benchmark OpenGL + coletor ADL integrado
│   ├── 📁 cpu/
│   │   └── apply_cpu_tweaks.ps1            # Plano Ultimate, Core Parking, Mitigações e MMCSS
│   ├── 📁 network/
│   │   └── otimizar_wifi.ps1               # Otimização Realtek RTL8192EU, Nagle e DNS Cloudflare
│   └── 📁 storage/
│       └── otimizar_discos.ps1             # TRIM, ReTrim em SSDs, Disk Timeout e limpeza
│
├── .gitattributes                          # Normalização de fim de linha e Linguist
├── .gitignore                              # Exclusão de backups locais (.reg, .log, .exe)
├── LICENSE                                 # Licença MIT
└── README.md                               # Visão geral e mapa de resultados
```

---

## 📊 Resultados Reais (Antes vs. Depois)

### GPU — Radeon RX 550 4GB (Benchmark OpenGL `gpu_bench.exe`)

| Métrica | Baseline (60s) | Tweaks Stock (60s) | Tweaks + OC `1205/1698` (15s) | Ganho Total |
| :--- | :---: | :---: | :---: | :---: |
| **RAM Processos AMD (Idle)** | `41,59 MB` | `23,61 MB` | `23,61 MB` | **`-43,2%`** |
| **Clock GPU (Médio / Máx)** | `561 / 716 MHz` | `1071 / 1071 MHz` | **`1205 / 1205 MHz`** | **`+114,8%`** no clock médio |
| **Clock Memória (Médio / Máx)** | `1478 / 1500 MHz` | `1500 / 1500 MHz` | **`1698 / 1698 MHz`** | **`+14,9%`** |
| **FPS Médio** | `212,92 FPS` | `539,72 FPS` (`+153,5%`) | **`590,30 FPS`** | **`+177,2%`** |
| **1% Low FPS** | `58,73 FPS` | `150,90 FPS` (`+156,9%`) | **`200,16 FPS`** | **`+240,8%`** |
| **Frametime Médio / P99** | `4,70 ms / 14,47 ms` | `1,85 ms / 4,92 ms` | **`1,69 ms / 4,41 ms`** | **`-64,0%` / `-69,5%`** |
| **Temperatura Máxima** | `59,0 °C` | `66,0 °C` | `72,0 °C` | Segura (`< 75 °C`) |

### CPU — Intel Core i7-3770 (CPU-Z Bench v17.01.64)

| Métrica | Antes | Depois | Variação |
| :--- | :---: | :---: | :---: |
| **Single Thread** | `373.4` | **`388.2`** | **`+3,96%`** (`+14.8 pts`) |
| **Multi Thread** | `1813.9` | `1793.9` | `-1,10%` *(variação normal / limite TDP H61)* |

### Armazenamento & Rede
- **SSDs**: `ReTrim` executado em `C:` (`135,62 GB`), `D:` (`514,20 GB`) e `E:` (`188,78 GB`); **`~805,22 MB`** liberados em temporários.
- **Rede Wi-Fi**: `USB Selective Suspend` desativado (`0`), `PnPCapabilities = 24`, Nagle desativado (`TcpAckFrequency = 1`, `TCPNoDelay = 1`), `NetworkThrottlingIndex = 0xFFFFFFFF`, `SystemResponsiveness = 0`, DNS Cloudflare (`1.1.1.1` / `1.0.0.1`).

---

## 🔗 Repositórios de Referência

- [imribiy/amd-gpu-tweaks](https://github.com/imribiy/amd-gpu-tweaks) — DWORDs de registro AMD (aplicados com omissão de `PP_ThermalAutoThrottlingEnable = 0` por segurança térmica).
- [GSDragoon/RadeonSoftwareSlimmer](https://github.com/GSDragoon/RadeonSoftwareSlimmer) — Referência para limpeza de serviços e telemetria AMD.
- [amitxv/PC-Tuning](https://github.com/amitxv/PC-Tuning) & [ChrisTitusTech/winutil](https://github.com/ChrisTitusTech/winutil) — Referências para plano *Ultimate Performance*, Core Parking, MMCSS e HPET.
- [Raphire/Win11Debloat](https://github.com/Raphire/Win11Debloat) — Debloat seguro compatível com Windows 10 preservando Microsoft Store, Xbox Game Bar, impressoras e OneDrive.

---

## 🚀 Como Usar com Segurança

1. Leia primeiro [01-seguranca-e-backups.md](./docs/01-seguranca-e-backups.md) e crie um **Ponto de Restauração** + exportação de registro antes de qualquer alteração.
2. Execute os scripts sempre em um **PowerShell como Administrador** (e **reinicie o Windows** após alterar chaves de driver/kernel — nunca faça *hot-restart* de driver com `pnputil` após mudar chaves de DPM/Clock Gating).

---

## 🔄 Reversão

Todos os documentos em `docs/` contêm os comandos exatos para reverter cada alteração individualmente ou via `reg import` dos backups locais.

---

## 👤 Autor

**Rafael Feltrim** — [@RaFeltrim](https://github.com/RaFeltrim)
