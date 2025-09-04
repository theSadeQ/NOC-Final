classdef test_P4 < matlab.unittest.TestCase
    methods(Test)
        function solveP4(testCase)
            spec = readProblemSpec(fullfile('docs','Problems','P4.yaml'));
            out = opt.barrier.activeSetQP();
            testCase.verifyEqual(out.status, spec.expected);
        end
    end
end