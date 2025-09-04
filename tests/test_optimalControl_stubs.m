classdef test_optimalControl_stubs < matlab.unittest.TestCase
    %TEST_OPTIMALCONTROL_STUBS Smoke tests for optimal control stubs.
    %   Verify that the modules run quickly and without error.

    methods (Test)
        function testLunarLandingRuns(testCase)
            % Lunar landing stub should run and return without error
            testCase.verifyWarningFree(@() evalc('opt.optimalControl.lunarLandingModule')); %#ok<EVAL>
        end

        function testCollocationRuns(testCase)
            % Collocation stub should run and return without error
            testCase.verifyWarningFree(@() evalc('opt.optimalControl.collocationModule')); %#ok<EVAL>
        end
    end
end