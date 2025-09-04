classdef test_P10 < matlab.unittest.TestCase
    methods(Test)
        function solveP10(testCase)
            spec = readProblemSpec(fullfile('docs','Problems','P10.yaml'));
            f = str2func(['@(x) ' spec.data.f_expr]);
            df = str2func(['@(x) ' spec.data.df_expr]);
            opts = struct('tol', spec.tolerance, 'maxIter', 50);
            [x, ~] = opt.root.newtonMethod(f, df, spec.data.x0, opts);
            testCase.verifyLessThan(abs(x - spec.expected), spec.tolerance);
        end
    end
end