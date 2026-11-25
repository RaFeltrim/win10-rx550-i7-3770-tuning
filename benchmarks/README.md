# 📊 Benchmarks e Metodologia de Medição

## 1. Metodologia GPU (`gpu_bench.cs` + `atiadlxx.dll`)

Para evitar depender de suítes proprietárias pesadas, foi construído um benchmark OpenGL nativo em C# ([gpu_bench.cs](../scripts/gpu/gpu_bench.cs)) compilado via `csc.exe` (.NET Framework 4.x) que:

1. Renderiza 40 camadas de quads translúcidos em `1280x720` com VSync desligado (`wglSwapIntervalEXT(0)`) e `glFinish()`, estressando pixel fillrate/ROPs e shaders da RX 550.
2. Coleta telemetria em tempo real diretamente via **AMD Display Library (`atiadlxx.dll`)**: temperatura (`°C`), clock de GPU (`MHz`), clock de memória (`MHz`), carga (`%`) e velocidade do barramento PCIe (`MT/s`).
3. Calcula FPS médio, **1% Low FPS** (média do 1% de quadros mais lentos), frametime médio e P99.

## 2. Arquivos de Log

- [baseline-rx550.txt](./baseline-rx550.txt) — Execução de 60s antes dos tweaks (`212,92 FPS` médio, `58,73 FPS` 1% Low, clock médio `561 MHz`, `41,59 MB` RAM AMD).
- [after-rx550.txt](./after-rx550.txt) — Execução de 60s após tweaks e reboot (`539,72 FPS` médio, `150,90 FPS` 1% Low, clock cravado em `1071 MHz`, `23,61 MB` RAM AMD, `0` TDRs).
