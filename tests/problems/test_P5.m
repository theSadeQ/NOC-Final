classdef test_P5 < matlab.unittest.TestCase
    methods(Test)
        function solveP5(testCase)
            spec = readProblemSpec(fullfile('docs','Problems','P5.yaml'));
            f = str2func(['@(x) ' spec.data.f_expr]);
            x0 = spec.data.x0_vec;
            opts = optimset('Display','off');
            [xOpt, fval] = fminsearch(f, x0, opts);
            testCase.verifyLessThan(norm(xOpt - spec.expected'), spec.tolerance);
            testCase.verifyLessThan(fval, spec.tolerance);
        end
    end
end