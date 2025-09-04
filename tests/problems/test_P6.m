classdef test_P6 < matlab.unittest.TestCase
    methods(Test)
        function solveP6(testCase)
            spec = readProblemSpec(fullfile('docs','Problems','P6.yaml'));
            % Expect NOT_IMPLEMENTED for optimal control stub
            testCase.verifyEqual(spec.expected, 'NOT_IMPLEMENTED');
            % Calling the module should produce no error
            testCase.verifyWarningFree(@() opt.optimalControl.lunarLandingModule());
        end
    end
end