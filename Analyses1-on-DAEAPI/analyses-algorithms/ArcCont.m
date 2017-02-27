function ArcContObj = ArcCont(g_h, dg_dxLambda_h, g_args, ArcContParms)
%ArcContObj = ArcCont(g_h, dg_dxLambda_h, g_args, ArcContParms)
%
% Runs arclength continuation from lambda = 0 (or ArcContParms.StartLambda) 
% to lambda = 1 (or ArcContParms.StopLambda).  Uses NR (which is MPPI NR).
%
% g_h: handle to function g(x,lambda), to be solved for g(x,lambda=1) = 0.
%      should be callable as: g = feval(g_h, [x;lambda], g_args).
%      g and x should be of column vectors of size n; lambda should be size 1.
%
% dg_dxLambda_h: handle to function [dg/dx; dg/dlambda].
%      should be callable as: dg_dy = feval(dg_dxLambda_h, [x;lambda], g_args).
%      dg_dy should be a matrix of size n x (n+1)
%
% g_args: passed directly to g_h and dg_dxLambda_h
% 
% ArcContParms: parameters for arclength continuation
%	ArcContParms.StartLambda (default is 0).
%	ArcContParms.StopLambda (default is 1);
%	ArcContParms.initDeltaLambda: default is 0.01. Initial step length is chosen
%		to make make lambda change by approximately this amount.
%	ArcContParms.maxDeltaLambda: default 0.05. Maximum lambda change allowed
%       per continuation step.
%	ArcContParms.MaxArcLength: max arclength, after which to stop.
%		default: Inf => continue forever.
%	ArcContParms.MaxLambda: max lambda; if lambda goes over this, stop.
%		default: Inf 
%	ArcContParms.MinLambda: min lambda; if lambda goes under this, stop.
%		default: -Inf 
%	ArcContParms.dbglvl: 
%	ArcContParms.NRparms: for MPPI newton corrector
%	ArcContParms.tranparms: transient parms for arclength continuation.
%		Note that only explicit methods (currently only FE) are
%		usable for arclength continuation.
%	ArcContParms.tangent_via_SVD: 
%		0 (default) => use rectangular LU factorization for tangent calculation
%		1 => use null() (SVD based) for tangent calculation
%	ArcContParms.rankdrop_reltol:
%	ArcContParms.rankdrop_abstol:
%		reltol and abstol for figuring out whether the rank of U has dropped 
%       more than 1 during tangent vector calculation. If any diagonal entry
%       of U is < reltol*max(abs(diag(U))) + abstol, it is considered to be
%       zero.
%	ArcContParms.dotprod_abstol: if the dot product of the tangent with the
%       previous tangent is less than this, then tangent_function declares an
%       error
%	ArcContParms.deltasIncreaseFactor: default 1.5. this controls how much the
%       MPPINR corrector's corrected solution is allowed to go over the
%       arclength step TODO: update ArcContAnalysis such that these parms when
%       can be specified when setting that up
%
% Arclength continuation relies on:
%	- NR (uses it for MPPI NR solves)
%	- DAEAPI (sets up the arclength continuation DAE)
%	- LMS (for doing the tracking using FE + MPPI NR corrector)
%
% ArcContObj is the returned object. It contains the following fields/methods:
%	ArcContObj.tangent_function
%		usage: [tangent, success] = feval(ArcContObj.tangent_function, 
%                                                      [x;lambda], ArcContObj)
%	ArcContObj.priorTangent:
%	ArcContObj.MPPINR_corrector:
%	ArcContObj.solve:
%		usage: [sol, NRiters, success] = solve(ArcContObj, initguess)
%		sol contains the fields: .spts, .yvals, .finalSol
%
% Call LMS to solve the homotopy differential equation, but modify it first:
% - first, set up a homotopy DAE as as DAEAPI object (DONE as ArcContDAE, but
%   not tested yet)
%   - call LMS to solve this with method FE (serving as predictor and not 
%     requiring derivatives of the RHS); plus a "corrector" routine that
%     should be supplied externally (this would be MPPI Newton for arclength
%     continuation. The corrector call could look like this: 
%	     xnew = feval(corrector, xnew, tnew, correctorargs);
% - LMS should be able to call a "corrector" routine (by default empty) at the
%   end of each step. (DONE, not tested)
%   - there should be timestep control based on success/failure of the
%     corrector routine, too. (DONE, not tested)
% - currently, LMS is set up to stop at a specific, given, time. There should
%   be a more general stopping criterion: call a routine to see whether to
%   stop, providing it the current timepoint and current solution.  This is
%   needed for arclength continuation. The more general stopping criterion
%   could look like this:
%       while 1 == 1 {
%	    ...
%	    stop = feval(stopping_criterion, xnew, tnew, stopping_criterion_args);
%	    if 1 == stop
%	    	break;
%	    end
%       } (DONE, not tested)
%
% The flow of ArclengthContinuation:
%
% 1. Set lambda = StartLambda and call NR to solve it. This is the starting 
%    point.
% 2. Compute the tangent vector at the starting point by solving for the null
%    space of the Jacobian matrix.  Choose the direction of increasing lambda.
% 3. Set up the ArclengthContinuation differential equation in DAEAPI format:
%    - arclength continuation differential equation: dg(x,lambda)/ds = 
%      tangent( dg_dxLambda(x,lambda) );
%      - note: core eqn to be solved: g(x,lambda) = 0
%    - a tangent routine needs to be set up: tangent( Jg, previous_tangent )
%      - simply calculate the null space of Jg, normalize to 1 and choose the
%        direction that makes the dot product with the previous tangent +ve.
% 4. Solve the ArclengthContinuation differential equation with initial
%    condition the starting point, and run it until lambda > 1. Use LMS with
%    additional hooks for this.
%    - an ending criterion needs to be set up: lambda > 1.
% 5. Endgame: then interpolate between the last two points to find an
%    approximate solution for lambda=1; run
%    NR of g(x, 1) with that initial guess to find the solution.
%
% We need a convenient way to set up a new DAEAPI object with supplied
%    function handles for q, f, B, etc.
%
% How can we do this?
% - make a DAE: ArcContODE.m specialized for Arclength Continuation, so we
%   don't need derivatives, noise, outputs, inputs, etc..
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Type "help MAPPlicense" at the MATLAB/Octave prompt to see the license      %
%% for this software.                                                          %
%% Author: J. Roychowdhury, 2011/11/25, 2015/05/31                             %
%% Copyright (C) 2008-2020 Jaijeet Roychowdhury <jr@berkeley.edu>. All rights  %
%%               reserved.                                                     %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

	if nargin < 3
		error('nargin < 3');
	end

	ArcContObj.g_h = g_h;
	ArcContObj.dg_dxLambda_h = dg_dxLambda_h;
	ArcContObj.g_args = g_args;

	if nargin > 3
		ArcContObj.ArcContParms = ArcContParms;
	else
		% set up defaults for ArcContParms.
		ArcContParms.StartLambda = 0;
		ArcContParms.StopLambda = 1;
		ArcContParms.initDeltaLambda = 0.01;
		ArcContParms.maxDeltaLambda = 0.05;
		ArcContParms.MaxArcLength = Inf;
		ArcContParms.MaxLambda = Inf;
		ArcContParms.MinLambda = -Inf;
		ArcContParms.dbglvl = 2; % TODO: implement info/warnings/errors

		%ArcContParms.NRparms 	%for MPPI newton corrector
		ArcContParms.NRparms = defaultNRparms();
		ArcContParms.NRparms.maxiter=20;
		ArcContParms.NRparms.reltol=1e-8;
		ArcContParms.NRparms.abstol=1e-14;
		ArcContParms.NRparms.residualtol=1e-13;
		ArcContParms.NRparms.MPPINR_use_pinv=1; % use pinv, not mldivide 
                                % - slow (SVD), but does find MLS solution
		ArcContParms.NRparms.limiting=0;
		ArcContParms.NRparms.dbglvl=1;
		ArcContParms.NRparms.method=0; % use regular NR, not SPICE-like 
                                       % rhs based NR

		%TODO: ArcContParms.tranparms: transient parms for arclength 
        % continuation.
		%currently using mostly default LMS parms
		dummyODE = ArcContDAE('dummyODE', 1, @tangent_function, []);
		arclenTrans = LMS(dummyODE); % by default, this is BE
		ArcContParms.FEparms = arclenTrans.FEparms;
		ArcContParms.tranparms = arclenTrans.tranparms;

		ArcContParms.tangent_via_SVD = 1;
			%0 (default) => use rectangular LU factorization for tangent 
            %  calculation
			%1 => use null() (SVD based) for tangent calculation
		ArcContParms.rankdrop_reltol = 1e-6;
		ArcContParms.rankdrop_abstol = 1e-12;
            % reltol and abstol for figuring out whether the rank of U has
            % dropped more than 1 during tangent vector calculation. If any
            % diagonal entry of U is < reltol*max(abs(diag(U))) + abstol, it is
            % considered to be zero.
		ArcContParms.dotprod_abstol = 0.5; % FIXME: this does not currently 
                                           % affect LMS 
		ArcContParms.deltasIncreaseFactor = 1.5; % Inf; % this controls how 
                             % much the MPPINR corrector's
							 % corrected solution is allowed to go over the
							 % arclength step 
							 % TODO: update ArcContAnalysis such that these 
                             % parms when can be specified when setting that
                             % up
		ArcContObj.ArcContParms = ArcContParms;
	end

	ArcContObj.solve_successful = 0; % solve has not been called yet
	ArcContObj.sol = []; % 
	ArcContObj.totNRiters = 0; % 

	ArcContObj.contODE = 'undefined'; % solve should set this up

	% set up function pointers for access
	ArcContObj.solve = @ArcContTracking; 
	% quick usage help for solve (during ArcContObj display)
	ArcContObj.solveUsage='ArcContObj =feval(ArcContObj.solve, ArcContObj, initguess)';
	ArcContObj.getsolution = @getsolution;
	ArcContObj.getsolutionUsage='[spts, yvals, finalSol]=feval(ArcContObj.getsolution, ArcContObj)';
	% for debugging
	if ArcContParms.dbglvl > 1
		ArcContObj.tangent_function = @tangent_function;
		ArcContObj.g_at_fixed_lambda = @g_at_fixed_lambda;
		ArcContObj.dgdx_at_fixed_lambda = @dgdx_at_fixed_lambda;
		ArcContObj.MPPINR_corrector = @MPPINR_corrector;
	end
end % ArcCont constructor

function [tangent, success, J] = tangent_function(y, ArcContObj)
	% compute rectangular Jacobian matrix
	J = feval(ArcContObj.dg_dxLambda_h, y, ArcContObj.g_args);

	% now find null space of J. It should be of dimension 1;
	% if not, we have a bifurcation; abort and return 
	% success = -rank_deficiency.

	if 1 == ArcContObj.ArcContParms.tangent_via_SVD % via SVDs; 
                                                    % very inefficient
		tangent = null(full(J));
		if size(tangent, 2) > 1
			success = -size(tangent, 2);
			return;
		else
			success = 1;
		end
	else % do it by sparse LU factorization
		1 == 1;
		% TODO: implement this
	end

	% normalize it and give it the proper direction
	tangent = tangent/norm(tangent);
    %ArcContObj.priorTangent % debug: does this ever change? Yes, it does.
	dotprod = tangent' *ArcContObj.priorTangent; 
	if abs(dotprod) < ArcContObj.ArcContParms.dotprod_abstol
		success = 0; % FIXME: need to modify NR/LMS to understand g() eval 
                     % failure
	end
	if dotprod < 0
		tangent = -tangent;
	end
end % tangent_function

function out = g_at_fixed_lambda(x, NRg_args)
	out = feval(NRg_args.ArcContObj.g_h, [x; NRg_args.lambda], NRg_args.ArcContObj.g_args);
end % g_at_fixed_lambda

function Jout = dgdx_at_fixed_lambda(x, NRg_args)
	J = feval(NRg_args.ArcContObj.dg_dxLambda_h, [x; NRg_args.lambda], NRg_args.ArcContObj.g_args);
	Jout = J(:, 1:(end-1));
end % dgdx_at_fixed_lambda

function [newy, news, iters, success] = MPPINR_corrector(s, y, args)
	[newy, iters, success] = NR(args.g_h, args.dg_dxLambda_h, y, args.g_args, args.NRparms); % will need AFobj update
	if success ~= 1
		news = [];
		if args.dbglvl >= 1
			fprintf(2,'MPPINR_corrector failed\n');
		end
		return;
	end

	% estimate the arc length between y and ynew
	% for now: just straight-line Euclidean distance

	oldy = args.xold;
	olds = args.told;
	intended_delta = s-olds;
	deltas = norm(newy-oldy);
	% check that the achieved deltaS wasn't too large
	if (deltas >= args.deltasIncreaseFactor)
		success = -1;
		news = [];
		if args.dbglvl >= 1
			fprintf(2,'MPPINR_corrector found too faraway a point\n');
		end
		return;
	end
	% check that the step in lambda wasn't too large:
	oldlambda = oldy(end,1);
	newlambda = newy(end,1);
	if (abs(newlambda-oldlambda) >= args.maxDeltaLambda)
		success = -2;
		news = [];
		if args.dbglvl >= 1
			fprintf(2,'MPPINR_corrector: delta lambda too large (%g)\n', ...
                                                         newlambda-oldlambda);
		end
		return;
	end
	news = olds + deltas;
	if args.dbglvl >= 2
		fprintf(2,'MLS-NR step OK: %s=%g, %s=%g, %s=%g\n', ...
                   'lambda', newy(end,1), ...
                   'deltas', deltas, ...
                   'tots', news);
	end
	% later: we have the tangents at both points. So 
	% we should be able to fit a cubic polynomial between
	% the two points (with an indep variable that goes from
	% zero to 1 between the two points. Then, using the
	% cubic formula, we should be able to get an analytical
	% expression for the arclength?
end % MPPINR_corrector

function objOut = ArcContTracking(ArcContObj, initguess)
%function objOut = ArcContTracking(ArcContObj, initguess)
%on successful completion, sets up:
%Objout.solve_successful
%Objout.totNRiters
%ObjOut.sol
%	sol.spts
%	sol.yvals
%	sol.finalSol

	totNRiters = 0;

	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	% run NR at lambda=lambdaStart to find the initial solution
	NRg_args.lambda = ArcContObj.ArcContParms.StartLambda; 
    NRg_args.ArcContObj = ArcContObj;
	[initsol, iters, success] = NR(@g_at_fixed_lambda, @dgdx_at_fixed_lambda, initguess, NRg_args, ArcContObj.ArcContParms.NRparms); % AFobj change needed
	if success ~= 1
		error(sprintf('ArcCont: initial NR at lambda=%g failed', NRg_args.lambda));
	end
	totNRiters = totNRiters + iters;

    % use NR's xscaling feature to get NR to scale the lambda component for convergence checks. May be useful if lambda is very big or very small compared to x.
    xscaling = ArcContObj.ArcContParms.NRparms.xscaling;
    if 1 == length(xscaling) 
        xscaling = xscaling*ones(length(initguess)+1, 1);
    else % already a vector
        xscaling(end+1,1) = ArcContObj.ArcContParms.StopLambda;
    end
    ArcContObj.ArcContParms.NRparms.xscaling = xscaling;

	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	% find and set the initial prior tangent vector
	ArcContObj.priorTangent = zeros(length(initguess),1);
	if ArcContObj.ArcContParms.StartLambda < ArcContObj.ArcContParms.StopLambda
		ArcContObj.priorTangent(end+1,1) = 1; % tangent_function will thus 
                     % ensure that the last entry (ie, dlambda/ds) will be
                     % positive
	else
		ArcContObj.priorTangent(end+1,1) = -1; % tangent_function will thus 
                     % ensure that the last entry (ie, dlambda/ds) will be
                     % negative
	end
	saved_dotprod = ArcContObj.ArcContParms.dotprod_abstol;
	ArcContObj.ArcContParms.dotprod_abstol = 1e-6;
    if ArcContObj.ArcContParms.dbglvl >= 2
	    [tangent, success, J] = tangent_function([initsol; ArcContObj.ArcContParms.StartLambda], ArcContObj); % may need AFobj change
        ArcContObj.priorDetSign = sign(det([J; tangent'])); % used by ArcContDAE::DAEupdateFuncPerTimepoint to notify if a bifurcation has been stepped over.
    else
	    [tangent, success] = tangent_function([initsol; ArcContObj.ArcContParms.StartLambda], ArcContObj); % may need AFobj change
    end
	if success ~= 1
		error('ArcCont: tangent_function failed at starting point.');
	end
	% TODO: should check that last entry is significantly positive
	if ArcContObj.ArcContParms.dbglvl >= 2
		fprintf(2,'lambda component of initial tangent vector: %g\n', ...
                                                            tangent(end,1));
	end
	ArcContObj.priorTangent = tangent;
	ArcContObj.ArcContParms.dotprod_abstol = saved_dotprod;

	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	% set up ArcContDAE
	n = length(initsol);
	if n <= 0
		error('ArcCont: n <= 0');
	end
	ArcContObj.contODE = ArcContDAE('contODE', n, @tangent_function,   ArcContObj);
	ArcContObj.contODE.funcargs = ArcContObj; % ugly hack needed because ^^^ 
                                              % this changed in the above call

	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	% set up an LMS object for running the continuation

	FEparms = ArcContObj.ArcContParms.FEparms; % we are going to use FE
	tranparms = ArcContObj.ArcContParms.tranparms; % set up in constructor
    tranparms.useAFobjForNR = 0; % use the old NR interface (don't use AFobj)
	tranparms.StepControlParms.doStepControl = 1; % step control

	% tranparms.NRparms may also need special settings
	tranparms.correctorFunc = @MPPINR_corrector; % will need AFobj update
	correctorFuncArgs.g_h = ArcContObj.g_h;
	correctorFuncArgs.dg_dxLambda_h = ArcContObj.dg_dxLambda_h;
	correctorFuncArgs.g_args = ArcContObj.g_args;
	correctorFuncArgs.NRparms = ArcContObj.ArcContParms.NRparms;
	correctorFuncArgs.told = 'undefined'; % LMS needs to set this up before 
                                          %     calling the corrector
	correctorFuncArgs.xold = 'undefined'; % LMS needs to set this up before 
                                          %     calling the corrector
	correctorFuncArgs.dbglvl = ArcContObj.ArcContParms.dbglvl;
	correctorFuncArgs.deltasIncreaseFactor = ArcContObj.ArcContParms.deltasIncreaseFactor;
	correctorFuncArgs.maxDeltaLambda = ArcContObj.ArcContParms.maxDeltaLambda;
	tranparms.correctorFuncArgs = correctorFuncArgs;

	tranparms.stopFunc = @(s, y, arg) ...
        (y(end,1)-arg.StopLambda)*((arg.StopLambda > arg.StartLambda)*2-1) ...
            >= 0 ...
        || s >= arg.MaxArcLength ...
        || y(end,1) > arg.MaxLambda ...
        || y(end,1) < arg.MinLambda;
	stopFuncArgs.StartLambda = ArcContObj.ArcContParms.StartLambda;
	stopFuncArgs.StopLambda = ArcContObj.ArcContParms.StopLambda;
	stopFuncArgs.MaxArcLength = ArcContObj.ArcContParms.MaxArcLength;
	stopFuncArgs.MaxLambda = ArcContObj.ArcContParms.MaxLambda;
	stopFuncArgs.MinLambda = ArcContObj.ArcContParms.MinLambda;
	tranparms.stopFuncArgs = stopFuncArgs;

	%tranparms.trandbglvl = 3;

	arclenTrans = LMS(ArcContObj.contODE, FEparms, tranparms); % FE with MPPI corrector and a stop func (supplied through tranparms)

	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	% choose an initial s-step
	% FIXME: this should be made much better: find the max rate of change, 
    %        limit max individual x component change using a reltol-abstol
    %        criterion.
	initialstep = abs(ArcContObj.ArcContParms.initDeltaLambda/tangent(end,1));

	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	% run arclength continuation and get the solution
	arclenTrans = feval(arclenTrans.solve, arclenTrans, [initsol; ArcContObj.ArcContParms.StartLambda], ArcContObj.ArcContParms.StartLambda, initialstep); % no tstop=>will
                                                                                                                                                           % use stopFunc
	[spts, yvals] = feval(arclenTrans.getsolution, arclenTrans);
	totNRiters = totNRiters + arclenTrans.totNRiters;

    % check if normal termination, or if MaxArcLength or Max/MinLambda exceeded
    last_s = spts(end); last_lambda = yvals(end, end);
    abnormal_termination = (last_s >= ArcContObj.ArcContParms.MaxArcLength) || (last_lambda >= ArcContObj.ArcContParms.MaxLambda) ||  (last_lambda <= ArcContObj.ArcContParms.MinLambda);

    if ~abnormal_termination
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % "endgame": interpolate between last two lambdas to predict solution at
        % lambda=StopLambda, then run NR to find the solution
        l2 = yvals(end,end); x2 = yvals(1:(end-1),end);
        l1 = yvals(end,end-1); x1 = yvals(1:(end-1),end-1);
        m = (ArcContObj.ArcContParms.StopLambda > ArcContObj.ArcContParms.StartLambda)*2 - 1; % 1 or -1
        if m*(l2-ArcContObj.ArcContParms.StopLambda) < 0 || m*(l1-ArcContObj.ArcContParms.StopLambda) >= 0 || m*(l2 - l1) <= 0
            error('ArcCont: l2 < StopLambda || l1 >= StopLambda || l2-l1 <= 0');
        end
        % linear interpolation to find NR initguess
        factor = (ArcContObj.ArcContParms.StopLambda-l1)/(l2-l1); % FIXME: do 
                         % this using interp1, which should have error checking
        finalsolguess = x1 + (x2-x1)*factor;
        % set up and run NR at StopLambda
        NRg_args.lambda = ArcContObj.ArcContParms.StopLambda; 
        NRg_args.ArcContObj = ArcContObj;
        % FIXME: could change NRparms here, eg, increase maxiter
        %
        % shorten xscaling vector if it is already set up
        xscaling = ArcContObj.ArcContParms.NRparms.xscaling;
        if length(xscaling) == length(finalsolguess) + 1
            xscaling = xscaling(1:end-1);
        end
        ArcContObj.ArcContParms.NRparms.xscaling = xscaling;
        [finalSol, iters, success] = NR(@g_at_fixed_lambda, @dgdx_at_fixed_lambda, finalsolguess, NRg_args, ArcContObj.ArcContParms.NRparms); % needs change for AFobj
        if success ~= 1
            fprintf(2, 'ArcCont: final NR at lambda=StopLambda failed; returning solution at last lambda');
            finalSol = finalsolguess;
        end
        totNRiters = totNRiters + iters;
    else % abnormal_termination
        finalSol = 'not valid - terminated before reaching StopLambda';
	    if ArcContObj.ArcContParms.dbglvl >= 2
		    fprintf(2,'ArcCont terminated abnormally: MaxArclength/MaxLambda/MinLambda reached.\n'); 
            fprintf(2,'\t finalSol has not been set.\n');
        end
	end

	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	% return solution
	ArcContObj.solve_successful = success; % TODO: needs proper fixing
	ArcContObj.totNRiters = totNRiters;
	ArcContObj.sol.spts = spts;
	ArcContObj.sol.yvals = yvals;
	ArcContObj.sol.finalSol = finalSol;

	objOut = ArcContObj;
end % ArcContTracking / solve

function [spts, yvals, finalSol] = getsolution(ArcContObj)
	if 1 == ArcContObj.solve_successful
		spts = ArcContObj.sol.spts;
		yvals = ArcContObj.sol.yvals;
		finalSol = ArcContObj.sol.finalSol;
	else
		if dbglvl > 1
			fprintf(2,'ArcCont: run solve (succesfully) first!\n');
		end
		spts = [];
		yvals = [];
		finalSol = [];
	end
end % getSolution
