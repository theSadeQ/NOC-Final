classdef test_lineSearch_newtonSystemArmijo < matlab.unittest.TestCase
    %TEST_LINESEARCH_NEWTONSYSTEMARMIJO Tests for the Newton/Armijo line search solver.
    %   Checks that the method decreases the residual on a nonlinear system
    %   and properly handles singular Jacobians.

    methods (Test)
        function testRosenbrockReduction(testCase)
            % Define Rosenbrock system: F(x) = [10*(x2 - x1^2); 1 - x1]
            F = @(x) [10*(x(2) - x(1)^2); 1 - x(1)];
            J = @(x) [-20*x(1), 10; -1, 0];
            x0 = [-1.2; 1.0];
            % Initial residual norm
            initialNorm = norm(F(x0));
            [x, info] = opt.lineSearch.newtonSystemArmijo(F, J, x0, struct('tol',1e-8,'maxIter',10,'c1',1e-4));
            % Residual should decrease
            newNorm = norm(F(x));
            testCase.verifyLessThan(newNorm, initialNorm, 'Armijo method failed to reduce the residual norm');
            % Step size recorded in info should be positive and not exceed 1
            testCase.verifyGreaterThan(info.stepSize, 0, 'Armijo step size must be positive');
            testCase.verifyLessThanOrEqual(info.stepSize, 1, 'Armijo step size must not exceed 1');
            % Iteration count should not exceed maxIter
            testCase.verifyLessThanOrEqual(info.iterations, 10, 'Line search exceeded maxIter');
        end

        function testSingularJacobianThrows(testCase)
            % Define a system with a singular Jacobian everywhere: F(x)=x, J(x)=0
            F = @(x) [x(1); x(2)];
            J = @(x) zeros(2);
            x0 = [1; 1];
            testCase.verifyError(@() opt.lineSearch.newtonSystemArmijo(F, J, x0, struct('maxIter',5)), ...
                'opt:lineSearch:singularJ', 'Expected singular Jacobian to raise an exception');
        end
    end
end