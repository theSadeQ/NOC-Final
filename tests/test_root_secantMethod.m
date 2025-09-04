classdef test_root_secantMethod < matlab.unittest.TestCase
    %TEST_ROOT_SECANTMETHOD Tests for the secant root solver.
    %   Ensures the secant method converges on typical problems and respects
    %   maximum iteration limits on divergent cases.

    methods (Test)
        function testConvergesOnCubic(testCase)
            % f(x) = x^3 - x - 2 has a real root near 1.52138
            f = @(x) x.^3 - x - 2;
            x0 = 1.0;
            x1 = 2.0;
            [x, info] = opt.root.secantMethod(f, x0, x1, struct('tol',1e-8,'maxIter',20));
            % True root via fzero for comparison (should be approx 1.52138)
            trueRoot = 1.52137970680457;
            testCase.verifyTrue(info.converged, 'Secant method did not converge on the cubic function');
            testCase.verifyLessThan(abs(x - trueRoot), 1e-8, 'Secant method returned an inaccurate root');
            testCase.verifyLessThanOrEqual(info.iterations, 20, 'Secant method exceeded the maximum iterations');
        end

        function testDivergenceRespectMaxIter(testCase)
            % f(x) = x^2 + 1 has no real roots.  The secant method should not
            % converge and must respect the specified maximum iterations.
            f = @(x) x.^2 + 1;
            x0 = 0.0;
            x1 = 1.0;
            opts.tol = 1e-8;
            opts.maxIter = 3;
            [~, info] = opt.root.secantMethod(f, x0, x1, opts);
            testCase.verifyFalse(info.converged, 'Secant method incorrectly flagged convergence');
            testCase.verifyLessThanOrEqual(info.iterations, opts.maxIter, 'Secant method did not respect maxIter');
        end
    end
end