classdef test_gui_functional < matlab.unittest.TestCase
    %TEST_GUI_FUNCTIONAL Functional tests for the optimisation GUI.
    %   These tests exercise the root solvers and line search via the
    %   wrappers.optimizationGUI function.  They run only when a desktop
    %   environment is available; otherwise they are skipped.
    methods(Test)
        function newtonPath(testCase)
            if ~usejava('desktop')
                testCase.assumeFail('GUI not available on CI');
            end
            import matlab.uitest.TestCase as UITestCase;
            uiTC = UITestCase.forInteractiveUse;
            app = wrappers.optimizationGUI(struct('Visible','off'));
            testCase.addTeardown(@() delete(app.UIFigure));
            % fill inputs
            uiTC.type(app.FunctionField,'x.^2 - 2');
            uiTC.type(app.DerivativeField,'2*x');
            uiTC.choose(app.MethodDropDown,'Newton');
            uiTC.type(app.X0Field,1);
            uiTC.press(app.SolveButton);
            pause(0.2);
            % parse result
            txt = app.ResultLabel.Text;
            tokens = regexp(txt,'x = ([^,]+)','tokens','once');
            testCase.verifyNotEmpty(tokens,'Result string missing root');
            xVal = str2double(tokens{1});
            testCase.verifyLessThan(abs(xVal - sqrt(2)),1e-8);
        end

        function secantPath(testCase)
            if ~usejava('desktop')
                testCase.assumeFail('GUI not available on CI');
            end
            import matlab.uitest.TestCase as UITestCase;
            uiTC = UITestCase.forInteractiveUse;
            app = wrappers.optimizationGUI(struct('Visible','off'));
            testCase.addTeardown(@() delete(app.UIFigure));
            uiTC.type(app.FunctionField,'x.^2 - 2');
            uiTC.type(app.DerivativeField,'');
            uiTC.choose(app.MethodDropDown,'Secant');
            uiTC.type(app.X0Field,1);
            uiTC.type(app.X1Field,2);
            uiTC.press(app.SolveButton);
            pause(0.2);
            txt = app.ResultLabel.Text;
            tokens = regexp(txt,'x = ([^,]+)','tokens','once');
            testCase.verifyNotEmpty(tokens);
            xVal = str2double(tokens{1});
            testCase.verifyLessThan(abs(xVal - sqrt(2)),1e-8);
        end

        function lineSearchArmijo(testCase)
            if ~usejava('desktop')
                testCase.assumeFail('GUI not available on CI');
            end
            import matlab.uitest.TestCase as UITestCase;
            uiTC = UITestCase.forInteractiveUse;
            app = wrappers.optimizationGUI(struct('Visible','off'));
            testCase.addTeardown(@() delete(app.UIFigure));
            % Input Rosenbrock system
            uiTC.type(app.FField,'[1 - v(1); 100*(v(2)-v(1)^2)]');
            uiTC.type(app.JField,'[-1, 0; -200*v(1), 100]');
            uiTC.type(app.XVecField,'[-1.2; 1]');
            uiTC.choose(app.StrategyDropDown,'Armijo');
            uiTC.type(app.AlphaField,0.25);
            uiTC.type(app.BetaField,0.5);
            uiTC.type(app.LSMaxIterField,5);
            uiTC.press(app.SolveSystemButton);
            pause(0.2);
            % verify step between 0 and 1
            txt = app.LSStatusLabel.Text;
            tok = regexp(txt,'step = ([^, ]+)','tokens','once');
            testCase.verifyNotEmpty(tok);
            stepVal = str2double(tok{1});
            testCase.verifyGreaterThan(stepVal,0);
            testCase.verifyLessThanOrEqual(stepVal,1);
            % verify residual decreases
            if ~isempty(app.HistoryAxes2.Children)
                ydata = app.HistoryAxes2.Children(1).YData;
                testCase.verifyLessThan(ydata(end),ydata(1));
            end
        end

        function lineSearchWolfe(testCase)
            if ~usejava('desktop')
                testCase.assumeFail('GUI not available on CI');
            end
            import matlab.uitest.TestCase as UITestCase;
            uiTC = UITestCase.forInteractiveUse;
            app = wrappers.optimizationGUI(struct('Visible','off'));
            testCase.addTeardown(@() delete(app.UIFigure));
            uiTC.type(app.FField,'[1 - v(1); 100*(v(2)-v(1)^2)]');
            uiTC.type(app.JField,'[-1, 0; -200*v(1), 100]');
            uiTC.type(app.XVecField,'[-1.2; 1]');
            uiTC.choose(app.StrategyDropDown,'Strong Wolfe');
            uiTC.type(app.AlphaField,0.25);
            uiTC.type(app.BetaField,0.5);
            uiTC.type(app.C1Field,1e-4);
            uiTC.type(app.C2Field,0.9);
            uiTC.type(app.LSMaxIterField,5);
            uiTC.press(app.SolveSystemButton);
            pause(0.2);
            % check step positive and ≤1
            txt = app.LSStatusLabel.Text;
            tok = regexp(txt,'step = ([^, ]+)','tokens','once');
            testCase.verifyNotEmpty(tok);
            stepVal = str2double(tok{1});
            testCase.verifyGreaterThan(stepVal,0);
            testCase.verifyLessThanOrEqual(stepVal,1);
            % check residual decrease
            if ~isempty(app.HistoryAxes2.Children)
                ydata = app.HistoryAxes2.Children(1).YData;
                testCase.verifyLessThan(ydata(end),ydata(1));
            end
        end

        function barrierSmoke(testCase)
            % Smoke test for barrier tab
            if ~usejava('desktop')
                testCase.assumeFail('GUI not available on CI');
            end
            import matlab.uitest.TestCase as UITestCase;
            uiTC = UITestCase.forInteractiveUse;
            app = wrappers.optimizationGUI(struct('Visible','off'));
            testCase.addTeardown(@() delete(app.UIFigure));
            % Press run barrier and wait
            uiTC.press(app.RunBarrierButton);
            pause(0.5);
            % Verify table has some rows and status label updated
            data = app.BarrierTable.Data;
            testCase.verifyGreaterThan(size(data,1),0);
            testCase.verifyNotEqual(app.BarrierStatusLabel.Text,'');
        end

        function fminSmoke(testCase)
            % Smoke test for fmincon tab using fminsearch penalty
            if ~usejava('desktop')
                testCase.assumeFail('GUI not available on CI');
            end
            import matlab.uitest.TestCase as UITestCase;
            uiTC = UITestCase.forInteractiveUse;
            app = wrappers.optimizationGUI(struct('Visible','off'));
            testCase.addTeardown(@() delete(app.UIFigure));
            % Provide simple quadratic objective and starting guess
            uiTC.type(app.FminObjField,'(x(1)-1)^2 + (x(2)-2)^2');
            uiTC.type(app.FminX0Field,'[0;0]');
            uiTC.type(app.FminConstrField,'');
            uiTC.press(app.FminRunButton);
            pause(0.5);
            data = app.FminResultTable.Data;
            % Expect 1 row of result
            testCase.verifyEqual(size(data,1),1);
            % fval near minimum (0)
            testCase.verifyLessThan(data{1,3},0.1);
        end

        function lunarSmoke(testCase)
            % Smoke test for lunar tab
            if ~usejava('desktop')
                testCase.assumeFail('GUI not available on CI');
            end
            import matlab.uitest.TestCase as UITestCase;
            uiTC = UITestCase.forInteractiveUse;
            app = wrappers.optimizationGUI(struct('Visible','off'));
            testCase.addTeardown(@() delete(app.UIFigure));
            uiTC.type(app.LunarNField,5);
            uiTC.press(app.LunarRunButton);
            pause(0.5);
            % Check that summary table has 1 row and altitude plot lines exist
            data = app.LunarSummaryTable.Data;
            testCase.verifyEqual(size(data,1),1);
            % verify altitude axes has line
            testCase.verifyNotEmpty(app.LunarAltAxes.Children);
        end
    end
end