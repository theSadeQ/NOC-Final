function [x, info] = solve1D(f, df, bracketOrX0, opts)
%SOLVE1D  Robust 1‑D solver combining Newton, secant and bisection.
%   [x,info] = opt.root.solve1D(f, df, bracketOrX0, opts) attempts to
%   find a root of the scalar function f.  If bracketOrX0 is scalar,
%   Newton's method is tried first, then the secant method if Newton
%   fails.  If bracketOrX0 is a two‑element vector [a b] with f(a)*f(b)<0,
%   bisection may be used as a final fallback.  Options in OPTS are
%   forwarded to the underlying solvers.
%
%   Outputs:
%     x    - approximate root
%     info - struct with fields:
%            method    : 'newton', 'secant', or 'bisection'
%            converged : logical flag
%            (additional fields from the successful solver)
%
%   Example:
%       f  = @(x) x.^3 - x - 2;
%       df = @(x) 3*x.^2 - 1;
%       [root,info] = opt.root.solve1D(f, df, 1.5, struct('tol',1e-10));
%       % root ≈ 1.52138 using Newton or secant

    if nargin < 4 || isempty(opts)
        opts = struct;
    end
    info = struct('method','', 'converged',false);
    % Determine whether bracketOrX0 is scalar or bracket
    if isscalar(bracketOrX0)
        x0 = bracketOrX0;
        % Attempt Newton
        try
            [xn, infoN] = opt.root.newtonMethod(f, df, x0, opts);
            if isfield(infoN,'converged') && infoN.converged
                x = xn;
                info = infoN;
                info.method = 'newton';
                return;
            end
        catch
            % ignore errors and continue
        end
        % Attempt secant using a perturbed initial guess
        x1 = x0 + 0.5;
        try
            [xs, infoS] = opt.root.secantMethod(f, x0, x1, opts);
            if isfield(infoS,'converged') && infoS.converged
                x = xs;
                info = infoS;
                info.method = 'secant';
                return;
            end
        catch
            % ignore and continue
        end
        % No bracket provided; cannot perform bisection
        error('opt:root:solve1D:NoBracket', 'Bisection requires a bracket [a b] with opposite signs.');
    else
        % bracketOrX0 is treated as [a b]
        bracket = bracketOrX0;
        if numel(bracket) ~= 2
            error('opt:root:solve1D:InvalidBracket', 'Bracket must be a two-element vector [a b].');
        end
        a = bracket(1); b = bracket(2);
        fa = f(a); fb = f(b);
        % Attempt Newton at midpoint if bracket is also considered as starting point
        x0 = 0.5 * (a + b);
        try
            [xn, infoN] = opt.root.newtonMethod(f, df, x0, opts);
            if isfield(infoN,'converged') && infoN.converged
                x = xn;
                info = infoN;
                info.method = 'newton';
                return;
            end
        catch
        end
        % Attempt secant using midpoint and a perturbed value
        try
            [xs, infoS] = opt.root.secantMethod(f, x0, x0 + 0.5, opts);
            if isfield(infoS,'converged') && infoS.converged
                x = xs;
                info = infoS;
                info.method = 'secant';
                return;
            end
        catch
        end
        % Validate bracket for bisection
        if fa * fb > 0
            error('opt:root:solve1D:InvalidBracket', 'f(a) and f(b) must have opposite signs for bisection.');
        end
        % Set defaults for bisection-specific options
        if ~isfield(opts,'tol'), opts.tol = 1e-8; end
        if ~isfield(opts,'maxIter'), opts.maxIter = 100; end
        % Perform bisection
        for k = 1:opts.maxIter
            x = 0.5 * (a + b);
            fx = f(x);
            if abs(fx) <= opts.tol || 0.5*(b - a) <= opts.tol
                info.converged = true;
                info.method = 'bisection';
                info.iters = k;
                info.iterations = k;
                info.residualNorm = abs(fx);
                return;
            end
            if fa * fx < 0
                b = x;
                fb = fx;
            else
                a = x;
                fa = fx;
            end
        end
        % If loop finishes without convergence
        x = 0.5 * (a + b);
        info.converged = false;
        info.method = 'bisection';
        info.iters = opts.maxIter;
        info.iterations = opts.maxIter;
        info.residualNorm = abs(f(x));
        return;
    end
end