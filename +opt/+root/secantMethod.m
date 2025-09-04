function [x, info] = secantMethod(f, x0, x1, opts)
%SECANTMETHOD  Secant method for 1‑D root finding.
%   [x,info] = opt.root.secantMethod(f, x0, x1, opts) attempts to find
%   a zero of the scalar function f using two initial guesses X0 and X1.
%   Unlike Newton's method, the secant method does not require the
%   derivative but approximates it using successive function values.
%
%   Example:
%       f = @(x) x.^3 - x - 2;
%       [root,info] = opt.root.secantMethod(f, 1.0, 2.0, struct('tol',1e-10));
%       % root ≈ 1.52138
%
%   Inputs:
%     f      - function handle returning f(x)
%     x0,x1  - scalar initial guesses for the iteration
%     opts   - struct with optional fields:
%              tol      : tolerance on |f(x)| and step size (default 1e-10)
%              maxIter  : maximum iterations (default 50)
%
%   Outputs:
%     x      - approximate root
%     info   - struct with fields similar to opt.root.newtonMethod

    if nargin < 4
        opts = struct;
    end
    defaultOpts.tol = 1e-10;
    defaultOpts.maxIter = 50;
    opts = opt.utils.parseOptions(opts, defaultOpts);

    x_prev = x0;
    x = x1;
    f_prev = f(x_prev);
    f_curr = f(x);
    history = zeros(opts.maxIter+1, 1);
    history(1) = x_prev;
    history(2) = x;
    converged = false;
    k = 2;
    for iter = 1:opts.maxIter
        if abs(f_curr) < opts.tol
            converged = true;
            break;
        end
        denom = f_curr - f_prev;
        if denom == 0
            % Named warning for degenerate slope in secant method.  Tests
            % may suppress this via warning('off','opt:root:secant:ZeroSlope').
            warning('opt:root:secant:ZeroSlope','Zero slope in secant method; terminating');
            break;
        end
        dx = -f_curr * (x - x_prev) / denom;
        x_new = x + dx;
        if abs(dx) < opts.tol
            x = x_new;
            converged = true;
            k = k + 1;
            history(min(k, opts.maxIter+1)) = x;
            break;
        end
        % shift
        x_prev = x;
        f_prev = f_curr;
        x = x_new;
        f_curr = f(x);
        k = k + 1;
        history(min(k, opts.maxIter+1)) = x;
    end
    info.iterations = k - 1;
    info.converged = converged;
    info.fval = f_curr;
    info.grad = NaN;
    info.history = history(1:k);
end