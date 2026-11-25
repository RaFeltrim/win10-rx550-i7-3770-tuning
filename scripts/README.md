# 🛠️ Scripts e Ferramentas

Todos os scripts PowerShell exigem **execução como Administrador**.

| Script | Escopo | Uso |
| :--- | :--- | :--- |
| [apply_rx550_tweaks.ps1](./gpu/apply_rx550_tweaks.ps1) | GPU RX 550 (70 DWORDs, ShaderCache, MPO, Crash Defender) | `powershell -ExecutionPolicy Bypass -File scripts\gpu\apply_rx550_tweaks.ps1` |
| [otimizar_rx550.ps1](./gpu/otimizar_rx550.ps1) | GPU RX 550 enxuto (ULPS, MPO, Energia, MMCSS) | `powershell -ExecutionPolicy Bypass -File scripts\gpu\otimizar_rx550.ps1` |
| [apply_cpu_tweaks.ps1](./cpu/apply_cpu_tweaks.ps1) | CPU i7-3770 (Ultimate, Core Parking, Mitigações, MMCSS) | `powershell -ExecutionPolicy Bypass -File scripts\cpu\apply_cpu_tweaks.ps1` |
| [otimizar_wifi.ps1](./network/otimizar_wifi.ps1) | Rede Wi-Fi (`-ApplyCloudflareDns` opcional) | `powershell -ExecutionPolicy Bypass -File scripts\network\otimizar_wifi.ps1 -ApplyCloudflareDns` |
| [otimizar_discos.ps1](./storage/otimizar_discos.ps1) | SSDs/HDs (`-DisableHibernate`, `-DefragHDD` opcionais) | `powershell -ExecutionPolicy Bypass -File scripts\storage\otimizar_discos.ps1 -DisableHibernate` |
| [adl_read.cs](./gpu/adl_read.cs) / [gpu_bench.cs](./gpu/gpu_bench.cs) | Leitor ADL e Benchmark OpenGL 3D | Compilar com `C:\Windows\Microsoft.NET\Framework64\v4.0.30319\csc.exe` |
