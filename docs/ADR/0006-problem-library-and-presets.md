# ADR 0006 – Problem Library and Presets

## Status
Accepted

## Context
The Numerical Optimisation and Control (NOC) course includes a sequence of homework problems.  To support reproducible exercises and automated grading, each problem must be represented formally, tested programmatically and configured easily through the GUI.

## Decision

* **Structured specs**: Each homework is represented by a YAML file under `docs/Problems/Pi.yaml`.  The schema includes an identifier, objective, variables, constraints, data (expressions, initial guesses), expected outcomes, tolerances, solver mapping and notes.  These files are human‑readable and traceable back to the original assignments.
* **Automated tests**: For every problem spec there is a corresponding `tests/problems/test_Pi.m` file.  These tests read the YAML via a simple parser (`readProblemSpec`) and dispatch to the appropriate solver (e.g. `opt.root`, `opt.lineSearch`, `fminsearch` for `fmincon` problems).  They assert that the solution matches the expected value or satisfies feasibility within the prescribed tolerance.
* **GUI presets**: Each problem includes a `.mat` file under `wrappers/presets/Pi.mat` containing a struct whose fields map to the GUI control tags.  The GUI’s “Load Preset…” button and the `loadPreset` method populate the controls from these presets, enabling users to set up a problem with one click.

## Consequences

The repository now hosts a reusable library of optimisation problems.  Instructors or users can add new problems by writing a YAML spec, a test file and a preset.  The test suite will automatically execute new problems when placed under `tests/problems`.  The GUI becomes a teaching tool where students can load a preset and experiment with solver settings.  Maintaining the parser and presets requires care: changes to control names or solver interfaces must be reflected in both the specs and the preset files.