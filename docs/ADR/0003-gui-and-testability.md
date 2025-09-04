## ADR‑0003: GUI and Testability Decisions

*Status: accepted*

## Context

The optimisation package originated from teaching scripts that were primarily interactive.  To support automated testing and continuous integration, the application needed a way to bypass interactive prompts.  Additionally, a graphical user interface (GUI) was out of scope for the initial MVP, but the codebase should leave room for a future GUI without hindering testability.

## Decision

* The function `opt.OptimizationApp` accepts an optional argument `'skip'`.  When this argument is provided the application prints a header and returns immediately, enabling smoke tests to run without waiting for user input.
* The wrapper `wrappers/optimizationGUI.m` remains a placeholder and simply prints a message indicating that the GUI is unavailable in this build.  No `uifigure` or graphical components are created at this time.
* Test files call `opt.OptimizationApp('skip')` and verify that no errors are thrown; the absence of a GUI means tests can run in headless CI environments.
* Future GUI development should live in a separate package or class to avoid polluting core logic; any UI calls must be wrapped so they can be disabled or mocked during testing.

## Consequences

* Non‑interactive execution through the `'skip'` flag allows the entire application to be exercised in CI without user intervention.  This pattern can be extended to other functions requiring user input.
* Deferring GUI implementation keeps the codebase lightweight and reduces maintenance burden.  When a GUI is eventually added, it should be accompanied by automated GUI tests and remain separable from core computation.
* Developers are reminded to design APIs that accept optional configuration structures so that user interface choices can be decoupled from algorithmic behaviour.