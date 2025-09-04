function results = runtests(folder)
%RUNTESTS Run the full MATLAB unit test suite.
%   RESULTS = RUNTESTS(FOLDER) discovers and runs all tests in the
%   specified folder (default: the folder containing this file) using a
%   text output runner and generates a Cobertura-format coverage report.
%   If any test fails, this function throws an error.

    if nargin == 0
        folder = fileparts(mfilename('fullpath'));
    end
    import matlab.unittest.TestSuite;
    import matlab.unittest.TestRunner;
    import matlab.unittest.plugins.CodeCoveragePlugin;
    % Discover tests recursively
    suite = TestSuite.fromFolder(folder, 'IncludingSubfolders', true);
    % Configure the test runner with verbose text output
    runner = TestRunner.withTextOutput('Verbosity', 3);
    % Determine coverage root (the +opt folder two levels up from this file)
    repoRoot = fileparts(folder);
    covRoot = fullfile(repoRoot, '+opt');
    covFile = fullfile(folder, 'coverage.xml');
    % Add coverage plugin for the whole opt package
    runner.addPlugin(CodeCoveragePlugin.forFolder(covRoot, ...
        'Producing', matlab.unittest.plugins.codecoverage.CoberturaFormat(covFile)));
    % Suppress secant zero-slope warnings during the test run
    originalWarnState = warning('off','opt:root:secant:ZeroSlope'); %#ok<NASGU>
    % Run the tests
    results = runner.run(suite);
    % Restore warning state
    warning('on','opt:root:secant:ZeroSlope');
    disp(table(results));
    % Signal failure by throwing an error if any test failed
    if any([results.Failed])
        error('TestsFailed');
    end
end