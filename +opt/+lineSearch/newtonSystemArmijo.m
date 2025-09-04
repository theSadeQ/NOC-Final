function [x, info] = newtonSystemArmijo(F, J, x0, opts)
%NEWTONSYSTEMARMIJO  Newton step with Armijo or strong Wolfe backtracking.
%   [x,info] = opt.lineSearch.newtonSystemArmijo(F,J,x0,opts) attempts to
%   solve F(x)=0 for a vector-valued nonlinear system via a Newton
%   direction coupled with either Armijo backtracking or strong Wolfe
%   conditions.  F returns a column vector of residuals and J returns
%   the Jacobian matrix.  X0 is the initial column vector guess.  OPTS
%   may contain the following fields:
%     tol            - residual norm tolerance (default 1e-8)
%     maxIter        - maximum number of iterations (default 50)
%     alpha          - Armijo parameter for sufficient decrease (default 0.25)
%     beta           - backtracking factor (default 0.5)
%     singularityTol - threshold for rcond(J) to detect singularity (default 1e-12)
%     wolfe          - logical flag to enforce strong Wolfe conditions (default false)
%     c1,c2          - Wolfe line search constants (defaults 1e-4 and 0.9 respectively)
%
%   The returned INFO struct contains:
%     iters        - number of iterations performed
%     converged    - true if the residual norm fell below tol
%     step         - step size used in the last line search (in (0,1])
%     history      - residual norms at each successful step
%     residualNorm - final residual norm (for backward compatibility)
%     iterations   - alias of iters (deprecated)
%     stepSize     - alias of step (deprecated)
%
%   Notes:
%     * info.step is the canonical step size field.  The alias info.stepSize is
%       DEPRECATED and will be removed in future releases.  Existing
%       clients should migrate to info.step.
%     * On detection of a singular or nearly singular Jacobian, this
%       function throws an MException with identifier 'opt:lineSearch:singularJ'.

    % Handle optional opts input
    if nargin < 4 || isempty(opts)
        opts = struct;
    end
    % Set default options if missing
    if ~isfield(opts, 'maxIter'),        opts.maxIter = 50; end
    if ~isfield(opts, 'tol'),            opts.tol     = 1e-8; end
    % Armijo-specific parameters
    if ~isfield(opts, 'alpha'),          opts.alpha   = 0.25; end
    if ~isfield(opts, 'beta'),           opts.beta    = 0.5;  end
    if ~isfield(opts, 'singularityTol'), opts.singularityTol = 1e-12; end
    % Wolfe-specific parameters
    if ~isfield(opts, 'wolfe'),          opts.wolfe   = false; end
    if ~isfield(opts, 'c1'),             opts.c1      = 1e-4; end
    if ~isfield(opts, 'c2'),             opts.c2      = 0.9;  end

    % Ensure the initial guess is a column vector
    x = x0(:);
    % Initialise info structure
    info = struct('iters', 0, 'converged', false, 'step', 1, 'history', []);

    for k = 1:opts.maxIter
        Fx = F(x);
        nrm = norm(Fx);
        % Check convergence based on residual norm
        if nrm <= opts.tol
            info.converged = true;
            info.iters = k - 1;
            % For compatibility with previous interface, record residual norm
            info.residualNorm = nrm;
            info.iterations   = info.iters;
            info.stepSize     = info.step;
            return;
        end
        Jx = J(x);
        % Compute reciprocal condition number to detect singularity
        rc = rcond(Jx);
        if ~isfinite(rc) || rc < opts.singularityTol
            error('opt:lineSearch:singularJ', ...
                  'Jacobian is singular/ill-conditioned (rcond=%g).', rc);
        end
        % Solve for Newton direction
        dx = -(Jx \ Fx);
        % Choose between Armijo and strong Wolfe line search
        if opts.wolfe
            % Strong Wolfe conditions
            phi0 = 0.5 * (Fx.' * Fx);
            g0   = Jx.' * Fx;
            gd0  = g0.' * dx;
            t = 1;
            while true
                x_try  = x + t * dx;
                Fx_try = F(x_try);
                phi    = 0.5 * (Fx_try.' * Fx_try);
                J_try  = J(x_try);
                gd     = (J_try.' * Fx_try).' * dx;
                % Check strong Wolfe conditions: sufficient decrease and curvature
                if (phi <= phi0 + opts.c1 * t * gd0) && (abs(gd) <= opts.c2 * abs(gd0))
                    break;
                end
                if t <= eps
                    break;
                end
                t = t * opts.beta;
            end
        else
            % Armijo backtracking on phi(x) = 1/2 * ||F(x)||^2
            phi0 = 0.5 * (Fx.' * Fx);
            g    = Jx.' * Fx;
            t = 1;
            while true
                x_try  = x + t * dx;
                Fx_try = F(x_try);
                phi    = 0.5 * (Fx_try.' * Fx_try);
                if phi <= phi0 + opts.alpha * t * (g.' * dx) || t <= eps
                    break;
                end
                t = t * opts.beta;
            end
        end
        % Update iterate
        x = x + t * dx;
        % Record step and history
        info.step = t;
        info.history(end+1,1) = norm(F(x)); %#ok<AGROW>
        info.iters = k;
    end
    % After loop, update residual norm and compatibility fields
    info.residualNorm = norm(F(x));
    info.iterations   = info.iters;
    info.stepSize     = info.step;
end