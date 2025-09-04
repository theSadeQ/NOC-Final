# Missing Assumptions Log

During the construction of this MATLAB MVP the chat export did not
provide complete implementation details for every module.  The
following assumptions were made:

1. **Default options for solvers** – When `opts` is missing or does
   not specify certain fields, the solvers use a tolerance of
   `1e‑10` and a maximum of 50 iterations.  These values were
   selected as reasonable defaults for homework problems.

2. **Armijo line search** – A simple backtracking strategy was
   implemented that reduces the step length by a factor of 0.5 until
   the squared norm of the residual decreases.  More sophisticated
   Wolfe conditions are deferred to future work.

3. **Placeholder barrier and QP methods** – The barrier method and
   active set QP solver are represented by stub functions that
   announce they are unimplemented.  The chat export did not supply
   sufficient detail to reimplement these algorithms.

4. **Optimal control modules omitted** – The lunar landing and
   collocation modules are stubs that print messages.  Without
   detailed problem specifications these solvers could not be
   reconstructed.

5. **GUI unavailability** – No MATLAB GUI is included in this build.
   The wrapper `optimizationGUI.m` prints a placeholder message
   indicating that the GUI is unavailable.

6. **Non‑interactive tests** – To enable automated testing, the
   application accepts an optional argument `'skip'`.  When provided,
   `opt.OptimizationApp` immediately returns without entering an
   interactive menu loop.