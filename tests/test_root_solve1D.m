classdef test_root_solve1D < matlab.unittest.TestCase
    %TEST_ROOT_SOLVE1D  Tests for the robust 1-D solver.
    %   Verifies that the fallback to bisection occurs when Newton and
    %   secant fail, and that secant/Newton succeed when appropriate.

    methods(Test)
        function bisectionFallback(testCase)
            % f has roots at x = 0.1 and x = -2; derivative defined
            f  = @(x) (x - 0.1) .* (x + 2);
            df = @(x) 2*x + 1;
            % Provide a bracket where Newton may fail but bisection succeeds
            [x, info] = opt.root.solve1D(f, df, [-1, 1], struct('tol',1e-10,'maxIter',100));
            testCase.verifyTrue(info.converged, 'Bisection should converge');
            testCase.verifyEqual(info.method, 'bisection');
            testCase.verifyLessThan(abs(f(x)), 1e-8);
        end

        function secantSuccess(testCase)
            % A cubic function with a single real root near 1.52138
            f  = @(x) x.^3 - x - 2;
            df = @(x) 3*x.^2 - 1;
            % Starting from x0 = 1.5 should converge via Newton or secant
            [x, info] = opt.root.solve1D(f, df, 1.5, struct('tol',1e-10,'maxIter',50));
            testCase.verifyTrue(info.converged, 'Solver did not converge on cubic');
            testCase.verifyLessThan(abs(f(x)), 1e-8);
            % The method should be either newton or secant
            testCase.verifyTrue(any(strcmp(info.method, {'newton','secant'})));
        end
    end
end