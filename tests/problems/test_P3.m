classdef test_P3 < matlab.unittest.TestCase
    methods(Test)
        function solveP3(testCase)
            spec = readProblemSpec(fullfile('docs','Problems','P3.yaml'));
            F = str2func(['@(v) ' spec.data.F_expr]);
            J = str2func(['@(v) ' spec.data.J_expr]);
            x0 = spec.data.x0_vec;
            opts = struct('maxIter', 50, 'alpha', 0.25, 'beta', 0.5, 'c1', 1e-4, 'c2', 0.9);
            [x, info] = opt.lineSearch.newtonSystemArmijo(F, J, x0, opts);
            res = norm(F(x));
            testCase.verifyLessThan(res, spec.tolerance);
            % residual should decrease across iterations when history available
            if isfield(info,'history') && ~isempty(info.history)
                testCase.verifyLessThan(info.history(end), info.history(1));
            end
        end
    end
end