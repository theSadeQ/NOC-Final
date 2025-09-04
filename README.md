# MATLAB Optimisation Package (MVP)

[![MATLAB CI](https://github.com/OWNER/REPO/actions/workflows/matlab-ci.yml/badge.svg)](https://github.com/OWNER/REPO/actions/workflows/matlab-ci.yml)

This repository provides a minimal, MATLAB‑only refactoring of a set of
nonlinear optimisation and optimal control scripts.  The goal is to
organise the code into packages (`+opt`, `+root`, `+lineSearch`,
`+barrier`, `+optimalControl`, `+utils`) and supply simple
implementations or stubs for the core algorithms.  A console‐based app
(`opt.OptimizationApp`) presents a menu for exploring the modules.

## Quickstart

### Requirements

* MATLAB R2021b or newer (no additional toolboxes required).

### Setup

1. Unzip the repository so that the folder `matlab-optimization` is on
   your MATLAB path.
2. In MATLAB, add the folder and its subfolders:

   ```matlab
   addpath(genpath('matlab-optimization'));
   ```

### Running the App

To launch the console menu:

```matlab
opt.OptimizationApp();
```

On startup the app prints a header and immediately returns.  Future
iterations will populate the menu with interactive choices.

### Running the Wrappers

The `wrappers` directory contains scripts to exercise specific
modules:

* `runHW2Console.m` – calls the line search demonstration.
* `runHW3Console.m` – calls the barrier method demo.
* `optimizationGUI.m` – thin wrapper that calls the package function `wrappers.optimizationGUI` to launch the GUI.

Invoke them from MATLAB:

```matlab
run('wrappers/runHW2Console.m');
run('wrappers/runHW3Console.m');
```

### GUI

An interactive graphical interface is available via the package function `wrappers.optimizationGUI`.  The GUI exposes the root solvers and system line‑search methods in two tabs.  To launch it interactively, simply call:

```matlab
app = wrappers.optimizationGUI;
```

This returns an object `app` that contains the `UIFigure` and the tagged controls used by the UI tests.  For automated testing or to run the GUI in a headless environment, you can hide the window by passing the `Visible` option:

```matlab
app = wrappers.optimizationGUI(struct('Visible','off'));
```

The GUI now exposes multiple solver demonstrations arranged in tabs:

* **Root** – enter a scalar function and (optionally) its derivative, select Newton or Secant, specify the initial guesses and tolerances, then press **Solve** to compute an approximate root.  The result label shows the root, residual and iteration count, and the history plot shows `|f(x_k)|`.
* **Line Search** – solve a two‑dimensional nonlinear system using a Newton step with either Armijo backtracking or strong Wolfe conditions.  Enter `F(v)`, its Jacobian `J(v)`, an initial guess vector, line search constants (`alpha`, `beta`, `c1`, `c2`) and the maximum iterations.  Press **Solve** to see the step size and residual history.
* **Barrier** – run a simple two‑dimensional inequality barrier method with fraction‑to‑boundary and Armijo/Wolfe line search on a merit function.  Press **Run Barrier** to perform outer μ loops and inner damped Newton steps.  The table lists iterations, barrier parameter and iterate values; the plot shows the feasible region and path.
* **fmincon** – specify a scalar objective `f(x)`, an initial guess vector and an inequality `c(x) <= 0` (optional).  The current implementation uses `fminsearch` with a penalty for constraint violations.  Press **Run** to optimise and view the result in the table; **Export** will write the result to a workspace variable.  Only the `'fminsearch'` algorithm is supported at this time.
* **Lunar** – demonstrate a toy collocation/shooting problem for lunar landing or re‑entry.  Select the number of segments `N` and choose whether to minimise **Time** or **Fuel**.  Press **Transcribe & Solve** to plot altitude, speed, thrust and mass profiles; the summary table reports the final time, fuel used, final mass and minimum altitude.  **Export** writes the summary to the workspace.

The GUI is toolbox‑free and uses standard `uifigure` controls.  All controls are assigned stable `Tag` properties so that they can be manipulated programmatically in tests.  For automated testing or CI runs you can hide the window by passing a struct with `Visible='off'`.
```

### Running the Tests

From MATLAB, execute all tests as follows:

```matlab
addpath(genpath('matlab-optimization'));
results = runtests('tests');
disp(table(results));
```

You should see all tests pass.  The test suite uses
`matlab.unittest` to verify the Newton root solver and performs a
smoke test on the application.

Test runs generate a Cobertura coverage report at `tests/coverage.xml`.
You can open this file with a coverage viewer or upload it to your
CI server.  The GitHub Actions workflow provided in this repository
will automatically upload the coverage XML as an artifact.

## CI

This repository includes a GitHub Actions workflow
(`.github/workflows/matlab-ci.yml`) that installs MATLAB, runs the
unit tests and uploads the coverage report as an artifact.  The
status badge above links to the latest run.

To run tests non‑interactively on your own machine via batch mode:

```bash
matlab -batch "addpath(genpath('matlab-optimization')); results = runtests('tests'); disp(table(results));"
```

## Project Docs

This project tracks architectural decisions and assumptions explicitly.  Refer to the following documents for further details:

* **Assumptions Register** – see [`Missing_Assumptions_Log.md`](Missing_Assumptions_Log.md) for current assumptions, open questions and next actions.
* **ADR 0002 – Solver Defaults and Errors** – see [`docs/ADR/0002-solver-defaults-and-errors.md`](docs/ADR/0002-solver-defaults-and-errors.md) for the rationale behind solver parameter defaults and error handling.
* **ADR 0003 – GUI and Testability** – see [`docs/ADR/0003-gui-and-testability.md`](docs/ADR/0003-gui-and-testability.md) for decisions on bypassing user interaction and deferring GUI development.
* **ADR 0004 – Error Policy and Defaults** – see [`docs/ADR/0004-error-policy-and-defaults.md`](docs/ADR/0004-error-policy-and-defaults.md) for the solver warning vs. error policy and default parameters.
* **ADR 0005 – GUI Headless and Tagging** – see [`docs/ADR/0005-gui-headless-and-tagging.md`](docs/ADR/0005-gui-headless-and-tagging.md) for headless GUI operation and tagging conventions.
* **ADR 0006 – Problem Library and Presets** – see [`docs/ADR/0006-problem-library-and-presets.md`](docs/ADR/0006-problem-library-and-presets.md) for how homeworks map to structured specs, tests and GUI presets.

## Known Limitations
## Problem Library

This repository includes a library of homework problems in `docs/Problems/P1.yaml` through `docs/Problems/P10.yaml`.  Each YAML file specifies the problem objective, variables, constraints, input data, expected result, tolerance and solver mapping.  A corresponding `.mat` preset exists under `wrappers/presets/Pi.mat` which can be loaded via the GUI.

To solve a problem programmatically, read the spec using `readProblemSpec` and call the appropriate solver:

```matlab
spec = readProblemSpec('docs/Problems/P3.yaml');
F = str2func(['@(v) ' spec.data.F_expr]);
J = str2func(['@(v) ' spec.data.J_expr]);
[x, info] = opt.lineSearch.newtonSystemArmijo(F,J,spec.data.x0_vec,struct('maxIter',50));
```

To load a preset in the GUI, click **Load Preset…** and select the desired `P?.mat` file (e.g. `wrappers/presets/P1.mat`).  In headless mode, call `app.loadPreset('wrappers/presets/P1.mat')` on an app instance created with `Visible='off'`.


* Only the Newton and secant root solvers are fully implemented.  The
  line search, barrier and optimal control modules contain
  placeholders or very simple demonstrations.
* A simple GUI is provided via `wrappers.optimizationGUI`.  Use the headless option for CI or automated testing.
* The command‐line interfaces prompt for user input only in
  rudimentary form; robust input parsing and error handling are TODO.

## Warnings

The secant solver emits the named warning `opt:root:secant:ZeroSlope`
when the finite difference slope vanishes during the iteration.  In
batch or CI environments you may wish to suppress this warning to
avoid cluttering the log:

```matlab
warning('off','opt:root:secant:ZeroSlope');
```

## Contributing

Contributions are welcome.  See the `Missing_Assumptions_Log.md` for
notes about assumptions and areas requiring clarification.  Please
ensure that any added MATLAB files remain within the package
structure and include unit tests when appropriate.
