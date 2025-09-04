%RUNHW2CONSOLE  Run the HW2 line search console demonstration.
%   RUNHW2CONSOLE() calls the line search demo in opt.lineSearch.

if exist('opt.lineSearch.lineSearchOpt','file') == 2
    opt.lineSearch.lineSearchOpt();
else
    fprintf('Line search module not found.\n');
end