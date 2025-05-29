# OpenFOAM Real-Time Residual & Diagnostics Monitor (MATLAB)

This MATLAB script lets you monitor and plot solver residuals, Courant numbers, and max temperature from a live OpenFOAM log file in real time.

---

## How to Use

### 1. Prerequisites

- MATLAB R2020b or newer
- OpenFOAM 2412
- An OpenFOAM simulation that writes its log output to a file

---

### 2. Prepare Your Log File

Run your OpenFOAM simulation and **redirect the output to a log file** that MATLAB can access. For example:

```bash
mpirun --oversubscribe -np 12 reactingFoam -parallel > "/path/to/your/log.reactingFoam" 2>&1
```

- Make sure to choose a log file location accessible to both your simulation environment and MATLAB.

---

### 3. Set Up the MATLAB Script

- Download or clone this repository.
- Open `OpenFOAM_ConvergenceMonitor.m` in MATLAB.
- At the top of the script, set the path to your log file. Example:

  ```matlab
  logFile = "C:/path/to/your/log.reactingFoam";
  ```

- If needed, edit the list of fields you want to monitor:

  ```matlab
  fields = {'Ux', 'Uy', 'T', 'p', 'OH', 'CO', 'h'};
  ```

---

### 4. Run the Monitor

- In MATLAB, run the script `OpenFOAM_ConvergenceMonitor.m`.
- The script will read the log file and update the plots automatically as your simulation runs.
- To stop the monitoring, press `Ctrl+C` in MATLAB.

---

## Tips

- You can adjust the number of time steps shown or the reset interval at the top of the script.
- Works with any OpenFOAM solver log containing the standard residual and Courant number output.

---

## Contributing

Feedback, bug reports, and contributions are welcome. Open an issue or submit a pull request.

---

## Example OpenFOAM Log Output (Snippet)

Below is an example of the kind of residuals and diagnostic output that this monitor can parse and visualize:

