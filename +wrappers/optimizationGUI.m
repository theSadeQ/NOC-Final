function app = optimizationGUI(varargin)
%OPTIMIZATIONGUI Facade to launch the optimisation GUI class.
%   app = wrappers.optimizationGUI(opts) constructs and returns an
%   instance of wrappers.OptimizationGUI.  Pass a struct with field
%   Visible='off' to hide the UI for automated tests.

app = wrappers.OptimizationGUI(varargin{:});