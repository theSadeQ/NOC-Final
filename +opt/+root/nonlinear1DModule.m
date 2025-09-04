function nonlinear1DModule()
%NONLINEAR1DMODULE  Demonstration of 1-D root finding.
%   NONLINEAR1DMODULE() solves a sample nonlinear equation using
%   Newton's method and reports the result.  Future versions can be
%   extended to prompt the user for custom functions and methods.

    opt.utils.printHeader('Nonlinear 1‑D Module');
    % Sample function: x^3 - 2*x + 1; derivative 3*x^2 - 2
    f = @(x) x.^3 - 2*x + 1;
    df = @(x) 3*x.^2 - 2;
    x0 = 0;
    [x, info] = opt.root.newtonMethod(f, df, x0, struct('tol', 1e-8, 'maxIter', 20));
    if info.converged
        fprintf('Found approximate root: x = %.6f after %d iterations (|f(x)|=%.3e)\n', x, info.iterations, abs(info.fval));
    else
        fprintf('Did not converge. Last iterate: x = %.6f, f(x)=%.3e\n', x, info.fval);
    end
end