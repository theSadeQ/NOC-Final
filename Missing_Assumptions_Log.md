# Assumptions Register (MATLAB Optimization)
_Last updated: 2025-09-04_

## Summary
This register records only active uncertainties and known gaps.  Implemented facts are promoted to decisions and captured in ADRs.  Each assumption has an owner, an assessed risk and an exit criterion for removal.

## Decisions
- **D1 – Exception for singular Jacobians:** The line search solver throws `opt:lineSearch:singularJ` when the Jacobian is ill‑conditioned (rcond below `singularityTol`).  Strong Wolfe conditions are supported with defaults `c1=1e‑4`, `c2=0.9`.
- **D2 – GUI availability:** A class-based GUI (`wrappers.OptimizationGUI`) provides tabs for root solving, line search, barrier demo, simple `fmincon` and a lunar collocation example.  It supports headless operation via `Visible='off'` and all controls use stable `Tag` names.
- **D3 – Namespace layout:** All public sources reside under `+opt/*` and `+wrappers/*`; no duplicate top-level packages exist.  The deprecated `info.stepSize` alias is maintained but documented as deprecated.

### Module defaults
| Module        | Parameters (default values)                            |
|---------------|--------------------------------------------------------|
| **Root**      | `tol=1e-10`, `maxIter=50`                             |
| **Line search** | `tol=1e-8`, `maxIter=50`, `alpha=0.25`, `beta=0.5`, `singularityTol=1e-12`, `c1=1e-4`, `c2=0.9` |

## Active Assumptions

| ID | Owner | Risk | Exit criteria | Evidence |
|----|-------|------|---------------|----------|
| **A1 – Barrier/QP first scenario** | Maintainer | Low | Define and implement a minimal quadratic program (e.g. 2×2 QP with linear inequality) so that `activeSetQP` returns a meaningful solution. | Stub functions `+opt/+barrier/activeSetQP.m` and `barrierMethodModule.m` are placeholders; tests assert `NOT_IMPLEMENTED`. |
| **A2 – Optimal-control demo** | Maintainer | Low | Provide a formal problem statement for the lunar landing/collocation example and implement a minimal numeric solver (or remove the demo). | `lunarLandingModule.m` and `collocationModule.m` are stubs; current GUI uses a toy placeholder. |
| **A3 – Expression parsing security** | Maintainer | Medium | Replace the current `eval`/`str2func` parsing with a safe expression parser or whitelist; document trusted input assumptions. | Expression fields in GUI and tests assume user‑provided expressions are trusted and syntactically valid MATLAB. |

## Known invariants
- Error identifiers follow the pattern `opt:<module>:<name>`.
- The repository targets MATLAB R2021b+ and uses no additional toolboxes.
- GUI uses MATLAB `uifigure`/`uitab` components exclusively.

## Security note
Users enter MATLAB expressions directly into GUI fields and YAML specs.  The system currently trusts these inputs.  A future release will include a safer parser to mitigate arbitrary code execution risks (see A3).

## Traceability
- **Problems**: see `docs/Problems/Pi.yaml` for problem statements and presets.
- **Tests**: see `tests/problems/test_Pi.m` for automated validation.  Code coverage is reported in `tests/coverage.xml`.
- **ADRs**: see `docs/ADR/0004-error-policy-and-defaults.md`, `docs/ADR/0005-gui-headless-and-tagging.md`, and `docs/ADR/0006-problem-library-and-presets.md` for the decisions behind error policy, GUI conventions and the problem library.