classdef test_root_newtonMethod < matlab.unittest.TestCase
    %TEST_ROOT_NEWTONMETHOD Unit tests for the Newton root solver.
    %   These tests verify that the Newton method converges to the correct
    %   root on simple problems and handles zero-derivative cases via
    %   well-defined exceptions.

    methods (Test)
        function testConvergesOnQuadratic(testCase)
            % f(x) = x^2 - 2 has root at sqrt(2)
            f = @(x) x.^2 - 2;
            df = @(x) 2*x;
            [x, info] = opt.root.newtonMethod(f, df, 1.0, struct('tol',1e-8,'maxIter',10));
            % Check convergence flag
            testCase.verifyTrue(info.converged, 'Newton method did not report convergence');
            % Check approximate solution accuracy
            testCase.verifyLessThan(abs(x - sqrt(2)), 1e-8, 'Newton method returned an inaccurate root');
            % Check iteration count
            testCase.verifyLessThanOrEqual(info.iterations, 10, 'Newton method exceeded maximum iterations');
        end

        function testZeroDerivativeThrows(testCase)
            % f(x) = 1 has derivative zero everywhere; Newton should throw
            f = @(x) 1 + 0*x;
            df = @(x) 0 + 0*x;
            testCase.verifyError(@() opt.root.newtonMethod(f, df, 0.0, struct('tol',1e-8,'maxIter',5)), ...
                'opt:root:newton:ZeroDerivative', 'Expected zero derivative to throw a package-specific exception');
        end
    end
end