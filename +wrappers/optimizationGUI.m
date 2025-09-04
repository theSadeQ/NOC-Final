function app = optimizationGUI(varargin)
%OPTIMIZATIONGUI  Simple UI for root solvers (Newton/Secant).
%   app = wrappers.optimizationGUI()   % returns UI handles for testing
%
% Tags used by tests:
%   FunctionField, DerivativeField, MethodDropDown, X0Field, X1Field,
%   SolveButton, ResultLabel, StatusLabel

% ------------ UI ------------
f = uifigure('Name','Optimization GUI','Position',[100 100 520 260],'Tag','OptimizationGUI');
gl = uigridlayout(f,[6 2], 'RowHeight',{'fit','fit','fit','fit','fit','1x'}, ...
    'ColumnWidth',{'fit','1x'}, 'Padding',[10 10 10 10], 'RowSpacing',8, 'ColumnSpacing',8);

uilabel(gl,'Text','f(x) =');
hFun = uieditfield(gl,'text','Tag','FunctionField','Placeholder','x.^2 - 2');

uilabel(gl,'Text','df/dx =');
hDf  = uieditfield(gl,'text','Tag','DerivativeField','Placeholder','2*x');

uilabel(gl,'Text','Method');
hMethod = uidropdown(gl,'Items',{'Newton','Secant'},'Value','Newton','Tag','MethodDropDown');

uilabel(gl,'Text','x0');
hX0 = uieditfield(gl,'text','Tag','X0Field','Value','1.0');

uilabel(gl,'Text','x1 (secant only)');
hX1 = uieditfield(gl,'text','Tag','X1Field','Value','2.0','Enable','off');

hSolve = uibutton(gl,'Text','Solve','Tag','SolveButton','ButtonPushedFcn',@onSolve);
hSolve.Layout.Column = [1 1];

hRes = uilabel(gl,'Text','Result: (none)','Tag','ResultLabel','FontWeight','bold');
hRes.Layout.Column = [2 2];

hStatus = uilabel(gl,'Text','','Tag','StatusLabel');
hStatus.Layout.Column = [1 2];

hMethod.ValueChangedFcn = @(~,~)updateMethodUI();
updateMethodUI();

app = struct('UIFigure',f,'FunctionField',hFun,'DerivativeField',hDf, ...
    'MethodDropDown',hMethod,'X0Field',hX0,'X1Field',hX1, ...
    'SolveButton',hSolve,'ResultLabel',hRes,'StatusLabel',hStatus);

% ------------ Callbacks ------------
    function updateMethodUI()
        isNewton = strcmp(hMethod.Value,'Newton');
        hDf.Enable = matlab.lang.OnOffSwitchState(isNewton);
        hX1.Enable = matlab.lang.OnOffSwitchState(~isNewton);
    end

    function onSolve(~,~)
        try
            funcStr = strtrim(hFun.Value);
            if isempty(funcStr), error('opt:gui:missingFunction','Function is required'); end
            f = str2func(['@(x) ' funcStr]);  %#ok<STR2FUNC>

            x0 = str2double(hX0.Value);
            if ~isfinite(x0), error('opt:gui:badX0','x0 must be numeric'); end

            opts = struct('tol',1e-10,'maxIter',50);
            switch hMethod.Value
                case 'Newton'
                    dfStr = strtrim(hDf.Value);
                    if isempty(dfStr), error('opt:gui:missingDerivative','df/dx is required for Newton'); end
                    df = str2func(['@(x) ' dfStr]); %#ok<STR2FUNC>
                    [x, info] = opt.root.newtonMethod(f, df, x0, opts);
                otherwise
                    x1 = str2double(hX1.Value);
                    if ~isfinite(x1), error('opt:gui:badX1','x1 must be numeric'); end
                    [x, info] = opt.root.secantMethod(f, x0, x1, opts);
            end

            hRes.Text = sprintf('Result: %.12g', x);
            iters = getfield(info,'iterations',getfield(info,'iters',NaN)); %#ok<GFLD>
            hStatus.Text = sprintf('Converged: %d | iters: %d | |f(x)|=%.3g', info.converged, iters, abs(f(x)));
        catch ME
            hRes.Text = 'Result: error';
            hStatus.Text = sprintf('[%s] %s', ME.identifier, ME.message);
        end
    end
end
