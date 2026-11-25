# 01 — Segurança, Pontos de Restauração e Backups

Antes de alterar qualquer registro crítico do Windows, driver de vídeo ou política de energia, foram aplicados os seguintes procedimentos de segurança e reversibilidade.

## 1. Privilégios e Ponto de Restauração

- Todos os scripts que alteram `HKLM` ou configurações de energia exigem **PowerShell como Administrador**.
- Comando para criação de Ponto de Restauração:

```powershell
Enable-ComputerRestore -Drive "C:\"
Checkpoint-Computer -Description "Pre-Otimizacao-Sistema" -RestorePointType "MODIFY_SETTINGS"
```

> **Nota sobre o limite de 24 horas do Windows:** Por padrão, o Windows permite criar apenas 1 Ponto de Restauração a cada 1440 minutos (24h). Caso já exista um ponto recente, o comando retorna aviso sem impedir o restante do fluxo.

## 2. Backups de Registro Exportados

Os backups locais (não versionados no Git por conterem metadados específicos da máquina, conforme `.gitignore`) são salvos em `C:\GPU_Otimizacao\`, `C:\CPU_Otimizacao\` e `C:\Backup_Otimizacao\`:

| Escopo | Chave de Registro | Arquivo Local |
| :--- | :--- | :--- |
| **GPU / Vídeo** | `HKLM\SYSTEM\CurrentControlSet\Control\Class\{4d36e968-e325-11ce-bfc1-08002be10318}` | `backup_gpu.reg` / `backup_video.reg` |
| **CPU / Memória** | `HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management` | `backup_cpu_mem.reg` |
| **Interface Wi-Fi TCP/IP** | `HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters\Interfaces\{GUID}` | `backup_wifi_tcpip.reg` |

## 3. Reversão Completa via Backup

```cmd
reg import "C:\Backup_Otimizacao\backup_video.reg"
reg import "C:\CPU_Otimizacao\backup_cpu_mem.reg"
reg import "C:\Backup_Otimizacao\backup_wifi_tcpip.reg"
```
