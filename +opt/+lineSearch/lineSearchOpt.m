function lineSearchOpt()
%LINESEARCHOPT  Demonstrate a simple system solve using Newton/Armijo.
%   LINESEARCHOPT() solves a toy nonlinear system using
%   newtonSystemArmijo and displays the result.  This function can be
%   extended to support interactive examples.

    opt.utils.printHeader('Line Search Demo');
    % Define a simple nonlinear system F(x) = 0
    F = @(x) [x(1)^2 - 1; x(2) + 1];
    J = @(x) [2*x(1), 0; 0, 1];
    x0 = [2; -2];
    [x, info] = opt.lineSearch.newtonSystemArmijo(F, J, x0, struct('tol', 1e-8, 'maxIter', 20));
    if info.converged
        fprintf('Converged to solution x = [%.4f, %.4f] after %d iterations.\n', x(1), x(2), info.iterations);
    else
        fprintf('Did not converge. Last iterate x = [%.4f, %.4f], residual norm = %.3e\n', x(1), x(2), info.residualNorm);
    end
end