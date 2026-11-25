param(
    [switch]$DisableHibernate,
    [switch]$DefragHDD
)

$ErrorActionPreference = "Continue"

# 1. Garantir TRIM ativo no sistema
Write-Host "=== 1. TRIM ==="
fsutil behavior set DisableDeleteNotify 0

# 2. Detectar SSDs vs HDs mecanicos e mapear letras de unidade
Write-Host "`n=== 2. OTIMIZACAO DE VOLUMES ==="
$partitions = Get-Partition | Where-Object { $_.DriveLetter }
foreach ($p in $partitions) {
    $phys = Get-PhysicalDisk | Where-Object { $_.DeviceId -eq $p.DiskNumber } | Select-Object -First 1
    $drive = $p.DriveLetter
    if ($phys.MediaType -eq 'SSD') {
        Write-Host "[SSD] Executando ReTrim em ${drive}: ($($phys.FriendlyName))..."
        Optimize-Volume -DriveLetter $drive -ReTrim -Verbose
    } elseif ($phys.MediaType -eq 'HDD') {
        if ($DefragHDD) {
            Write-Host "[HDD] Executando Defrag em ${drive}: ($($phys.FriendlyName))..."
            Optimize-Volume -DriveLetter $drive -Defrag -Verbose
        } else {
            Write-Host "[HDD] ${drive}: ($($phys.FriendlyName)) ignorado (DefragHDD nao solicitado)."
        }
    } else {
        Write-Host "[INFO] ${drive}: MediaType=$($phys.MediaType) - ignorado."
    }
}

# 3. Evitar suspensao dos discos por inatividade
Write-Host "`n=== 3. DISK TIMEOUT ==="
powercfg /change disk-timeout-ac 0
powercfg /change disk-timeout-dc 0
Write-Host "[OK] disk-timeout-ac e disk-timeout-dc definidos para 0 (nunca suspender discos)."

# 4. Hibernacao (opcional)
Write-Host "`n=== 4. HIBERFIL.SYS ==="
if ($DisableHibernate) {
    powercfg -h off
    Write-Host "[OK] Hibernacao desativada (hiberfil.sys removido)."
} else {
    Write-Host "[INFO] Hibernacao mantida sem alteracao."
}

# 5. Limpeza segura de arquivos temporarios (ignorando em uso)
Write-Host "`n=== 5. LIMPEZA DE TEMPORARIOS ==="
$targets = @(
    $env:TEMP,
    "C:\Windows\Temp",
    "C:\Windows\SoftwareDistribution\Download"
)
foreach ($t in $targets) {
    if (Test-Path $t) {
        $before = (Get-ChildItem $t -Recurse -Force -ErrorAction SilentlyContinue | Measure-Object -Property Length -Sum).Sum
        Get-ChildItem $t -Force -ErrorAction SilentlyContinue | Remove-Item -Recurse -Force -ErrorAction SilentlyContinue
        $after = (Get-ChildItem $t -Recurse -Force -ErrorAction SilentlyContinue | Measure-Object -Property Length -Sum).Sum
        $freedMB = [math]::Round(($before - $after) / 1MB, 2)
        Write-Host "[OK] Limpeza em ${t}: ~${freedMB} MB liberados (arquivos em uso ignorados)."
    }
}

Write-Host "`nConcluido!"
