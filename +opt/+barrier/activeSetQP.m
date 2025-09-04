function out = activeSetQP()
%ACTIVESETQP  Placeholder for an active-set QP solver.
%   OUT = ACTIVESETQP() returns a struct with fields:
%     x      - an empty solution vector
%     status - string, currently 'NOT_IMPLEMENTED'
%   This behaviour allows callers and test suites to detect the
%   placeholder status without parsing printed output.  Future versions
%   will implement a working active-set solver.

    opt.utils.printHeader('Active-Set QP');
    fprintf('Active-set QP solver not implemented.\n');
    fprintf('This function is a stub for future development.\n');
    out.x = [];
    out.status = 'NOT_IMPLEMENTED';
end