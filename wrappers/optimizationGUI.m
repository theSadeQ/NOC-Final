function app = optimizationGUI(opts)
%OPTIMIZATIONGUI  Launch the optimisation GUI (wrapper).
%   This convenience function forwards to the package implementation
%   `wrappers.optimizationGUI`.  Provide an optional struct with a
%   `Visible` field to create the window hidden for testing.

if nargin < 1
    opts = struct;
end
app = wrappers.optimizationGUI(opts);