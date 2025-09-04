function OptimizationApp(varargin)
%OPTIMIZATIONAPP  Console menu for the optimisation package (MVP).
%   OPTIMIZATIONAPP() prints a header and a list of available modules.
%   OPTIMIZATIONAPP('skip') returns immediately without any output.  This
%   is used by the automated test suite to perform a smoke test.

    if nargin > 0
        arg = varargin{1};
        if ischar(arg) && strcmpi(arg, 'skip')
            return;
        end
    end
    % Print a header using the utils package if available
    if exist('opt.utils.printHeader','file') == 2
        opt.utils.printHeader('Nonlinear Optimisation Package');
    else
        fprintf('\n==== Nonlinear Optimisation Package ===\n');
    end
    fprintf('Welcome to the optimisation app.\n');
    fprintf('This MVP lists available modules and then exits.\n');
    fprintf('\nAvailable modules:\n');
    fprintf(' 1) Nonlinear 1‑D Root Finding (opt.root.nonlinear1DModule)\n');
    fprintf(' 2) Stationary Points (opt.root.rootStationaryModule)\n');
    fprintf(' 3) Line Search (opt.lineSearch.lineSearchOpt)\n');
    fprintf(' 4) Barrier Methods (opt.barrier.barrierMethodModule)\n');
    fprintf(' 5) Optimal Control (opt.optimalControl.lunarLandingModule)\n');
    fprintf(' 0) Exit\n');
    fprintf('\nExiting.\n');
end