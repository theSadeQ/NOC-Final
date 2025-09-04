# ADR 0004 – Error Policy and Solver Defaults

## Status
Accepted

## Context
The optimisation suite includes several numerical solvers with configurable tolerances and step control parameters.  A clear error‑handling policy and consistent default values are needed to ensure predictable behaviour and testability.

## Decision

* **Throw vs. warn**: Functions throw `MException`s when they encounter unrecoverable numerical issues (e.g. singular Jacobians).  Named warnings are used only for benign issues such as a zero slope in the secant method (`opt:root:secant:ZeroSlope`).  Test code suppresses these warnings when necessary.
* **Defaults**: Root solvers default to `tol = 1e-10` and `maxIter = 50`.  The line‑search solver uses `tol = 1e-8`, `maxIter = 50`, `alpha = 0.25`, `beta = 0.5`, `singularityTol = 1e-12` for Jacobian checks, and (for strong Wolfe) `c1 = 1e-4`, `c2 = 0.9`.  These values are suitable for homework‑scale problems.
* **Deprecations**: The `info.stepSize` field returned by `newtonSystemArmijo` is retained for backward compatibility but is marked as deprecated in the function help text.  Users should rely on `info.step` instead.

## Consequences

The test suite can assert specific error IDs and rely on deterministic defaults.  Future work to harden the secant solver may upgrade warnings to exceptions in strict modes (see assumption A3).  Changing default tolerances will require updates to this ADR and corresponding tests.