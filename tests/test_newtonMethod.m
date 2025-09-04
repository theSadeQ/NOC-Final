classdef test_newtonMethod < matlab.unittest.TestCase
    %TEST_NEWTONMETHOD  Unit tests for the Newton root solver.

    methods (Test)
        function testSqrt2(tc)
            f = @(x) x.^2 - 2;
            df = @(x) 2*x;
            [x, info] = opt.root.newtonMethod(f, df, 1.0, struct('tol',1e-10,'maxIter',10));
            tc.verifyTrue(info.converged, 'Newton method did not converge');
            tc.verifyLessThan(abs(x - sqrt(2)), 1e-8, 'Root not accurate enough');
            tc.verifyLessThanOrEqual(info.iterations, 10, 'Too many iterations');
        end
    end
end