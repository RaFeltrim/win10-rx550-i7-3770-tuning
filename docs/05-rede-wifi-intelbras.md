# 05 — Otimização de Rede e Wi-Fi 2.4GHz (Intelbras / Realtek RTL8192EU)

## 1. Diagnóstico Inicial

- **Adaptador**: `Realtek RTL8192EU Wireless LAN 802.11n USB 2.0 Network Adapter` (`300 Mbps`, GUID `{44F1EA76-C7A2-4F9A-93D6-3028F2DA4203}`).
- **Gargalo encontrado**: `Suspensão seletiva USB` estava **ativada (`0x00000001`)** no plano *Desempenho Máximo*, e `NetworkThrottlingIndex` estava em `10` (`0xA`).
- **Propriedades avançadas**: O driver `RTL8192EU` expõe apenas `Bandwidth` (`20_40MHz`), `QoS Support` (`Auto`) e `Wireless Mode` (`802.11b/g/n`), não expondo *Roaming Aggressiveness*.

## 2. Otimizações Aplicadas ([otimizar_wifi.ps1](../scripts/network/otimizar_wifi.ps1))

1. **Economia de energia do adaptador**: `Disable-NetAdapterPowerManagement` + `PnPCapabilities = 24` na subchave `0001` (`{4d36e972-e325-11ce-bfc1-08002be10318}`).
2. **USB Selective Suspend**: desativado (`0`) em AC e DC no plano atual via `powercfg`.
3. **MMCSS / Latência de Rede**: `NetworkThrottlingIndex = 0xFFFFFFFF` (`[uint32]::MaxValue`) e `SystemResponsiveness = 0`.
4. **Algoritmo de Nagle desativado**: `TcpAckFrequency = 1` e `TCPNoDelay = 1` na interface `{44F1EA76-C7A2-4F9A-93D6-3028F2DA4203}`.
5. **DNS Cloudflare**: alterado de `192.168.3.1` para `1.1.1.1` / `1.0.0.1`.
6. **Serviço `WlanSvc`**: garantido em `Automatic`.

## 3. Reversão

```powershell
reg import "C:\Backup_Otimizacao\backup_wifi_tcpip.reg"
Set-DnsClientServerAddress -InterfaceAlias "Wi-Fi" -ResetServerAddresses
reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile" /v NetworkThrottlingIndex /t REG_DWORD /d 10 /f
reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile" /v SystemResponsiveness /t REG_DWORD /d 20 /f
```
