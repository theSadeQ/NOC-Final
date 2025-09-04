classdef test_utils_parseOptions < matlab.unittest.TestCase
    %TEST_UTILS_PARSEOPTIONS Unit tests for the parseOptions utility.

    methods (Test)
        function testDefaultsApplied(testCase)
            defaultOpts.tol = 1e-6;
            defaultOpts.maxIter = 10;
            % Provide an empty struct; should return default values
            out = opt.utils.parseOptions(struct(), defaultOpts);
            testCase.verifyEqual(out.tol, defaultOpts.tol, 'Default tol not applied');
            testCase.verifyEqual(out.maxIter, defaultOpts.maxIter, 'Default maxIter not applied');
            % Provide only one field; other should default
            out2 = opt.utils.parseOptions(struct('tol',1e-3), defaultOpts);
            testCase.verifyEqual(out2.tol, 1e-3, 'User-supplied tol not used');
            testCase.verifyEqual(out2.maxIter, defaultOpts.maxIter, 'Missing field maxIter not defaulted');
        end

        function testInvalidTypeThrows(testCase)
            defaultOpts.tol = 1e-6;
            defaultOpts.maxIter = 10;
            % Pass invalid type for tol
            testCase.verifyError(@() opt.utils.parseOptions(struct('tol','bad'), defaultOpts), ...
                'opt:utils:parseOptions', 'Expected invalid type to raise parseOptions error');
            % Pass non-struct userOpts
            testCase.verifyError(@() opt.utils.parseOptions(42, defaultOpts), ...
                'opt:utils:parseOptions', 'Expected non-struct userOpts to raise parseOptions error');
        end

        function testIgnoresUnknownFields(testCase)
            defaultOpts.a = 1;
            defaultOpts.b = 2;
            % Unknown field c should be ignored
            out = opt.utils.parseOptions(struct('c', 3), defaultOpts);
            testCase.verifyFalse(isfield(out,'c'), 'Unknown field should not be present in output');
            testCase.verifyEqual(out.a, 1);
            testCase.verifyEqual(out.b, 2);
        end
    end
end