classdef test_P8 < matlab.unittest.TestCase
    methods(Test)
        function solveP8(testCase)
            spec = readProblemSpec(fullfile('docs','Problems','P8.yaml'));
            out = opt.barrier.activeSetQP();
            testCase.verifyEqual(out.status, spec.expected);
        end
    end
end