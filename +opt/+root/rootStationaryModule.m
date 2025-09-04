function rootStationaryModule()
%ROOTSTATIONARYMODULE  Demonstrate stationary point classification.
%   ROOTSTATIONARYMODULE() solves for the critical points of a sample
%   function f(x) and classifies them based on the second derivative.

    opt.utils.printHeader('Stationary Points Module');
    % Sample function f(x) = x^3 - 4*x; f'(x) = 3*x^2 - 4; f''(x) = 6*x
    f = @(x) x.^3 - 4*x;
    df = @(x) 3*x.^2 - 4;
    d2f = @(x) 6*x;
    % Initial guesses for stationary points
    guesses = [-2, 0, 2];
    for i = 1:numel(guesses)
        x0 = guesses(i);
        [x_star, info] = opt.root.newtonMethod(df, d2f, x0, struct('tol', 1e-8, 'maxIter', 20));
        if info.converged
            secondDeriv = d2f(x_star);
            if secondDeriv > 0
                typeStr = 'minimum';
            elseif secondDeriv < 0
                typeStr = 'maximum';
            else
                typeStr = 'inflection';
            end
            fprintf('Critical point at x = %.4f -> %s, f(x) = %.4f\n', x_star, typeStr, f(x_star));
        else
            fprintf('Failed to converge from initial guess %.2f\n', x0);
        end
    end
end