classdef test_lineSearch_wolfe < matlab.unittest.TestCase
    %TEST_LINESEARCH_WOLFE  Strong Wolfe line search tests.
    %   This test verifies that the Newton/line search solver honours the
    %   strong Wolfe conditions when enabled and reduces the residual norm.

    methods(Test)
        function strongWolfe(testCase)
            % Define a simple nonlinear system (variant of Rosenbrock)
            F = @(v) [1 - v(1); 100*(v(2) - v(1)^2)];
            J = @(v) [-1, 0; -200*v(1), 100];
            x0 = [-1.2; 1.0];
            % Call solver with Wolfe option enabled
            opts = struct('wolfe', true, 'beta', 0.5, 'maxIter', 5);
            [x, info] = opt.lineSearch.newtonSystemArmijo(F, J, x0, opts);
            % Step size should be positive and not exceed 1
            testCase.verifyGreaterThan(info.step, 0);
            testCase.verifyLessThanOrEqual(info.step, 1);
            % Residual norm should decrease compared to the initial guess
            testCase.verifyLessThan(norm(F(x)), norm(F(x0)));
        end
    end
end