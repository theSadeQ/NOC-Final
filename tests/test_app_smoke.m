classdef test_app_smoke < matlab.unittest.TestCase
    %TEST_APP_SMOKE Smoke tests for the main optimisation app.
    %   Verifies that the application entry point returns immediately when
    %   invoked with a skip flag.

    methods (Test)
        function testOptimizationAppSkip(testCase)
            % Call the app with the 'skip' argument; should not throw
            testCase.verifyWarningFree(@() opt.OptimizationApp('skip'));
        end
    end
end