classdef test_P2 < matlab.unittest.TestCase
    methods(Test)
        function solveP2(testCase)
            spec = readProblemSpec(fullfile('docs','Problems','P2.yaml'));
            f  = str2func(['@(x) ' spec.data.f_expr]);
            df = str2func(['@(x) ' spec.data.df_expr]);
            opts = struct('tol', spec.tolerance, 'maxIter', 100);
            [x, ~] = opt.root.newtonMethod(f, df, spec.data.x0, opts);
            testCase.verifyLessThan(abs(x - spec.expected), spec.tolerance);
        end
    end
end