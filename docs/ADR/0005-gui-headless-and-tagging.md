# ADR 0005 – GUI Headless Mode and Tagging Conventions

## Status
Accepted

## Context
Automated testing requires a graphical interface that can operate without opening a visible window.  Moreover, programmatic access to UI controls necessitates stable identifiers.  The GUI previously existed as a script with hard‑coded callbacks and no support for headless operation.

## Decision

* **App class**: The GUI is implemented as a `matlab.apps.AppBase` class in `+wrappers/@OptimizationGUI/OptimizationGUI.m`.  A thin wrapper function `wrappers.optimizationGUI` instantiates the class.
* **Headless mode**: The constructor accepts an `opts` struct with a `Visible` field.  Passing `struct('Visible','off')` hides the figure, allowing UITest and CI runs to exercise the GUI logic without rendering.
* **Tagging**: All interactive controls (`uieditfield`, `uidropdown`, `uifigure` etc.) are assigned a `Tag` property.  These tags are used by tests and the `Load Preset` mechanism to locate controls reliably.  Tags follow the naming convention used in earlier test suites (e.g. `FunctionField`, `SolveButton`).
* **Load preset**: A `Load Preset…` button was added.  It invokes `loadPresetCallback`, which calls `loadPreset(app,filename)`.  The latter loads a struct from a MAT file and assigns each field to the control whose `Tag` matches the field name.  In headless mode the callback does nothing; tests may call `app.loadPreset(filename)` directly.

## Consequences

The GUI is fully testable via `matlab.uitest.TestCase` and integrates with the problem library through presets.  Future tabs and controls must adhere to the established tagging scheme.  When adding controls, developers should extend the `findComponentByTag` helper to include them so presets continue to function.