classdef OptimizationGUI < matlab.apps.AppBase
    %OPTIMIZATIONGUI Class-based GUI for optimisation demonstrations.
    %   This app exposes root finding, line search, barrier methods,
    %   unconstrained optimisation and a toy lunar landing collocation
    %   example.  The GUI is headless-friendly: construct with
    %   opts.Visible='off' to hide the figure for automated tests.  All
    %   interactive controls are public properties with stable Tag names
    %   for use with matlab.uitest.TestCase.

    properties (Access = public)
        UIFigure            matlab.ui.Figure
        TabGroup            matlab.ui.container.TabGroup
        RootTab             matlab.ui.container.Tab
        LineTab             matlab.ui.container.Tab
        BarrierTab          matlab.ui.container.Tab
        FminconTab          matlab.ui.container.Tab
        LunarTab            matlab.ui.container.Tab
        % Root solver controls
        FunctionField       matlab.ui.control.EditField
        DerivativeField     matlab.ui.control.EditField
        MethodDropDown      matlab.ui.control.DropDown
        X0Field             matlab.ui.control.NumericEditField
        X1Field             matlab.ui.control.NumericEditField
        TolField            matlab.ui.control.NumericEditField
        MaxIterField        matlab.ui.control.NumericEditField
        SolveButton         matlab.ui.control.Button
        ResultLabel         matlab.ui.control.Label
        StatusLabel         matlab.ui.control.Label
        HistoryAxes         matlab.ui.control.UIAxes
        % Line search controls
        FField              matlab.ui.control.EditField
        JField              matlab.ui.control.EditField
        XVecField           matlab.ui.control.EditField
        StrategyDropDown    matlab.ui.control.DropDown
        AlphaField          matlab.ui.control.NumericEditField
        BetaField           matlab.ui.control.NumericEditField
        C1Field             matlab.ui.control.NumericEditField
        C2Field             matlab.ui.control.NumericEditField
        LSMaxIterField      matlab.ui.control.NumericEditField
        SolveSystemButton   matlab.ui.control.Button
        LSStatusLabel       matlab.ui.control.Label
        HistoryAxes2        matlab.ui.control.UIAxes
        % Barrier controls
        RunBarrierButton    matlab.ui.control.Button
        BarrierTable        matlab.ui.control.Table
        BarrierStatusLabel  matlab.ui.control.Label
        BarrierAxes         matlab.ui.control.UIAxes
        % fmincon controls
        FminObjField        matlab.ui.control.EditField
        FminX0Field         matlab.ui.control.EditField
        FminConstrField     matlab.ui.control.EditField
        FminAlgDropDown     matlab.ui.control.DropDown
        FminRunButton       matlab.ui.control.Button
        FminExportButton    matlab.ui.control.Button
        FminResultTable     matlab.ui.control.Table
        FminLogArea         matlab.ui.control.TextArea
        % Lunar controls
        LunarNField         matlab.ui.control.NumericEditField
        LunarObjDropDown    matlab.ui.control.DropDown
        LunarRunButton      matlab.ui.control.Button
        LunarExportButton   matlab.ui.control.Button
        LunarAltAxes        matlab.ui.control.UIAxes
        LunarSpeedAxes      matlab.ui.control.UIAxes
        LunarThrustAxes     matlab.ui.control.UIAxes
        LunarMassAxes       matlab.ui.control.UIAxes
        LunarSummaryTable   matlab.ui.control.Table
        % Load preset button
        LoadPresetButton   matlab.ui.control.Button
    end

    methods (Access = public)
        function app = OptimizationGUI(varargin)
            % Constructor: optionally accept opts struct with Visible field
            opts.Visible = 'on';
            if nargin >= 1 && isstruct(varargin{1})
                inOpts = varargin{1};
                if isfield(inOpts,'Visible'), opts.Visible = inOpts.Visible; end
            end
            createComponents(app);
            app.UIFigure.Visible = opts.Visible;
        end
    end

    methods (Access = private)
        function createComponents(app)
            % Build figure and tabs
            app.UIFigure = uifigure('Name','Optimization GUI','Visible','off');
            app.TabGroup = uitabgroup(app.UIFigure);
            %% Root tab
            app.RootTab = uitab(app.TabGroup,'Title','Root');
            uilabel(app.RootTab,'Text','f(x)=','Position',[10 380 50 22]);
            app.FunctionField = uieditfield(app.RootTab,'text','Tag','FunctionField','Position',[60 380 200 22]);
            uilabel(app.RootTab,'Text','df/dx=','Position',[10 350 50 22]);
            app.DerivativeField = uieditfield(app.RootTab,'text','Tag','DerivativeField','Position',[60 350 200 22]);
            uilabel(app.RootTab,'Text','Method','Position',[10 320 50 22]);
            app.MethodDropDown = uidropdown(app.RootTab,'Tag','MethodDropDown','Items',{'Newton','Secant'},'Position',[60 320 100 22]);
            uilabel(app.RootTab,'Text','x0','Position',[10 290 50 22]);
            app.X0Field = uieditfield(app.RootTab,'numeric','Tag','X0Field','Position',[60 290 100 22]);
            uilabel(app.RootTab,'Text','x1','Position',[10 260 50 22]);
            app.X1Field = uieditfield(app.RootTab,'numeric','Tag','X1Field','Position',[60 260 100 22]);
            app.X1Field.Enable = 'off';
            uilabel(app.RootTab,'Text','tol','Position',[10 230 50 22]);
            app.TolField = uieditfield(app.RootTab,'numeric','Tag','TolField','Position',[60 230 100 22],'Value',1e-10);
            uilabel(app.RootTab,'Text','maxIter','Position',[10 200 50 22]);
            app.MaxIterField = uieditfield(app.RootTab,'numeric','Tag','MaxIterField','Position',[60 200 100 22],'Value',50);
            app.SolveButton = uibutton(app.RootTab,'push','Text','Solve','Tag','SolveButton','Position',[10 160 80 28],...
                'ButtonPushedFcn',@(src,ev)solveRoot(app));
            app.ResultLabel = uilabel(app.RootTab,'Tag','ResultLabel','Position',[10 130 300 22],'Text','');
            app.StatusLabel = uilabel(app.RootTab,'Tag','StatusLabel','Position',[10 100 300 22],'Text','');
            app.HistoryAxes = uiaxes(app.RootTab,'Tag','HistoryAxes','Position',[300 200 300 200]);
            title(app.HistoryAxes,'|f(x_k)| history'); xlabel(app.HistoryAxes,'Iteration'); ylabel(app.HistoryAxes,'|f(x)|');
            app.MethodDropDown.ValueChangedFcn = @(src,ev)toggleX1(app);
            %% Line search tab
            app.LineTab = uitab(app.TabGroup,'Title','Line Search');
            uilabel(app.LineTab,'Text','F(v)=','Position',[10 380 50 22]);
            app.FField = uieditfield(app.LineTab,'text','Tag','FField','Position',[60 380 250 22]);
            uilabel(app.LineTab,'Text','J(v)=','Position',[10 350 50 22]);
            app.JField = uieditfield(app.LineTab,'text','Tag','JField','Position',[60 350 250 22]);
            uilabel(app.LineTab,'Text','x0','Position',[10 320 50 22]);
            app.XVecField = uieditfield(app.LineTab,'text','Tag','XVecField','Position',[60 320 250 22]);
            uilabel(app.LineTab,'Text','Strategy','Position',[10 290 50 22]);
            app.StrategyDropDown = uidropdown(app.LineTab,'Tag','StrategyDropDown','Items',{'Armijo','Strong Wolfe'},'Position',[60 290 100 22]);
            uilabel(app.LineTab,'Text','alpha','Position',[10 260 50 22]);
            app.AlphaField = uieditfield(app.LineTab,'numeric','Tag','AlphaField','Position',[60 260 100 22],'Value',0.25);
            uilabel(app.LineTab,'Text','beta','Position',[10 230 50 22]);
            app.BetaField = uieditfield(app.LineTab,'numeric','Tag','BetaField','Position',[60 230 100 22],'Value',0.5);
            uilabel(app.LineTab,'Text','c1','Position',[10 200 50 22]);
            app.C1Field = uieditfield(app.LineTab,'numeric','Tag','C1Field','Position',[60 200 100 22],'Value',1e-4);
            uilabel(app.LineTab,'Text','c2','Position',[10 170 50 22]);
            app.C2Field = uieditfield(app.LineTab,'numeric','Tag','C2Field','Position',[60 170 100 22],'Value',0.9);
            uilabel(app.LineTab,'Text','maxIter','Position',[10 140 50 22]);
            app.LSMaxIterField = uieditfield(app.LineTab,'numeric','Tag','MaxIterField','Position',[60 140 100 22],'Value',50);
            app.SolveSystemButton = uibutton(app.LineTab,'push','Text','Solve','Tag','SolveSystemButton','Position',[10 100 80 28],...
                'ButtonPushedFcn',@(src,ev)solveLineSearch(app));
            app.LSStatusLabel = uilabel(app.LineTab,'Tag','LSStatusLabel','Position',[10 70 400 22],'Text','');
            app.HistoryAxes2 = uiaxes(app.LineTab,'Tag','HistoryAxes2','Position',[330 200 300 200]);
            title(app.HistoryAxes2,'||F(x_k)|| history'); xlabel(app.HistoryAxes2,'Iteration'); ylabel(app.HistoryAxes2,'||F(x)||');
            %% Barrier tab
            app.BarrierTab = uitab(app.TabGroup,'Title','Barrier');
            app.RunBarrierButton = uibutton(app.BarrierTab,'push','Text','Run Barrier','Tag','RunBarrierButton','Position',[10 380 100 28],...
                'ButtonPushedFcn',@(src,ev)runBarrier(app));
            app.BarrierStatusLabel = uilabel(app.BarrierTab,'Tag','BarrierStatusLabel','Position',[120 380 300 22],'Text','');
            app.BarrierTable = uitable(app.BarrierTab,'Tag','BarrierTable','Position',[10 100 300 250]);
            app.BarrierTable.ColumnName = {'Iter','mu','x1','x2','residual'};
            app.BarrierAxes = uiaxes(app.BarrierTab,'Tag','BarrierAxes','Position',[330 100 300 250]);
            title(app.BarrierAxes,'Feasible region and iterates');
            %% fmincon tab
            app.FminconTab = uitab(app.TabGroup,'Title','fmincon');
            uilabel(app.FminconTab,'Text','f(x)=','Position',[10 380 50 22]);
            app.FminObjField = uieditfield(app.FminconTab,'text','Tag','FminObjField','Position',[60 380 250 22]);
            uilabel(app.FminconTab,'Text','x0','Position',[10 350 50 22]);
            app.FminX0Field = uieditfield(app.FminconTab,'text','Tag','FminX0Field','Position',[60 350 250 22]);
            uilabel(app.FminconTab,'Text','c(x)<=0','Position',[10 320 70 22]);
            app.FminConstrField = uieditfield(app.FminconTab,'text','Tag','FminConstrField','Position',[80 320 230 22]);
            uilabel(app.FminconTab,'Text','Alg','Position',[10 290 50 22]);
            app.FminAlgDropDown = uidropdown(app.FminconTab,'Tag','FminAlgDropDown','Items',{'fminsearch'},'Position',[60 290 100 22]);
            app.FminRunButton = uibutton(app.FminconTab,'push','Text','Run','Tag','FminRunButton','Position',[10 250 80 28],...
                'ButtonPushedFcn',@(src,ev)runFmin(app));
            app.FminExportButton = uibutton(app.FminconTab,'push','Text','Export','Tag','FminExportButton','Position',[100 250 80 28],...
                'ButtonPushedFcn',@(src,ev)exportFmin(app));
            app.FminResultTable = uitable(app.FminconTab,'Tag','FminResultTable','Position',[10 100 300 140]);
            app.FminResultTable.ColumnName = {'x1','x2','fval'};
            app.FminLogArea = uitextarea(app.FminconTab,'Tag','FminLogArea','Position',[330 100 300 200]);
            %% Lunar tab
            app.LunarTab = uitab(app.TabGroup,'Title','Lunar');
            uilabel(app.LunarTab,'Text','N','Position',[10 380 50 22]);
            app.LunarNField = uieditfield(app.LunarTab,'numeric','Tag','LunarNField','Position',[60 380 100 22],'Value',10);
            uilabel(app.LunarTab,'Text','Objective','Position',[10 350 70 22]);
            app.LunarObjDropDown = uidropdown(app.LunarTab,'Tag','LunarObjDropDown','Items',{'Time','Fuel'},'Position',[80 350 100 22]);
            app.LunarRunButton = uibutton(app.LunarTab,'push','Text','Transcribe & Solve','Tag','LunarRunButton','Position',[10 310 120 28],...
                'ButtonPushedFcn',@(src,ev)runLunar(app));
            app.LunarExportButton = uibutton(app.LunarTab,'push','Text','Export','Tag','LunarExportButton','Position',[140 310 80 28],...
                'ButtonPushedFcn',@(src,ev)exportLunar(app));
            app.LunarAltAxes   = uiaxes(app.LunarTab,'Tag','LunarAltAxes','Position',[10 150 200 120]);
            app.LunarSpeedAxes = uiaxes(app.LunarTab,'Tag','LunarSpeedAxes','Position',[220 150 200 120]);
            app.LunarThrustAxes= uiaxes(app.LunarTab,'Tag','LunarThrustAxes','Position',[430 150 200 120]);
            app.LunarMassAxes  = uiaxes(app.LunarTab,'Tag','LunarMassAxes','Position',[640 150 200 120]);
            title(app.LunarAltAxes,'Altitude'); title(app.LunarSpeedAxes,'Speed');
            title(app.LunarThrustAxes,'Thrust'); title(app.LunarMassAxes,'Mass');
            app.LunarSummaryTable = uitable(app.LunarTab,'Tag','LunarSummaryTable','Position',[10 100 300 40]);
            app.LunarSummaryTable.ColumnName = {'tf','fuel','m_f','minAlt'};

            %% Load preset button (top-level)
            app.LoadPresetButton = uibutton(app.UIFigure,'push','Text','Load Preset...','Tag','LoadPresetButton','Position',[10 20 120 28],...
                'ButtonPushedFcn',@(src,ev)loadPresetCallback(app));
        end

        function toggleX1(app)
            if strcmp(app.MethodDropDown.Value,'Secant')
                app.X1Field.Enable = 'on';
            else
                app.X1Field.Enable = 'off';
            end
        end

        function solveRoot(app)
            app.StatusLabel.Text = '';
            app.ResultLabel.Text = '';
            cla(app.HistoryAxes);
            % build function handle
            try
                f = app.safeExpr2Handle(app.FunctionField.Value,'x');
            catch ME
                app.StatusLabel.Text = ['[' ME.identifier '] ' ME.message]; return;
            end
            method = app.MethodDropDown.Value;
            tol = app.TolField.Value; maxIter = app.MaxIterField.Value;
            optsR = struct('tol',tol,'maxIter',maxIter);
            try
                x0 = app.X0Field.Value;
                if strcmp(method,'Newton')
                    if isempty(strtrim(app.DerivativeField.Value))
                        error('opt:gui:badDerivative','Derivative cannot be empty for Newton');
                    end
                    df = app.safeExpr2Handle(app.DerivativeField.Value,'x');
                    [x,info] = opt.root.newtonMethod(f,df,x0,optsR);
                else
                    x1 = app.X1Field.Value;
                    [x,info] = opt.root.secantMethod(f,x0,x1,optsR);
                end
                if info.converged
                    app.ResultLabel.Text = sprintf('x = %.10g, f(x) = %.3g, iters = %d',x,f(x),info.iterations);
                else
                    app.ResultLabel.Text = sprintf('x = %.10g, did not converge in %d iter',x,info.iterations);
                end
                if isfield(info,'history') && ~isempty(info.history)
                    plot(app.HistoryAxes,1:numel(info.history),info.history,'-o');
                end
            catch ME
                app.StatusLabel.Text = ['[' ME.identifier '] ' ME.message];
            end
        end

        function solveLineSearch(app)
            app.LSStatusLabel.Text = '';
            cla(app.HistoryAxes2);
            % build vector functions
            try
                F = app.safeExpr2Handle(app.FField.Value,'v');
                J = app.safeExpr2Handle(app.JField.Value,'v');
            catch ME
                app.LSStatusLabel.Text = ['[' ME.identifier '] ' ME.message]; return;
            end
            x0str = strtrim(app.XVecField.Value);
            try
                x0v = app.safeNumArray(x0str);
            catch ME
                app.LSStatusLabel.Text = ['[' ME.identifier '] ' ME.message]; return;
            end
            optsL = struct();
            optsL.maxIter = app.LSMaxIterField.Value;
            optsL.alpha   = app.AlphaField.Value;
            optsL.beta    = app.BetaField.Value;
            optsL.singularityTol = 1e-12;
            if strcmp(app.StrategyDropDown.Value,'Strong Wolfe')
                optsL.wolfe = true;
                optsL.c1 = app.C1Field.Value;
                optsL.c2 = app.C2Field.Value;
            else
                optsL.wolfe = false;
            end
            try
                [~,info] = opt.lineSearch.newtonSystemArmijo(F,J,x0v,optsL);
                if info.converged
                    app.LSStatusLabel.Text = sprintf('step = %.3g, iters = %d',info.step,info.iters);
                else
                    app.LSStatusLabel.Text = sprintf('did not converge in %d iter, step = %.3g',info.iters,info.step);
                end
                if isfield(info,'history') && ~isempty(info.history)
                    plot(app.HistoryAxes2,1:numel(info.history),info.history,'-o');
                end
            catch ME
                app.LSStatusLabel.Text = ['[' ME.identifier '] ' ME.message];
            end
        end

        function runBarrier(app)
            % Simple 2-D inequality barrier demonstration
            app.BarrierStatusLabel.Text = '';
            app.BarrierTable.Data = [];
            cla(app.BarrierAxes);
            % Problem: minimize (x1-1)^2 + (x2-1)^2 subject to x1 + x2 >= 1
            f = @(x) (x(1)-1).^2 + (x(2)-1).^2;
            grad = @(x) [2*(x(1)-1); 2*(x(2)-1)];
            hess = @(x) 2*eye(2);
            c = @(x) 1 - x(1) - x(2); % inequality <= 0 means feasible region x1+x2 >= 1
            x = [1.5; 0.1];
            mu = 1.0;
            iter = 0;
            data = [];
            while mu > 1e-3 && iter < 20
                % inner damped Newton
                for j=1:10
                    % gradient of barrier function f_b(x) = f(x) - mu*log(-c(x))
                    g = grad(x) + mu * grad_c(x) / (-c(x));
                    H = hess(x) + mu * (grad_c(x)*grad_c(x).' / (c(x)^2));
                    % ensure PD
                    [R,p] = chol(H);
                    if p>0
                        H = H + (1e-6*norm(H,1)+1e-12)*eye(2);
                    end
                    d = -H\g;
                    % fraction to boundary step
                    tau = 1.0;
                    if (grad_c(x).' * d) > 0
                        tau = min(1, 0.99*(-c(x))/(grad_c(x).'* d));
                    end
                    % Armijo on merit
                    t = tau; phi0 = merit(x,mu); deriv = g.'*d;
                    while merit(x + t*d,mu) > phi0 + 0.1*t*deriv && t > eps
                        t = 0.5*t;
                    end
                    x = x + t*d;
                    if norm(g) < 1e-6, break; end
                end
                iter = iter+1;
                data(end+1,:) = {iter, mu, x(1), x(2), norm(g)}; %#ok<AGROW>
                mu = mu * 0.5;
            end
            app.BarrierTable.Data = data;
            app.BarrierStatusLabel.Text = sprintf('Finished in %d outer iterations',iter);
            % plot feasible region and iterates
            hold(app.BarrierAxes,'on');
            % feasible region: x1+x2>=1
            [X1,X2] = meshgrid(linspace(0,2,30));
            mask = X1+X2>=1;
            surf(app.BarrierAxes,X1,X2,double(mask),'EdgeColor','none','FaceAlpha',0.2);
            app.BarrierAxes.ZLim = [0 1]; view(app.BarrierAxes,2);
            plot(app.BarrierAxes,cell2mat(data(:,3)),cell2mat(data(:,4)),'-o','LineWidth',2);
            hold(app.BarrierAxes,'off');

            function g = grad_c(x)
                g = [-1; -1];
            end
            function val = merit(x,mu)
                if c(x) >= 0
                    val = f(x) + mu*1e6; % huge penalty
                else
                    val = f(x) - mu*log(-c(x));
                end
            end
        end

        function runFmin(app)
            % Unconstrained optimisation via fminsearch as fallback
            app.FminLogArea.Value = '';
            app.FminResultTable.Data = [];
            try
                f = app.safeExpr2Handle(app.FminObjField.Value,'x');
                x0 = app.safeNumArray(app.FminX0Field.Value);
                if isempty(x0)
                    error('opt:gui:badX0','Initial guess required');
                end
                if ~isempty(strtrim(app.FminConstrField.Value))
                    cFun = app.safeExpr2Handle(app.FminConstrField.Value,'x');
                else
                    cFun = @(x) [];
                end
            catch ME
                app.FminLogArea.Value = ['[' ME.identifier '] ' ME.message]; return;
            end
            % simple penalty
            penF = @(x) f(x) + 1e3*sum(max(cFun(x),0));
            opts = optimset('Display','off');
            [xOpt,fval,~,out] = fminsearch(penF,x0,opts);
            app.FminResultTable.Data = {xOpt(1), xOpt(2), fval};
            app.FminLogArea.Value = sprintf('Iters: %d  FuncCount: %d',out.iterations,out.funcCount);
        end

        function exportFmin(app)
            % Export fmincon result to MAT file (placeholder)
            data = app.FminResultTable.Data;
            assignin('base','fmincon_result',data);
            app.FminLogArea.Value = [app.FminLogArea.Value; {'Exported to workspace variable ''fmincon_result''.'}];
        end

        function runLunar(app)
            % Simple collocation placeholder demonstrating plots
            N = app.LunarNField.Value;
            t = linspace(0,1,N+1); % time scaled 0-1
            alt = 1 - 0.5*t.^2;     % altitude decreasing
            speed = 1 - t;          % speed decreasing
            thrust = 0.5*ones(size(t)); % constant thrust
            mass = 1 - 0.1*t;       % mass decreasing
            plot(app.LunarAltAxes,t,alt);
            plot(app.LunarSpeedAxes,t,speed);
            plot(app.LunarThrustAxes,t,thrust);
            plot(app.LunarMassAxes,t,mass);
            minAlt = min(alt);
            fuelUsed = mass(1)-mass(end);
            app.LunarSummaryTable.Data = {t(end), fuelUsed, mass(end), minAlt};
        end

        function exportLunar(app)
            % Export lunar solution to MAT file (placeholder)
            assignin('base','lunar_solution',app.LunarSummaryTable.Data);
        end

        function loadPresetCallback(app)
            %LOADPRESETCALLBACK  Select a preset MAT file and populate controls.
            %   Invoked when the Load Preset button is pressed.  In
            %   interactive mode, a file chooser is displayed.  In
            %   headless mode (Visible off), this method does nothing.
            if strcmp(app.UIFigure.Visible,'off')
                % headless: do nothing
                return;
            end
            [file, path] = uigetfile('*.mat','Select GUI preset');
            if isequal(file,0)
                return;
            end
            full = fullfile(path,file);
            try
                app.loadPreset(full);
            catch ME
                uialert(app.UIFigure,['Failed to load preset: ' ME.message],'Preset Error');
            end
        end

        function loadPreset(app, filename)
            %LOADPRESET  Load a MAT preset file and set control values.
            %   app.loadPreset(FILENAME) loads the MAT file which should
            %   contain a single struct variable.  Each field name
            %   corresponds to the Tag of a control and the value is
            %   assigned to the control's Value or String property.
            s = load(filename);
            % Assume the struct is the first field
            fn = fieldnames(s);
            if isempty(fn)
                error('opt:gui:presetEmpty','No variables in preset');
            end
            preset = s.(fn{1});
            fns = fieldnames(preset);
            for i = 1:numel(fns)
                tag = fns{i};
                val = preset.(tag);
                % set property on matching Tag
                try
                    % find matching property by comparing Tag
                    comp = app.findComponentByTag(tag);
                    if isempty(comp)
                        continue;
                    end
                    % Determine which property to set
                    if isa(comp,'matlab.ui.control.EditField') && ~isempty(val)
                        comp.Value = val;
                    elseif isa(comp,'matlab.ui.control.NumericEditField') && ~isempty(val)
                        comp.Value = val;
                    elseif isa(comp,'matlab.ui.control.DropDown') && ~isempty(val)
                        comp.Value = val;
                    end
                catch
                    % ignore failures quietly
                end
            end
            % update x1 enable state based on method
            toggleX1(app);
        end

        function comp = findComponentByTag(app, tag)
            %FINDCOMPONENTBYTAG Return component handle with given Tag
            comps = [app.FunctionField, app.DerivativeField, app.MethodDropDown,...
                app.X0Field, app.X1Field, app.TolField, app.MaxIterField,
                app.SolveButton, app.ResultLabel, app.StatusLabel, app.HistoryAxes,
                app.FField, app.JField, app.XVecField, app.StrategyDropDown,
                app.AlphaField, app.BetaField, app.C1Field, app.C2Field,
                app.LSMaxIterField, app.SolveSystemButton, app.LSStatusLabel,
                app.HistoryAxes2, app.RunBarrierButton, app.BarrierTable,
                app.BarrierStatusLabel, app.BarrierAxes, app.FminObjField,
                app.FminX0Field, app.FminConstrField, app.FminAlgDropDown,
                app.FminRunButton, app.FminExportButton, app.FminResultTable,
                app.FminLogArea, app.LunarNField, app.LunarObjDropDown,
                app.LunarRunButton, app.LunarExportButton, app.LunarAltAxes,
                app.LunarSpeedAxes, app.LunarThrustAxes, app.LunarMassAxes,
                app.LunarSummaryTable];
            comp = [];
            for c = comps
                if strcmp(c.Tag, tag)
                    comp = c;
                    return;
                end
            end
        end

        function h = safeExpr2Handle(app,str,var)
            % Safely convert expression string to function handle
            if isempty(strtrim(str))
                error('opt:gui:emptyExpr','Expression cannot be empty');
            end
            allowed = '0123456789+-*/.^()[]; :,xv';
            expr = strtrim(str);
            if ~all(ismember(expr, allowed))
                error('opt:gui:badExpr','Expression contains invalid characters');
            end
            h = str2func(['@(' var ') ' expr]);
        end

        function vec = safeNumArray(app,str)
            % Parse numeric array from string into column vector
            try
                vec = eval(str);
                if ~isnumeric(vec)
                    error('opt:gui:notNumeric');
                end
                vec = vec(:);
            catch
                error('opt:gui:badNumArray','Invalid numeric array');
            end
        end

    end
end