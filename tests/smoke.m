function smoke()
%SMOKE  Smoke test for the optimisation package.
%   SMOKE() calls the application with a flag to skip the menu.  This
%   verifies that the top-level entry point is callable without error.

    opt.OptimizationApp('skip');
end