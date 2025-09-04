classdef test_wrappers_smoke < matlab.unittest.TestCase
    %TEST_WRAPPERS_SMOKE Smoke tests for wrapper scripts.
    %   These tests ensure that the demonstration wrappers run without
    %   errors or user interaction.

    methods (Test)
        function testRunHW2Console(testCase)
            % Capture output to avoid cluttering test log
            testCase.verifyWarningFree(@() evalc('runHW2Console')); %#ok<EVAL> 
        end

        function testRunHW3Console(testCase)
            testCase.verifyWarningFree(@() evalc('runHW3Console')); %#ok<EVAL> 
        end

        function testGUIPlaceholder(testCase)
            % The GUI placeholder should run and print a message
            testCase.verifyWarningFree(@() evalc('optimizationGUI')); %#ok<EVAL> 
        end
    end
end