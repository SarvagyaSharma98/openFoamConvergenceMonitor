Real-Time OpenFOAM Residual Monitor (MATLAB)
--------------------------------------------

This MATLAB script monitors an OpenFOAM log file in real time and plots residuals, Courant numbers, and max temperature. It is designed to work with transient, PIMPLE-based solvers like `reactingFoam`.

--------------------------------------------
Quick Start
--------------------------------------------

1. Run your OpenFOAM case with this command:

   nohup mpirun --oversubscribe -np 12 reactingFoam -parallel > log.reactingFoam 2>&1 &

2. Edit the `residualMonitor.m` script in MATLAB:

   - Set the full path to your OpenFOAM log file:
     logFile = 'C:\\Path\\to\\log.reactingFoam';

   - Set how many recent time steps to display:
     PlotSteps = 250;

3. Run the script in MATLAB:
   It will update every ~20 seconds. Use Ctrl+C to stop.

--------------------------------------------
Example Compatible Log Snippet
--------------------------------------------

Make sure your log file contains lines similar to the following:

Courant Number mean: 0.0177023 max: 0.123183
Time = 0.002251

DILUPBiCGStab:  Solving for Ux, Initial residual = 0.00473474, Final residual = 1.98e-07, No Iterations 1
DILUPBiCGStab:  Solving for Uy, Initial residual = 0.00468016, Final residual = 1.16e-07, No Iterations 1
DILUPBiCGStab:  Solving for CH4, Initial residual = 3.62e-05, Final residual = 2.28e-07, No Iterations 1
DILUPBiCGStab:  Solving for OH, Initial residual = 3.02e-05, Final residual = 6.05e-07, No Iterations 1
DILUPBiCGStab:  Solving for CO, Initial residual = 8.30e-05, Final residual = 9.07e-07, No Iterations 1
DILUPBiCGStab:  Solving for h, Initial residual = 2.41e-05, Final residual = 3.96e-07, No Iterations 1
min/max(T) = 293, 2773.05

The script extracts and plots:
- Initial and final residuals for each field
- Mean and maximum Courant numbers
- Maximum temperature in the domain

--------------------------------------------
Requirements
--------------------------------------------

- MATLAB R2020b or later (for `tiledlayout`)
- OpenFOAM log file from a PIMPLE-based transient solver like reactingFoam
- Standard field names: Ux, Uy, p, T, OH, CO, h (you can edit the `fields` array in the script if needed)

--------------------------------------------
Troubleshooting
--------------------------------------------

• If the script shows no data:
  - Check that your log file path is correct.
  - Make sure the file includes lines for Time, residuals, Courant number, and temperature.

• If you use a different solver:
  - This script expects the default OpenFOAM logging format.
  - It may not work with steady-state solvers, or solvers with custom log messages.

This script is shared to help the OpenFOAM community. Suggestions welcome.
