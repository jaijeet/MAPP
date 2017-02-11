function [solution, iters, success, AFobjPreComputedStuff] = NR(varargin)
%function [sol, iters, success, allNRpts] = NR(f_handle, df_handle, initGuess,
%                                                           funcparms, NRparms)
% OR
%function [solution, iters, success, AFobjPreComputedStuff] = NR(AFobj, NRparms,
%                                                                   initGuess)
%
%Solve f(x) = 0 using the Newton-Raphson algorithm.
%
%If invoked as 
%   NR(f_handle, df_handle, initGuess, funcparms, NRparms),
%f is called as feval(f_handle, x, funcparms).
%
%Arguments (first form NR(f_handle, df_handle, initGuess, funcparms, NRparms)):
%   f_handle: fn ptr to evaluate f(x), ie,
%       - fx = feval(f_handle, x, funcparms) should return f(x)
%       - [fx, success] = feval(fhandle, x, funcparms) is also supported
%                           (detected automatically)
%   df_handle: fn ptr to evaluate dg_dx, ie,
%       - J = feval(df_handle, x, funcparms) should return the Jacobian
%             matrix df_dx(x)
%       - [J, success] = feval(df_handle, x, funcparms) is also supported
%                       (detected automatically)
%       - if df_handle == [], then f_handle should return both f(x) and df_dx,
%           ie,
%           [fx, dfdx] = feval(f_handle, x, funcparms) 
%               or
%           [fx, dfdx, success] = feval(f_handle, x, funcparms) 
%       - In the above, success, if returned, should be 1 if evaluation of g/J
%         is successful.
%   initguess: initial guess for NR
%   funcparms: passed as last argument to f_handle/df_handle
%   NRparms:   (optional). If supplied, it should be a struct with 
%              fields defined in defaultNRparms.m. If not supplied,
%              defaultNRparms() is called internally to set up
%              NRparms. See help defaultNRparms.
%
%Return values:
%   sol:       the NR solution if converged; NaN if not converged.
%   iters:     (optional) the number of iterations taken.
%   success:   (optional) 1 if converged, 0 if not converged.
%   allNRpts:  (optional) a matrix with x at every NR iterate. The ith column
%                         of the matrix is the ith iterate; i=1 is the initial
%                         guess. 
%
%%%%%%%%%%%%%
%If invoked as 
%              NR(AFobj, NRparms, initGuess), 
%f(x) is specified within the argument AFobj, which is a structure returned by
%AlgebraicFunction (help AlgebraicFunction for usage). You can call 
%f(x, funcparms) and df_dx(x, funcparms) via:
%    feval(AFobj.f, x, funcparms) and feval(AFobj.df, x, funcparms).
%
%Arguments:
%   AFobj: Algebraic Function object. To see the fields it contains, run:
%       help AlgebraicFunction;
%       
%   NRparms is optional.  If supplied, it should be a struct with fields
%       coresponding to defaultNRparms.m. Important fields are reltol, abstol
%       and maxiter.
%       To see the fields it contains, run:
%       help defaultNRparms;
%   
%   initGuess (optional) is an initial guess for Newton-Raphson. If not
%      specified, it is taken to be all zeros, unless initialization
%      is in effect.
%   
%Return values:
%   sol:                    the NR solution if converged; NaN if not converged.
%   iters:                  (optional) the number of iterations taken.
%   success:                (optional) 1 if converged, 0 if not converged.
%   AFobjPreComputedStuff:  (optional) struct that contains internal information
%                               of the algebraic function (AFobj)
%            .allpts:       (optional) if supplied, then all the points in the
%                               NR sequence will be returned - as a matrix (each
%                               column is an NR iterate).
%                                [TODO: NOT SUPPORTED USING THE SECOND CALLING
%                                SYNTAX].
%            .fqterm:       (optional) Store the f/q function evaluation which
%                           can be used to reduce redundant evaluation of f/q in
%                           transient analysis
%            .Jacobian:     (TODO: This can be used to implement jacobian
%                            bypass)
%
%Notes
%-----
%
%0. The basic NR iteration implemented here is:
%       delta_x = - df(x_i) \ f(x_i) 
%       x_{i+1} = x_i + delta_x
%
%1. Convergence is declared if EITHER a reltol-abstol criterion on norm(deltax)
%   OR an absolute tolerance criterion on norm(f(x)) is satisfied.  Ie,
%   convergence is declared if
%    norm(deltax) <= reltol*norm(x)+abstol 
%       OR
%    norm(residual) <= residualtol.
%   Set NRparms.reltol and NRparms.abstol to control the deltax convergence
%   criterion and NRparms.residualtol to control the residual convergence
%   criterion.
%
%2. For matrix solution (ie, to solve J deltax = - f), NR normally uses Matlab's
%   \ (backslash or mldivide) operator, which solves sparse systems
%   efficiently. However, it is useful mostly when the system f(x) to be
%   solved is square (ie, equal numbers of equations and unknowns), although
%   it can work for non-square systems too.
%
%3. If the number of unknowns in x is greater than the number of equations in g,
%   it can be useful to tell NR to use Matlab's pinv() function to solve 
%   J deltax = - g, by setting NRparms.MPPINR_use_pinv=1. pinv() implements
%   the Moore-Penrose Pseudo Inverse (MPPI). Newton-Raphson with MPPI updates
%   has useful properties for solving non-square systems (for example, it is
%   used in Euler-Newton curve tracing).
%   [TODO: NOT SUPPORTED USING THE SECOND CALLING SYNTAX].
%
%4. NR uses norms of vectors for determining convergence. It is therefore
%   important that entries of x and the residual are well scaled to values 
%   that are roughly of the order of 1.
%
%5. Initialization and limiting heuristics are supported via facilities in
%   AFobj. See help topic for NRinitlimiting for details.
%
%6. When using the second calling syntax, this routine also supports a
%   SPICE-like NR algorithm:
%   x = df(x) \ RHS(x)
%   This representation of NR algorithm is used when NRparms.method == 1.
%
%
%Examples (calling syntax NR(f_handle, df_handle, initGuess, funcparms, NRparms)
%-------------------------------------------------------------------------------
%
% % 2-d system of equations: straight line intersecting circle
%ghandle = @(x, args) [x(1)^2 + x(2)^2 - args.circleradius^2; x(1) + x(2)];
%dghandle = @(x, args) [2*x(1), 2*x(2); 1, 1];
%args.circleradius = 1;
% % first solution
%[sol1, iters1, success1] = NR(ghandle, dghandle, [-1;1], args);
% % second solution
%[sol2, iters2, success2] = NR(ghandle, dghandle, [1;-1], args);
%
% % show more detail about the progress of NR; plot error vs iteration number
%NRparms = defaultNRparms();
% % help defaultNRparms
%NRparms.dbglvl=2;
%[sol, iters, success, allNRpts] = NR(ghandle, dghandle, [-1;1], args, NRparms);
%[nr, nc] = size(allNRpts);
%errors = allNRpts - sol*ones(1,nc);
%errnorms = sqrt(sum(errors.^2,1));
%logerrornorms = log10(errnorms+1e-18);
%stem(logerrornorms, 'b.-');
%xlabel('NR iteration number'); ylabel('log10(error)'); grid on;
%title('error vs NR iteration');
%
%
% % other functions to try:
% % simple tanh function: f(x) = tanh(k*x)
%tanhfunc = @(x, k) tanh(k*x); dtanhfunc = @(x, k) k*(1-tanh(k*x).^2);
%[sol, iters, success, allNRpts] = NR(tanhfunc, dtanhfunc, 1.09, 1, NRparms); % diverges
%[sol, iters, success, allNRpts] = NR(tanhfunc, dtanhfunc, 1.0875, 1, NRparms); % converges
% % f(x) = x^2 - 4
%xsqrM4 = @(x, ~) x^2 - 4; dxsqrM4 = @(x, ~) 2*x; 
%[sol, iters, success, allNRpts] = NR(xsqrM4, dxsqrM4, 3, [], NRparms); % quadratic convergence
% % f(x) = x^3
%xcubed = @(x, ~) x^3; dxcubed = @(x, ~) 3*x^2; 
%[sol, iters, success, allNRpts] = NR(xcubed, dxcubed, 3, [], NRparms); % linear (slow) convergence
%
%Examples (calling syntax NR(AFobj, NRparms, initGuess))
%-------------------------------------------------------
%
% % 1. create an AF object from DAE:
%
% % set up DAE
% DAE = MNA_EqnEngine(SHringosc3_ckt);
%
% % perform a QSS analysis through AF object
% uDC = DAE.uQSS(DAE);
% f_df_rhs_handle = @(x, args) deal(args.DAE.f(x, uDC, args.DAE), ...
%      args.DAE.df_dx(x, uDC, args.DAE), ...
%      args.DAE.df_dx(x, uDC, args.DAE) * x - args.DAE.f(x, uDC, args.DAE), ...
%      [], 1);
% % Note that this f_df_rhs function handle is normally set up in analyses
% % instead of manually. Here we coded it manually only to demonstrate how AF
% % works in general
%
% AFO = AlgebraicFunction(f_df_rhs_handle, DAE);
%
% NR(AFO)
%
% % 2. create an AF object from scratch:
% AFO = AlgebraicFunction_skeleton();
% 
% % let this AF represent a simple function: f(x) = x^2 - 1
% AFO.n_unks = 1;
% AFO.n_eqns = 1;
% AFO.n_limitedvars = 0;
% AFO.f_df_rhs = @(x, args) deal(x^2-1, 2*x, x^2+1, [], 1);
% 
% % use NR to solve for one of the solutions
% NR(AFO, defaultNRparms, 0.5)
%
% % update AF object to represent a slightly more complicated function:
% % Consider a diode whose current can be calculated as Id = diode_Id(Vd).
% % Drive this diode with a current source of 1A such that Id=1A, solve for Vd. 
% % The AF for this circuit will be f(x) = diode_Id(x) - 1.
% VT = 0.025;
% IS = 1e-12;
% diode_Id = @(Vd) IS * (exp(Vd/VT)-1);
% diode_Gd = @(Vd) IS/VT * exp(Vd/VT);
%
% AFO.f_df_rhs = @(x, args) deal(diode_Id(x) - 1, ...
%         diode_Gd(x), ...
%         diode_Gd(x) * x - diode_Id(x) + 1, ...
%         [], 1);
%
% % use NR to solve for the solution
% NRparms = defaultNRparms;
% NR(AFO, NRparms, 0.6)
%
% % use NR to solve for the solution from another initial guess
% NR(AFO, NRparms, 0.5)
% % It failed as the f(x) in this AF object doesn't have good numerical
% % properties.
%
% % update AF object to use limiting, e.g. pnjlim
% AFO.n_limitedvars = 1;
% 
% VCRIT = VT*log(VT/(sqrt(2)*IS));
% AFO.f_df_rhs = @(x, args) deal(diode_Id(pnjlim(args.xlimOld, x, VT, VCRIT)) - 1, ...
%         diode_Gd(pnjlim(args.xlimOld, x, VT, VCRIT)), ...
%         diode_Gd(pnjlim(args.xlimOld, x, VT, VCRIT)) * pnjlim(args.xlimOld, x, VT, VCRIT) ...
%         - diode_Id(pnjlim(args.xlimOld, x, VT, VCRIT)) + 1, ...
%         pnjlim(args.xlimOld, x, VT, VCRIT), 1);
%
% % use NR to solve for the solution from initial guess where it failed previously
% NR(AFO, NRparms, 0.5)
%
% % use NR to solve for the solution from an even "worse" initial guess
% NR(AFO, NRparms, 0)
%
%See also
%--------
%
%defaultNRparms, mldivide, pinv, QSS, dot_op, AlgebraicFunction, 
%NRinitlimiting (TODO)
%
%
%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Type "help MAPPlicense" at the MATLAB/Octave prompt to see the license      %
%% for this software.                                                          %
%% Copyright (C) 2008-2013 Jaijeet Roychowdhury <jr@berkeley.edu>. All rights  %
%% reserved.                                                                   %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%Changelog:
%---------
%2014/05/13: Bichen Wu <bichen@berkeley.edu> Modification to improve the
%             efficiency of transient analysis.
%2014/03/03: Jaijeet Roychowdhury <jr@berkeley.edu> Fixed the out-of-date
%            help; made it backward compatible to the old calling syntax
%            (ie, without AFobj).
%2013/01/08: Tianshi Wang <tianshi@berkeley.edu>: restructured the whole file,
%            added SPICE-styled RHS-based NR, added init/limiting and AFobj
%2008/sometime: Jaijeet Roychowdhury <jr@berkeley.edu>

    orig_calling_syntax = isa(varargin{1}, 'function_handle');

    if 1 == orig_calling_syntax
        % Bichen: allpts should be a member of other struct
        % [solution, iters, success, other.allpts] = NR_orig(varargin{:});
        [solution, iters, success, allpts] = NR_orig(varargin{:});
        AFobjPreComputedStuff = allpts;
    else
        [solution, iters, success, AFobjPreComputedStuff] = NR_tianshi(varargin{:});
        if ~isempty(AFobjPreComputedStuff)
            AFobjPreComputedStuff.allpts = [];
        end
    end
end % NR

% local/private function
function [solution, iters, success, allpts] = NR_orig(ghandle, dghandle, ...
                                                        initguess, ...
                                                        funcparms, NRparms)
    if (nargin < 5)
        NRparms = defaultNRparms();
    end

    maxiter=NRparms.maxiter;
    reltol=NRparms.reltol;
    abstol=NRparms.abstol;
    residualtol=NRparms.residualtol;
    dbglvl=NRparms.dbglvl;

    x = initguess;
    tolerance = norm(x)*reltol + abstol;
    dx = 2*tolerance;
    g = 2*residualtol;

    iter = 0;
    if 4 == nargout 
        allpts(:,iter+1) = x;
    end

    if (dbglvl > 1)
        fprintf(2,'Iter %d: |x|=%g\n', iter, norm(x));
    end

    %{
    global HBdebuglvl; % REMOVE
    HBdebuglvl = 1; % REMOVE
    %}

    while ((norm(dx)>tolerance || norm(g)>residualtol) && (iter<maxiter))
    %while ((norm(dx)>tolerance && norm(g)>residualtol) && (iter<maxiter))
        %{
        if iter > 0 
            HBdebuglvl = 0;
        end
        %}
        [g, J, evalsuccess] = evalgJ(ghandle, dghandle, x, funcparms); % local function
        if 1 ~= evalsuccess
            if dbglvl > -1
                fprintf(2,'\nNR: g/J() eval did not succeed, aborting.\n');
            end
            iters = iter;
            solution = NaN;
            success = 0; % TODO: error codes for different types of errors
            return;
        end

        %size(x)
        %size(g)
        %size(J)
        %dx = -inv(J)*g;
        
        % solve J deltax = -g
        % doesn't work with warnings: try catch MATLAB:singularMatrix
        lastwarn(''); % clear prior warnings

        % difference between pinv and mldivide (from Mathworks
        % webpage): When the system A*x = b is overdetermined, both
        % algorithms provide the same answer. When the system is
        % underdetermined, PINV will return the solution x, that has
        % the minimum norm (min NORM(x)). MLDIVIDE will pick the
        % solution with least number of non-zero elements. 
        [nr, nc] = size(J);
        % try this: Ron's idea: conserve v*i product across steps
        % STA would be easier: have access to v and i for all devices.
        % Key question: how to modify the step to do this conservation?
        %
        if (nr == nc) || 0 == NRparms.MPPINR_use_pinv 
            dx = -J\g;  % use mldivide. when nc > nr, finds 
                    % a sparse solution (not a minimum norm one)
        else % nr != nc && 1 == NRparms.MPPINR_use_pinv 
            dx = -pinv(full(J))*g;  % use pinv - uses SVD =>
                                    % inefficient, but does find
                                    % the minimum norm solution 
                                    % when nc > nr
        end

        [lastmsg, lastid] = lastwarn;
        if 1 == strcmp(lastid,'MATLAB:singularMatrix')
            if dbglvl > -1
                fprintf(2,'\nNR: Jacobian is singular, aborting.\n');
            end
            success = 0;
            iters = iter;
            solution = NaN;
            return;
        end

        %TODO: REMOVE
        if dbglvl > 1 
            fprintf('x=[');
            for c = 1:length(x)
                if c ~= length(x)
                    fprintf('%g,', x(c));
                else
                    fprintf('%g]\n', x(c));
                end 
            end 
        end 
        x = x + dx; iter = iter+1;
        if 4 == nargout 
            allpts(:,iter+1) = x;
        end
        if (dbglvl > 1)
            fprintf(2,'Iter %d: |newx|=%g, |dx|=%g, |g(oldx)|=%g\n',iter,norm(x),norm(dx),norm(g));
        end

        tolerance = norm(x)*reltol + abstol;
        if (iter > 1) && (dbglvl > 0) 
            fprintf(1,'.');
        end
    end % of while
    
    if (iter == maxiter)
        solution = NaN;
        iters=maxiter;
        if dbglvl > -1
            fprintf(2,'\nNR failed to solve nonlinear equations - reached maxiter=%d\n', maxiter);
        end
        success = 0;
    else
        if sum(isnan(x)) > 0
            success = -1;
            if (dbglvl>-1)
                fprintf(2,'\nNR appeared to complete, but contains NaN entries.\n');
            end
        else
            success = 1;
            if (dbglvl>1)
                fprintf(2,'\nNR succeeded in %d iterations\n', iter);
            end
        end
        solution = x;
        iters = iter;
        if dbglvl > 0 
            fprintf(1,'*');
            if 1 == NRparms.terminating_newline
                fprintf(1,'\n');
            end
        end
    end
end % end of NR_orig

% local/private function
function [solution, iters, success, AFobjPreComputedStuff] = NR_tianshi(AFobj, NRparms, initGuess)
    if nargin < 2 || isempty(NRparms)
        NRparms = defaultNRparms();
    end
    dNRparms = defaultNRparms();
    % assign NRparms
    maxiter=optget(NRparms, 'maxiter', dNRparms.maxiter);
    reltol=optget(NRparms, 'reltol', dNRparms.reltol);
    abstol=optget(NRparms, 'abstol', dNRparms.abstol);
    residualtol=optget(NRparms, 'residualtol', dNRparms.residualtol);
    limiting=optget(NRparms, 'limiting', dNRparms.limiting);
    init=optget(NRparms, 'init', dNRparms.init);
    dbglvl=optget(NRparms, 'dbglvl', dNRparms.dbglvl);
    method=optget(NRparms, 'method', dNRparms.method);
    % 
    nunks = feval(AFobj.nunks, AFobj);
    neqns = feval(AFobj.neqns, AFobj);
    nlimitedvars = feval(AFobj.nlimitedvars, AFobj);
    % set up initGuess
    if nargin < 3 || isempty(initGuess)
        if ~init
            if dbglvl > -1
            warning('No initial Guess, no initialization, initial guess set to 0, may be problems!\n');
            end
        end
        initGuess = zeros(nunks, 1);
    end
    % NR begins
    x = initGuess;
    xlimOld = zeros(nlimitedvars, 1);
    AFobj = feval(AFobj.set_xlimOld, xlimOld, AFobj);
    tolerance = norm(x)*reltol + abstol;
    dx = 2*tolerance;
    fx = 2*residualtol;

    iter = 1;

    % print
    if (dbglvl > 1)
        fprintf(2,'Iter %d: |x|=%g\n', iter, norm(x));
    end
    AFobj = feval(AFobj.set_init, init, AFobj);
    AFobj = feval(AFobj.set_limit, limiting, AFobj);
    % NR iteration begins
    while ((norm(dx)>tolerance || norm(fx)>residualtol) && (iter<maxiter))
    %while ((norm(dx)>tolerance && norm(g)>residualtol) && (iter<maxiter))
        switch method
        case 0
            if dbglvl > 1 
                fprintf('x=[');
                for c = 1:length(x)
                    if c ~= length(x)
                        fprintf('%g,', x(c));
                    else
                        fprintf('%g]\n', x(c));
                    end 
                end 
            end 
            [fx, dfx, xlimOld, evalsuccess] = feval(AFobj.f_and_df, x, AFobj); 
            AFobjPreComputedStuff = [];
            AFobj = feval(AFobj.set_xlimOld, xlimOld, AFobj);
            if 1 ~= evalsuccess
                if dbglvl > -1
                    fprintf(2,'\nNR: g/J() eval did not succeed, aborting.\n');
                end
                iters = iter;
                solution = NaN;
                success = 0; % TODO: error codes for different types of errors
                return;
            end % if not evalsuccess
            lastwarn(''); % clear prior warnings
        
            % support for MPPINR - JR, 2014/06/26
            [nr, nc] = size(dfx);
            if (nr == nc) || 0 == NRparms.MPPINR_use_pinv 
                dx = -dfx\fx;  % use mldivide. when nc > nr, finds 
                    % a sparse solution (not a minimum norm one)
            else % nr != nc && 1 == NRparms.MPPINR_use_pinv 
                dx = -pinv(full(dfx))*fx;  % use pinv - uses SVD => inefficient, 
                        % but does find the minimum norm solution when nc > nr
            end

            [lastmsg, lastid] = lastwarn;
            if 1 == strcmp(lastid,'MATLAB:singularMatrix')
                if dbglvl > -1
                    fprintf(2,'\nNR: Jacobian is singular, aborting.\n');
                end
                success = 0;
                iters = iter;
                solution = NaN;
                return;
            end
            x = x + dx; iter = iter+1;
            if (dbglvl > 1)
                fprintf(2,'Iter %d: |newx|=%g, |dx|=%g, |g(oldx)|=%g\n',...
                iter,norm(x),norm(dx),norm(fx));
            end
            tolerance = norm(x)*reltol + abstol;
            if (iter > 1) && (dbglvl > 0) 
                fprintf(1,'.');
            end
            if 2 == iter && 1==init
                if 0 == feval(AFobj.get_init, AFobj)
                    AFobj = feval(AFobj.set_init, 1, AFobj);
                    AFobj = feval(AFobj.set_limit, 0, AFobj);
                    iter = 1; % redo iter1 with init_on
                else
                    % recover from initialization
                    AFobj = feval(AFobj.set_init, 0, AFobj);
                    AFobj = feval(AFobj.set_limit, limiting, AFobj);
                end
            end % if within first iter and init
        case 1 % SPICE-NR
            if dbglvl > 1 
                fprintf('x=[');
                for c = 1:length(x)
                    if c ~= length(x)
                        fprintf('%g,', x(c));
                    else
                        fprintf('%g]\n', x(c));
                    end 
                end 
            end 

            AFobj.LMS_add_on.iter = iter;
            % [fx, dfx, rhsx, xlimOld, evalsuccess] = feval(AFobj.f_df_rhs, x, AFobj); 
            if nargout(AFobj.f_df_rhs) == 6
                [fx, dfx, rhsx, xlimOld, evalsuccess, AFobjPreComputedStuff] = feval(AFobj.f_df_rhs, x, AFobj); 
                % TODO: AFobjPreComutedStuff can also include Jacobian, which
                % can be useful to implement Jacobian Bypass
                AFobj.PreComputedStuff = AFobjPreComputedStuff;
            else
                [fx, dfx, rhsx, xlimOld, evalsuccess] = feval(AFobj.f_df_rhs, x, AFobj); 
                AFobjPreComputedStuff = [];
            end
            AFobj = feval(AFobj.set_xlimOld, xlimOld, AFobj);
            if 1 ~= evalsuccess
                if dbglvl > -1
                    fprintf(2,'\nNR: g/J() eval did not succeed, aborting.\n');
                end
                iters = iter;
                solution = NaN;
                success = 0; % TODO: error codes for different types of errors
                return;
            end % if not evalsuccess
            lastwarn(''); % clear prior warnings

            % support for MPPINR - JR, 2014/06/26
            [nr, nc] = size(dfx);
            if (nr == nc) || 0 == NRparms.MPPINR_use_pinv 
                newx = dfx\rhsx;  % use mldivide. when nc > nr, finds 
                    % a sparse solution (not a minimum norm one)
            else % nr != nc && 1 == NRparms.MPPINR_use_pinv 
                dx = pinv(full(dfx))*rhsx;  % use pinv - uses SVD => inefficient, 
                        % but does find the minimum norm solution when nc > nr
            end

            iter = iter+1;
            dx = newx - x; x = newx;
            [lastmsg, lastid] = lastwarn;
            if 1 == strcmp(lastid,'MATLAB:singularMatrix')
                if dbglvl > -1
                    fprintf(2,'\nNR: Jacobian is singular, aborting.\n');
                end
                success = 0;
                iters = iter;
                solution = NaN;
                return;
            end
            if (dbglvl > 1)
                fprintf(2,'Iter %d: |newx|=%g, |dx|=%g, |g(oldx)|=%g\n',...
                iter,norm(x),norm(dx),norm(fx));
            end
            tolerance = norm(x)*reltol + abstol;
            if (iter > 1) && (dbglvl > 0) 
                fprintf(1,'.');
            end
            if 2 == iter && 1==init
                if 0 == feval(AFobj.get_init, AFobj)
                    AFobj = feval(AFobj.set_init, 1, AFobj);
                    AFobj = feval(AFobj.set_limit, 0, AFobj);
                    iter = 1; % redo iter1 with init_on
                else
                    % recover from initialization
                    AFobj = feval(AFobj.set_init, 0, AFobj);
                    AFobj = feval(AFobj.set_limit, limiting, AFobj);
                end
            end % if within first iter and init
        end % switch
    end % while
    
    if (iter == maxiter)
        solution = NaN;
        iters=maxiter;
        if dbglvl > -1
            fprintf(2,'\nNR failed to solve nonlinear equations - reached maxiter=%d\n', maxiter);
        end
        success = 0;
    else
        if sum(isnan(x)) > 0
            success = -1;
            if (dbglvl>-1)
                fprintf(2,'\nNR appeared to complete, but contains NaN entries.\n');
            end
        else
            success = 1;
            if (dbglvl>1)
                fprintf(2,'\nNR succeeded in %d iterations\n', iter);
            end
        end
        solution = x;
        iters = iter;
        if dbglvl > 0 
            fprintf(1,'*');
        end
    end % iter==maxiter
end % end of tianshi_NR

function [g, J, evalsuccess] = evalgJ(ghandle, dghandle, x, funcparms); 
    % local/private function 
    if isa(dghandle, 'function_handle')
        if 2 == nargout(ghandle)
            [g, evalsuccess] = feval(ghandle,  x, funcparms);
        elseif 1 == nargout(ghandle) || -1 == nargout(ghandle)
            % nargout == -1 for anonymous functions
            g = feval(ghandle,  x, funcparms);
            evalsuccess = 1;
        else
            error('NR: nargout(ghandle) not 1 or 2');
        end

        % evaluate dg_dx
        if 2 == nargout(ghandle)
            [J, evalsuccess2] = feval(dghandle, x, funcparms);
            evalsuccess = evalsuccess & evalsucess2;
        elseif 1 == nargout(ghandle) || -1 == nargout(ghandle)
            J = feval(dghandle,  x, funcparms);
            evalsuccess = 1 & evalsuccess;
        else
            error('NR: nargout(dghandle) not 1 or 2');
        end
    else % dghandle is []
        if 3 == nargout(ghandle)
            [g, J, evalsuccess] = feval(ghandle,  x, funcparms);
        elseif 2 == nargout(ghandle)
            [g, J] = feval(ghandle,  x, funcparms);
            evalsuccess = 1;
        else
            error('NR: nargout(ghandle) not 2 or 3, and dghandle==[]');
        end
    end
end % end of evalgJ
