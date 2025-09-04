classdef test_barrier_activeSetQP_stub < matlab.unittest.TestCase
    %TEST_BARRIER_ACTIVESETQP_STUB Tests for the active-set QP stub.
    %   Ensures that the placeholder function returns a standardised output.

    methods (Test)
        function testReturnsNotImplementedStatus(testCase)
            % Call the active-set QP stub through the package namespace
            out = opt.barrier.activeSetQP();
            % Verify fields exist
            testCase.verifyTrue(isfield(out,'status'), 'Output struct must contain a status field');
            testCase.verifyEqual(out.status, 'NOT_IMPLEMENTED', 'Status field must be NOT_IMPLEMENTED');
            % x field should exist and be empty
            testCase.verifyTrue(isfield(out,'x'), 'Output struct must contain an x field');
            testCase.verifyEmpty(out.x, 'x field should be empty for unimplemented solver');
        end
    end
end