```text
diagonal:  Solving for rho, Initial residual = 0, Final residual = 0, No Iterations 0
PIMPLE: iteration 1
DILUPBiCGStab:  Solving for Ux, Initial residual = 0.0142847, Final residual = 7.35416e-08, No Iterations 2
DILUPBiCGStab:  Solving for Uy, Initial residual = 0.0216794, Final residual = 9.15778e-08, No Iterations 2
DILUPBiCGStab:  Solving for CH4, Initial residual = 1.97167e-05, Final residual = 3.31333e-08, No Iterations 1
DILUPBiCGStab:  Solving for CH2O, Initial residual = 0.00079863, Final residual = 1.94924e-06, No Iterations 1
DILUPBiCGStab:  Solving for CH3O, Initial residual = 0.00244962, Final residual = 3.10595e-06, No Iterations 1
DILUPBiCGStab:  Solving for H, Initial residual = 0.000115838, Final residual = 5.3828e-07, No Iterations 1
DILUPBiCGStab:  Solving for O2, Initial residual = 1.92373e-05, Final residual = 4.35521e-08, No Iterations 1
DILUPBiCGStab:  Solving for H2, Initial residual = 9.20525e-05, Final residual = 3.16905e-07, No Iterations 1
DILUPBiCGStab:  Solving for O, Initial residual = 0.000117051, Final residual = 5.96407e-07, No Iterations 1
DILUPBiCGStab:  Solving for OH, Initial residual = 3.82386e-05, Final residual = 1.86038e-07, No Iterations 1
DILUPBiCGStab:  Solving for H2O, Initial residual = 1.92158e-05, Final residual = 3.99904e-08, No Iterations 1
DILUPBiCGStab:  Solving for HO2, Initial residual = 0.000934558, Final residual = 2.05239e-06, No Iterations 1
DILUPBiCGStab:  Solving for H2O2, Initial residual = 9.38797e-05, Final residual = 6.41068e-08, No Iterations 1
DILUPBiCGStab:  Solving for C, Initial residual = 0.00259645, Final residual = 1.28664e-05, No Iterations 1
DILUPBiCGStab:  Solving for CH, Initial residual = 0.00241996, Final residual = 1.15764e-05, No Iterations 1
DILUPBiCGStab:  Solving for CH2, Initial residual = 0.00191999, Final residual = 8.50137e-06, No Iterations 1
DILUPBiCGStab:  Solving for CH2(S), Initial residual = 0.00189574, Final residual = 8.56592e-06, No Iterations 1
DILUPBiCGStab:  Solving for CH3, Initial residual = 0.00112171, Final residual = 4.39442e-06, No Iterations 1
DILUPBiCGStab:  Solving for CO, Initial residual = 6.81727e-05, Final residual = 1.9205e-07, No Iterations 1
DILUPBiCGStab:  Solving for CO2, Initial residual = 1.7254e-05, Final residual = 4.68897e-08, No Iterations 1
DILUPBiCGStab:  Solving for HCO, Initial residual = 0.00156162, Final residual = 7.02798e-06, No Iterations 1
DILUPBiCGStab:  Solving for CH2OH, Initial residual = 0.00173894, Final residual = 7.83095e-06, No Iterations 1
DILUPBiCGStab:  Solving for CH3OH, Initial residual = 0.000496906, Final residual = 1.02062e-06, No Iterations 1
DILUPBiCGStab:  Solving for C2H, Initial residual = 0.00283463, Final residual = 1.28642e-05, No Iterations 1
DILUPBiCGStab:  Solving for C2H2, Initial residual = 0.00140552, Final residual = 4.32025e-06, No Iterations 1
DILUPBiCGStab:  Solving for C2H3, Initial residual = 0.00206157, Final residual = 7.65553e-06, No Iterations 1
DILUPBiCGStab:  Solving for C2H4, Initial residual = 0.000848503, Final residual = 1.92981e-06, No Iterations 1
DILUPBiCGStab:  Solving for C2H5, Initial residual = 0.00126327, Final residual = 3.71927e-06, No Iterations 1
DILUPBiCGStab:  Solving for C2H6, Initial residual = 0.000769116, Final residual = 1.28469e-06, No Iterations 1
DILUPBiCGStab:  Solving for HCCO, Initial residual = 0.00231234, Final residual = 9.50495e-06, No Iterations 1
DILUPBiCGStab:  Solving for CH2CO, Initial residual = 0.00098165, Final residual = 2.76783e-06, No Iterations 1
DILUPBiCGStab:  Solving for HCCOH, Initial residual = 0.0019713, Final residual = 6.95063e-06, No Iterations 1
DILUPBiCGStab:  Solving for N, Initial residual = 0.000182295, Final residual = 9.2372e-07, No Iterations 1
DILUPBiCGStab:  Solving for NH, Initial residual = 0.000350952, Final residual = 1.5658e-06, No Iterations 1
DILUPBiCGStab:  Solving for NH2, Initial residual = 0.00057108, Final residual = 2.33358e-06, No Iterations 1
DILUPBiCGStab:  Solving for NH3, Initial residual = 0.000345556, Final residual = 9.75144e-07, No Iterations 1
DILUPBiCGStab:  Solving for NNH, Initial residual = 0.000100214, Final residual = 4.54764e-07, No Iterations 1
DILUPBiCGStab:  Solving for NO, Initial residual = 1.38128e-05, Final residual = 6.68209e-08, No Iterations 1
DILUPBiCGStab:  Solving for NO2, Initial residual = 5.79542e-05, Final residual = 8.48699e-09, No Iterations 1
DILUPBiCGStab:  Solving for N2O, Initial residual = 3.69908e-05, Final residual = 7.73545e-08, No Iterations 1
DILUPBiCGStab:  Solving for HNO, Initial residual = 7.20878e-05, Final residual = 1.89312e-08, No Iterations 1
DILUPBiCGStab:  Solving for CN, Initial residual = 0.00182992, Final residual = 8.69294e-06, No Iterations 1
DILUPBiCGStab:  Solving for HCN, Initial residual = 0.000532245, Final residual = 2.11697e-06, No Iterations 1
DILUPBiCGStab:  Solving for H2CN, Initial residual = 7.81125e-05, Final residual = 3.45662e-08, No Iterations 1
DILUPBiCGStab:  Solving for HCNN, Initial residual = 0.00207555, Final residual = 9.56059e-06, No Iterations 1
DILUPBiCGStab:  Solving for HCNO, Initial residual = 0.000334563, Final residual = 1.15505e-06, No Iterations 1
DILUPBiCGStab:  Solving for HOCN, Initial residual = 0.0011487, Final residual = 5.07572e-06, No Iterations 1
DILUPBiCGStab:  Solving for HNCO, Initial residual = 0.000173066, Final residual = 5.09636e-07, No Iterations 1
DILUPBiCGStab:  Solving for NCO, Initial residual = 0.00144398, Final residual = 6.48686e-06, No Iterations 1
DILUPBiCGStab:  Solving for AR, Initial residual = 0, Final residual = 0, No Iterations 0
DILUPBiCGStab:  Solving for C3H7, Initial residual = 0.00187764, Final residual = 3.60004e-06, No Iterations 1
DILUPBiCGStab:  Solving for C3H8, Initial residual = 0.000763546, Final residual = 1.22472e-06, No Iterations 1
DILUPBiCGStab:  Solving for CH2CHO, Initial residual = 0.00262041, Final residual = 5.0892e-06, No Iterations 1
DILUPBiCGStab:  Solving for CH3CHO, Initial residual = 0.000892941, Final residual = 2.51193e-06, No Iterations 1
DILUPBiCGStab:  Solving for h, Initial residual = 2.16365e-05, Final residual = 8.90937e-08, No Iterations 1
limitTemperature=limitT, Type=Lower, LimitedCells=0, CellsPercent=0, Tmin=200, UnlimitedTmin=300.276
limitTemperature=limitT, Type=Upper, LimitedCells=0, CellsPercent=0, Tmax=2990, UnlimitedTmax=2563.01
min/max(T) = 293, 2562.97
DICPCG:  Solving for p, Initial residual = 0.00685302, Final residual = 0.000255, No Iterations 9
diagonal:  Solving for rho, Initial residual = 0, Final residual = 0, No Iterations 0
time step continuity errors : sum local = 4.13719e-06, global = -1.54003e-07, cumulative = 0.0463341
DICPCG:  Solving for p, Initial residual = 0.000260087, Final residual = 8.44157e-07, No Iterations 21
diagonal:  Solving for rho, Initial residual = 0, Final residual = 0, No Iterations 0
time step continuity errors : sum local = 1.37008e-08, global = -8.38916e-10, cumulative = 0.0463341
ExecutionTime = 250.51 s  ClockTime = 232 s

Courant Number mean: 0.00983524 max: 0.0432442
Time = 0.0063605
```
