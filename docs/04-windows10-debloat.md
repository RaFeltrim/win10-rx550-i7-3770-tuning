# 04 — Debloat Seguro do Windows 10 (`Raphire/Win11Debloat`)

## 1. Estratégia e Compatibilidade

Apesar do nome, o repositório [Raphire/Win11Debloat](https://github.com/Raphire/Win11Debloat) suporta oficialmente **Windows 10 e Windows 11**. Os parâmetros foram auditados diretamente em `Win11Debloat.ps1` e `Config/Apps.json` antes da execução para garantir:

- **Remoção**: Cortana (`Microsoft.549981C3F5F10`) e apps promocionais padrão (`SelectedByDefault = True`).
- **Preservação**: **Microsoft Store** (`Microsoft.WindowsStore`), **Xbox Game Bar** (`Microsoft.XboxGamingOverlay`, `XboxGameOverlay`, `XboxIdentityProvider`, `Xbox.TCUI`), **suporte a impressoras** e **OneDrive** (`SelectedByDefault = False`).
- **Privacidade & Interface**: Telemetria, sugestões, Bing no menu Iniciar, anúncios no Edge, dicas na tela de bloqueio, sugestões na Store e recomendações do Iniciar desativados.

## 2. Comando Executado

```powershell
powershell -ExecutionPolicy Bypass -File "$env:TEMP\Win11Debloat\Win11Debloat-master\Win11Debloat.ps1" `
  -Silent -SkipRegistryBackup -RemoveApps `
  -DisableTelemetry -DisableSuggestions -DisableBing `
  -DisableEdgeAds -DisableLockscreenTips -DisableStoreSearchSuggestions `
  -DisableStartRecommended
```

## 3. Verificação Pós-Execução

- `Microsoft.549981C3F5F10` (Cortana): removida.
- `Microsoft.WindowsStore`: preservada.
- `C:\Windows\SysWOW64\OneDriveSetup.exe`: preservado.
- Arquivos temporários em `%TEMP%\Win11Debloat*` removidos ao final.
