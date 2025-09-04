## ADR‑0002: Solver Defaults and Error Handling

*Status: accepted*

## Context

The optimisation package includes several numerical routines for root finding and nonlinear equation solving.  These functions require stopping tolerances, maximum iteration counts and line‑search parameters.  They also need well‑defined behaviour when a Jacobian matrix becomes singular or ill‑conditioned.  During early development these values were hard‑coded or implicit, and error handling was ad‑hoc.  A recent feature pass introduced a robust set of defaults along with strong Wolfe line‑search support and explicit error identifiers.

## Decision

We standardise solver defaults across the repository and codify explicit error handling:

* Newton and secant solvers default to `tol = 1e‑10` and `maxIter = 50` when options are not provided.  These values are sufficiently tight for coursework problems while avoiding excessive iteration counts.
* The line‑search solver defaults to `alpha = 0.25`, `beta = 0.5` and a singularity tolerance `singularityTol = 1e‑12`.  It supports a strong Wolfe line search when `opts.wolfe` is true, with constants `c1 = 1e‑4` and `c2 = 0.9`.
* When the reciprocal condition number of the Jacobian (`rcond`) falls below `singularityTol` the solver throws an `MException` with identifier `opt:lineSearch:singularJ`.  This prevents misleading numerical results and allows calling code to handle failures explicitly.
* The secant solver detects a zero finite‑difference slope and emits a named warning `opt:root:secant:ZeroSlope`.  A warning is used instead of an exception so that the solver can gracefully terminate and return its last iterate; callers may choose to suppress or promote the warning.

These defaults and behaviours are tested under `tests/test_root_newtonMethod.m`, `tests/test_root_secantMethod.m`, `tests/test_lineSearch_newtonSystemArmijo.m`, `tests/test_lineSearch_wolfe.m` and `tests/test_root_solve1D.m`.

## Consequences

* Having centralised defaults simplifies solver configuration and test reproducibility.  Future changes to tolerances or Armijo constants need to update a single source and corresponding tests.
* Named error identifiers enable high‑level scripts (e.g. `opt.OptimizationApp`) to catch and report numerical issues cleanly.  Users can differentiate between singular Jacobian failures and convergence failures.
* Maintaining strong Wolfe support alongside Armijo backtracking increases flexibility but adds minor branching complexity.  Tests ensure both paths reduce residual norms and satisfy curvature conditions.
* The decision to issue a warning (rather than error) for zero secant slope reflects a compromise between robustness and backwards compatibility; revisiting this choice is listed as an open question in the Assumptions Register.