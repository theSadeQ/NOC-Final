function [x, info] = newtonMethod(f, df, x0, opts)
%NEWTONMETHOD  Newton's method for 1‑D root finding.
%   [x,info] = opt.root.newtonMethod(f, df, x0, opts) attempts to find
%   a zero of the scalar function f using its derivative df.  X0 is the
%   initial guess.  OPTS may specify tolerances and limits (see below).
%
%   Example:
%       f  = @(x) x.^2 - 2;
%       df = @(x) 2*x;
%       [root,info] = opt.root.newtonMethod(f, df, 1.0, struct('tol',1e-10));
%       % root ≈ sqrt(2)
%
%   Inputs:
%     f      - function handle returning f(x)
%     df     - derivative handle returning f'(x)
%     x0     - scalar initial guess
%     opts   - struct with optional fields:
%              tol      : tolerance on |f(x)| and step size (default 1e-10)
%              maxIter  : maximum number of iterations (default 50)
%
%   Outputs:
%     x      - approximate root
%     info   - struct with fields:
%              iterations : number of iterations performed
%              converged  : true if convergence criteria met
%              fval       : function value at the final iterate
%              grad       : derivative at the final iterate
%              history    : vector of iterates

    if nargin < 4
        opts = struct;
    end
    defaultOpts.tol = 1e-10;
    defaultOpts.maxIter = 50;
    opts = opt.utils.parseOptions(opts, defaultOpts);

    x = x0;
    history = zeros(opts.maxIter, 1);
    converged = false;
    for k = 1:opts.maxIter
        history(k) = x;
        fx = f(x);
        dfx = df(x);
        if abs(fx) < opts.tol
            converged = true;
            break;
        end
        if dfx == 0
            % Throw a package-specific error if derivative is zero.  This
            % allows client code and tests to detect the failure mode via
            % the MException identifier.  See test_root_newtonMethod.
            error('opt:root:newton:ZeroDerivative','Derivative is zero; cannot proceed with Newton method');
        end
        dx = -fx / dfx;
        xnew = x + dx;
        if abs(dx) < opts.tol
            x = xnew;
            converged = true;
            k = k + 1;
            history(min(k, opts.maxIter)) = x;
            break;
        end
        x = xnew;
    end
    info.iterations = k;
    info.converged = converged;
    info.fval = f(x);
    info.grad = df(x);
    info.history = history(1:k);
end