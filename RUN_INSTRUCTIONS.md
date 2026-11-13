# Running the MATLAB Project

## Requirements

- MATLAB R2025a with Signal Processing Toolbox.
- The submitted `run_project.m`, `project_config.m`, `+e5305/`, and `data/` must retain their relative folder structure.
- Keep the `+` in the folder name `+e5305`.

## Run

1. Download the repository and extract the files.
2. Open MATLAB.
3. Set **Current Folder** to the directory containing `run_project.m` and `project_config.m`. The `+e5305/` and `data/` folders must be in that same directory.
4. Enter this command in the MATLAB Command Window:

```matlab
[metrics, summary] = run_project;
```

5. Wait until the Command Window displays `Saved results to ...`.

With the supplied default configuration, the experiment evaluates three speech pairs, four angular separations, three input SNRs, and eight outputs per scene. It produces 288 rows in `metrics` and aggregated scores in `summary`.

## Outputs

The program automatically creates `results_final/` beside `run_project.m`.

| Location inside `results_final/` | Contents |
|---|---|
| `metrics_per_condition.csv` | Evaluation scores for each scene and method |
| `metrics_summary.csv` | Aggregated evaluation scores |
| `figures/` | Result plots, spectrograms and mask visualisations |
| `audio/` | Input mixture, separated signals and spatially re-mixed audio |

Running the program again replaces output files with the same names. No separate demonstration or validation script is needed to run this command.
