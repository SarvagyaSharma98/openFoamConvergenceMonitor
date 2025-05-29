# OpenFOAM Real-Time Residual & Diagnostics Monitor (MATLAB)

This MATLAB script provides **real-time monitoring and plotting** of residuals, Courant numbers, and maximum temperature from a live OpenFOAM solver log file.

It is especially useful for OpenFOAM simulations where you redirect the output log file to a location accessible from both your OpenFOAM environment (e.g., WSL or Linux) and MATLAB.

## Features

- **Real-time Visualization:** Continuously plots residuals, Courant numbers, and max temperature.
- **User-friendly Configuration:** Easily select fields to monitor, plot settings, and log file paths.
- **Robust Error Handling:** Gracefully handles file read errors and missing data.
- **Modular & Extensible:** Clearly structured code for easy customization and extension.

---

## Getting Started

### Prerequisites

- MATLAB R2020b or newer (for optimal plotting and tiled layouts).
- An OpenFOAM simulation producing a log file.

### Setup

1. **Download or clone** this repository.
2. **Set the `logFile` variable** at the top of `OpenFOAM_ConvergenceMonitor.m` to the full path of your log file. For example:

   ```matlab
   logFile = "C:/path/to/your/log.reactingFoam";
   ```
   *(Use forward slashes `/` or double backslashes `\` for Windows paths.)*

3. **Optional:** Adjust the `fields` array in the script to match the variables you wish to monitor:
   ```matlab
   fields = {'Ux', 'Uy', 'T', 'p', 'OH', 'CO', 'h'};
   ```

---

## Running the Monitor

1. **Start your OpenFOAM simulation** and redirect the log output to a file, e.g.:
   ```bash
   mpirun --oversubscribe -np 12 reactingFoam -parallel > "/path/to/your/log.reactingFoam" 2>&1
   ```

2. **Run** the `OpenFOAM_ConvergenceMonitor.m` script in MATLAB.

3. The script will automatically update the plots in real time.

4. **To stop monitoring**, press `Ctrl+C` in the MATLAB command window.

---

## Recommended Workflow

- Run your simulation in WSL, Linux, or any platform.
- Redirect the OpenFOAM solver output to a log file accessible by MATLAB (e.g., in a shared folder).
- Monitor solver convergence live from MATLAB for immediate feedback.

---

## License

This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.

---

## Contributing

Contributions, bug reports, and suggestions are welcome!  
Please open an issue or submit a pull request.

