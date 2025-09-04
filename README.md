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
* `optimizationGUI.m` – placeholder that prints a message.

Invoke them from MATLAB:

```matlab
run('wrappers/runHW2Console.m');
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

## Known Limitations

* Only the Newton and secant root solvers are fully implemented.  The
  line search, barrier and optimal control modules contain
  placeholders or very simple demonstrations.
* The GUI functionality is not implemented in this build; the
  wrapper prints a message instead.
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
