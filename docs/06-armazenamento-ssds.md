# 06 — Otimização de Armazenamento (3x SSDs SATA)

## 1. Inventário de Discos (`Get-PhysicalDisk`)

| Unidade | Modelo | Tipo | Tamanho | Espaço Otimizado (`ReTrim`) |
| :---: | :--- | :---: | :---: | :---: |
| **`C:`** | `X12 SSD 240GB` | SSD | `221,55 GB` | `135,62 GB` |
| **`D:`** | `Reeinno ST960GB S7S3` | SSD | `894,25 GB` | `514,20 GB` |
| **`E:`** | `KINGSTON SV300S37A240G` | SSD | `223,57 GB` | `188,78 GB` |

## 2. Otimizações Aplicadas ([otimizar_discos.ps1](../scripts/storage/otimizar_discos.ps1))

1. **TRIM ativo**: `fsutil behavior set DisableDeleteNotify 0` (NTFS e ReFS).
2. **`Optimize-Volume -ReTrim`**: executado apenas nas unidades SSD (sem desfragmentação mecânica desnecessária).
3. **Suspensão de disco desativada**: `powercfg /change disk-timeout-ac 0` e `disk-timeout-dc 0`.
4. **Hibernação desativada**: `powercfg -h off` (`hiberfil.sys` ausente).
5. **Limpeza de temporários (`~805,22 MB` liberados)**:
   - `%TEMP%`: `~772,02 MB`
   - `C:\Windows\Temp`: `~24,05 MB`
   - `C:\Windows\SoftwareDistribution\Download`: `~9,15 MB`

## 3. Reversão (se desejar reativar Hibernação)

```powershell
powercfg -h on
```
