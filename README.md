# OpenFOAM Real-Time Convergence Monitor App (MATLAB)

This MATLAB app provides a graphical interface to **monitor and plot solver residuals, Courant numbers, and maximum temperature** from a live OpenFOAM log file in real time.

---

## Features

- **User-friendly GUI** to select  
  • log file path  
  • fields to monitor (e.g. `Ux, Uy, h, OH, CO2, O2`)  
  • number of recent time steps to display  
  • auto‑reset interval  
- **Plots residuals for any user‑selected fields**; **always** shows max temperature & Courant (mean / max).  
- **Automatic live updating** while your simulation runs.  
- Periodic self‑reset to keep MATLAB memory usage low.  
- Works with serial or parallel OpenFOAM logs (standard format).

---

## How to Use

### 1  Prerequisites

| Requirement | 					Version 				|
|-------------|---------------------------------------------|
| MATLAB      | R2020b or newer 							|
| OpenFOAM    | tested with v2412 reactingFOAM with PIMPLE	|
| ---- Running simulation that writes a log file 	   ---- |

---

### 2  Prepare Your Log File

Redirect your solver output to a file **accessible to MATLAB**:

```bash
mpirun -np 12 reactingFoam -parallel     > "/path/to/your/log.reactingFoam" 2>&1
```

#### WSL (Windows Subsystem for Linux) users
If MATLAB cannot read a log stored inside your Linux home directory, redirect the log to a Windows‑visible path (e.g. on `C:`):

```bash
mpirun -np 12 reactingFoam -parallel     > "/mnt/c/Users/<WindowsUser>/Desktop/log.reactingFoam" 2>&1
```

---

### 3  Run the MATLAB App

1. Download `openFoamConvergenceMonitor.m`.
2. In MATLAB, run

   ```matlab
   openFoamConvergenceMonitor.m
   ```

3. In the GUI  
   • Browse to your **log file**  
   • Enter **fields** to monitor (comma‑separated)  
   • Set **PlotSteps** and **ResetInterval** if desired  
   • Click **Start Monitoring**

4. A maximized figure window opens and updates live.  
5. Stop anytime by closing the plot window or pressing **Ctrl + C** in MATLAB.

---

## Tips

- **PlotSteps** → how many latest time steps are shown.  
- **ResetInterval** → how many refresh cycles (each ≈20 s) before the monitor restarts to free memory.  
- Works with any OpenFOAM solver log that prints residuals and Courant numbers in standard format.

---

## Contributing

Issues, feature requests and pull‑requests are welcome!

---

## Example Log Snippet

```text
DILUPBiCGStab:  Solving for Ux, Initial residual = 0.0142847, Final residual = 7.35e-08, No Iterations 2
DILUPBiCGStab:  Solving for h,  Initial residual = 2.16e-05, Final residual = 8.91e-08, No Iterations 1
...
min/max(T) = 293, 2563.0
Courant Number mean: 0.00983 max: 0.04324
Time = 0.0063605
```

The app extracts these diagnostics automatically and plots them.

---

## Credits

Developed by *Sarvagya Sharma* (IISc Bangalore) with interactive GUI refinements using **OpenAI ChatGPT**.
