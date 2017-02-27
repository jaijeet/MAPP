function LMSobj = LMS(DAE, TRmethod, tranparms) % DAE=DAEAPIv6.2
%function LMSobj = LMS(DAE, TRmethod, tranparms)
%
%LMS is a generic implementation of Linear Multi-Step methods for DAE/ODE
%initial value solution (aka transient simulation).
%
%Arguments:
%  - DAE:       a DAEAPI object/structure describing a DAE. help DAEAPI for
%               more information.
%  
%  - TRmethod:  an integration method structure defined by LMSmethods(). 
%               For example:
%                   methods = LMSmethods(); TRmethod = methods.TRAP;
%               help LMSmethods for more information.
%  
%  - tranparms: a transient parameters structure as defined by
%               defaultTranParms(). Many important capabilities of LMS can be
%               utilized by appropriate settings in tranparms.  
%               help defaultTranParms for more information.
%
%Output:
%  - LMSobj: a LMS object/structure (with function handles defined for LMS
%            analysis on a DAE). LMSobj has the following fields:
%    
%            .solve (function handle). Runs transient timestepping (initial 
%                value solution of LMS.DAE) by calling
%                LMS::LMStimeStepping().  help LMS::LMStimeStepping for
%                more information and usage details.
%
%            .getSolution (function handle). (LMSobj.getsolution is identical). 
%                   Returns the solution obtained by a successful run of 
%                   LMSobj.solve(). Use: 
%                       [tpts, vals, jacobians] = feval(LMSobj.getSolution, ...
%                                                       LMSobj);
%                   jacobians is an optional output. LMSobj.[Gg]etsolution calls
%                   transient_skeleton::transient_getsolution(...).  help
%                   transient_skeleton::transient_getsolution for further
%                   details.
%
%            .updateDAE (function handle). Update the DAE in the LMS object.
%                   Useful, eg, if DAE parameters or inputs have been changed.
%                   Calls LMS::LMSupdateDAE(...).  help LMS::LMSupdateDAE for
%                   details and usage.
%
%            .plot (function handle). Plots results from a successful run of
%                   LMSobj.solve(). Basic usage: 
%                       feval(LMSobj.plot, LMSobj);
%                   Calls transient_skeleton::transient_plot(...), which can
%                   be called in many ways. 
%                   help transient_skeleton::transient_plot for further
%                   details and usage information.
%    
%Examples
%--------
%
% % set up DAE
% nsegs = 1; R = 1e3; C = 1e-6;
% DAE =  RClineDAEAPIv6('', nsegs, R, C);
% 
% % set transient input to the DAE
% utargs.A = 1; utargs.f=1e3; utargs.phi=0;
% utfunc = @(t, args) args.A*sin(2*pi*args.f*t + args.phi);
% DAE = feval(DAE.set_utransient, utfunc, utargs, DAE);
% 
% % set up LMS object
% TransObjBE = LMS(DAE); % default method is BE
% LMStranparms = defaultTranParms(); 
% TRmethods = LMSmethods(); % defines FE, BE, TRAP, and GEAR2 
% TransObjTRAP = LMS(DAE, TRmethods.TRAP, LMStranparms);
% 
% % run transient and plot
% xinit = 1;
% tstart = 0;
% tstep = 10e-6;
% tstop = 5e-3;
% TransObjTRAP = feval(TransObjTRAP.solve, TransObjTRAP, ...
%     xinit, tstart, tstep, tstop);
% [thefig, legends] = feval(TransObjTRAP.plot, TransObjTRAP);
%
% % multiple overlaid plots, and the use of StateOutputs
% souts = StateOutputs(DAE); % [] is a legal value for souts
% TransObjBE = feval(TransObjBE.solve, TransObjBE, xinit, tstart, ...
%             tstep, tstop);
% [thefig, legends] = feval(TransObjBE.plot, TransObjBE, souts, 'BE'); 
%                                    % BE plots
% %[thefig, legends] = feval(TransObjFE.plot, TransObjFE,  souts, 'FE', ...
% %                        'x-', thefig, legends); 
% %% FE plots, overlaid
% [thefig, legends] = feval(TransObjTRAP.plot, TransObjTRAP, souts, ...
%                 'TRAP', 'o-', thefig, legends, 2); 
% %help transientPlot to see all plot options
% % TRAP plots, overlaid
% title('BE and TRAP on RClineDAEAPIv6');
%
%See also
%--------
%
% defaultTranParms, LMSmethods, transient_skeleton::transient_plot, 
% transient_skeleton, transientPlot, utransient, set_utransient,
% dot_transient_BE, dot_transient_GEAR, dot_transient_TRAP, op, QSS, NR,
% analyses-algorithms, DAE_concepts, DAEAPI
%
%Notes
%-----
%The time-step control mechanism including both NR iter and LTE-based time
%control
%
%Further reading
%---------------
%(placeholder for Dahlquist's book)
%(placeholder for video tutorial on LMS methods)
%(placeholder for JR's NOW monograph)
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Type "help MAPPlicense" at the MATLAB/Octave prompt to see the license      %
%% for this software.                                                          %
%% Copyright (C) 2008-2013 Jaijeet Roychowdhury <jr@berkeley.edu>. All rights  %
%% reserved.                                                                   %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%Changelog:
%---------
%2014-07-02: Tianshi Wang <tianshi@berkeley.edu>: deleted nargin checks for f/q,
%            check for support_initlimiting flag of DAE instead
%2014-06-30: Bichen Wu <bichen@berkeley.edu>: add switch to turn on/off LMS
%             speedup. Search 'doSpeedup' to see detailed implementations.
%2014-05-12: Bichen Wu <bichen@berkeley.edu>: improved the efficiency of
%             transient analysis
%2014-02-07: Jian Yao <jianyao@berkeley.edu>: add LTE-based control method. 
%2014-02-02: Tianshi Wang <tianshi@berkeley.edu>: nargin checks for backward
%            compatibility with DAEAPIv6
%2013-11-12: Tianshi Wang <tianshi@berkeley.edu>: commented out init/limiting
%            for second release, because ring oscillator 3 seems to stop
%            oscillating after limiting.
%2013-10-01: Tianshi Wang <tianshi@berkeley.edu>: added init/limiting
%sometime ago: Jaijeet Roychowdury <jr@berkeley.edu> 
%
    if (nargin > 3) || (nargin < 1)
        fprintf(2,'LMS: error: too many or too few arguments.\n');
        help('LMS');
        return;
    end
    LMSobj = transient_skeleton(DAE); % set up basic structure and useful
                      % functions

    % usage and name strings
    LMSobj.Usage = help('LMS'); 
    % name is a function

    %
    LMSobj.name = @name;
    LMSobj.solve = @LMStimestepping;
    LMSobj.updateDAE = @LMSupdateDAE;
    LMSobj.Limiting = @TRANlimiting;

    TRmethods = LMSmethods(); 

    % for compatibility with already-written calls of LMS; should get rid
    % of this later
    LMSobj.FEparms = TRmethods.FE;
    LMSobj.BEparms = TRmethods.BE;
    LMSobj.TRAPparms = TRmethods.TRAP;
    LMSobj.GEAR2parms = TRmethods.GEAR2;
    %% end for historical compatibility

    if (nargin >= 2)
        LMSobj.TRmethod = TRmethod;
    else
        % default is BE
        LMSobj.TRmethod = TRmethods.BE;
        % printed below after trandbglvl set up: fprintf(2,'LMS: defaulting to BE.\n');
    end


    if (nargin >= 3)
        LMSobj.tranparms = tranparms;
    end

    if isa(LMSobj.tranparms.correctorFunc, 'function_handle')
        corrector_available = 1;
    else
        corrector_available = 0;
    end

    if LMSobj.tranparms.trandbglvl > 1
        fprintf(1,'LMS NR parms: maxiter=%d, reltol=%g, abstol=%g, residualtol=%g, limiting=%d.\n', ...
            tranparms.NRparms.maxiter, tranparms.NRparms.reltol, ...
            tranparms.NRparms.abstol, ...
            tranparms.NRparms.residualtol, ...
            tranparms.NRparms.limiting);
    end

    if (LMSobj.tranparms.trandbglvl > 1) && (nargin < 2)
        fprintf(2,'LMS: defaulting to BE.\n');
    end

    if (1 == LMSobj.tranparms.stepControlParms.doStepControl) && ...
                        (LMSobj.tranparms.trandbglvl < 2)
        LMSobj.tranparms.NRparms.dbglvl = -1; % don't yell if NR fails during timestepping.
    end

    testts = (LMSobj.TRmethod.order+1):-1:1; % eg, 3, 2, 1
    testbetas = feval(LMSobj.TRmethod.betasfunc, testts);
    if (0==testbetas(1) && (LMSobj.tranparms.trandbglvl > -1) && ...
                        (1 ~= corrector_available))
        fprintf(2,'LMS WARNING: explicit LMS method, WILL fail on DAEs unless dq_dx is full rank.\n');
    end

    LMSobj.totNRiters = 0; % for keeping track of the total number of NR
                   % iterations


    if 1 == LMSobj.tranparms.useAFobjForNR
        LMSobj.AFobj = AlgebraicFunction(@LMS_f_df_rhs, DAE); %TODO: document this
    end
end % LMS "constructor"






function LMSout = LMSupdateDAE(DAE, LMSobj)
%function LMSout = LMSupdateDAE(DAE, LMSobj)
%(this is a private function of LMS, but can be accessed via LMSobj.updateDAE)
%Updates LMSobj.DAE with the DAE argument, returns the updated LMS object.
%Useful if you have, eg, changed a parameter or input in the DAE.
%
%Example
%-------
%    % set transient input to the DAE
%    utargs.A = 1; utargs.f=1e3; utargs.phi=0;
%    utfunc = @(t, args) args.A*sin(2*pi*args.f*t + args.phi);
%    DAE = feval(DAE.set_utransient, utfunc, utargs, DAE);
%    LMSobj  = feval(LMSobj.updateDAE, DAE, LMSobj);
%
    LMSobj.DAE = DAE;
    LMSout = LMSobj;
end % LMSupdateDAE







function out = name(LMSobj)
%function out = name(LMSobj)
%  Returns the name of the LMS object.
    out = sprintf('%s LMS solver', LMSobj.TRmethod.name);
end % name









function LMSobjOUT = LMStimestepping(LMSobj, xinitcond, tstart, tstep, tstop, store_Jacobians)
%function LMSobjOUT = LMStimestepping(LMSobj, xinitcond, tstart, tstep, tstop,
%                                store_Jacobians)
%(this is a private function of LMS, but can be accessed as LMSobj.solve)
%LMStimeStepping runs time-stepping DAE/ODE solution on LMSobj.
%
%Arguments:
%  - LMSobj: the LMS structure/object
%  - xinitcond: initial condition for the time-stepping solution.
%        Note: consistency of the initial condition for DAEs is not
%        checked. Depending on the integration method used,
%        inconsistent initial conditions can result in completely
%        erroneous or non-useful simulations. (In particular, watch out
%        for TRAP). If you cannot ensure easily consistency of the
%        initial condition, it is recommended that you first run a few
%        small timesteps of an overdamped p=1 method (such as BE), then
%        follow with other integration methods.
%  - tstart: start time for the simulation.
%  - tstop: stop time for the simulation. 
%  - tstep: initial time-step for the simulation. Can change if timestep
%        control is enabled (see defaultTranParms).
%  - store_Jacobians (optional argument): valid values are 1 and 0 (default 0).
%        if set to 1, time stepping will store the DAE's Jacobians at each
%        timestep. These Jacobians can be accessed via LMSobj.getSolution().
%
%Outputs:
%  - LMSobjOUT: updated LMS object containing the time-stepping solution (if
%        successful). The solution can be accessed via
%        LMSobj.getSolution() and plotted using LMSobj.plot().
%
%Examples
%--------
%    % assuming LMSobj already set up; help LMS for an example
%     xinit = 1; tstart = 0; tstep = 10e-6; tstop = 5e-3;
%     LMSobj = feval(LMSobj.solve, LMSobj, xinit, tstart, tstep, tstop);
%    feval(LMSobj.plot, LMSobj);
%    [tpts, vals] = feval(LMSobj.getsolution, LMSobj);
%
%See also
%--------
%  LMS, defaultTranParms (in particular: timestep control, stop function and 
%                   corrector function options).
%
%
%

% or (TODO) function LMSobjOUT = LMStimestepping(LMSobj, 'continue', extra_t, store_Jacobians) 

    if nargin > 4 % tstop has been supplied
        tstop_specified = 1;
    else
        tstop_specified = 0;
        % FIXME: check that stopFunc and stopFuncArgs are properly defined
    end

    if nargin < 6
        store_Jacobians = 0;
    end

    if isa(LMSobj.tranparms.correctorFunc,'function_handle')
        corrector_available = 1;
    else
        corrector_available = 0;
    end
    if isfield(LMSobj.DAE,'DAEupdateFuncPerTimepoint') && isa(LMSobj.DAE.DAEupdateFuncPerTimepoint, 'function_handle')
        DAE_updatefunc_available = 1;
    else
        DAE_updatefunc_available = 0;
    end

    p = LMSobj.TRmethod.order;
    % assign LTEparms %%%%%% added by jian
        LTEparms = LMSobj.tranparms.LTEstepControlParms;
        trreltol=optget(LTEparms, 'reltol', LTEparms.trreltol);
        trabstol=optget(LTEparms, 'abstol', LTEparms.trabstol);
        k = LMSobj.TRmethod.kth_exact;
    
    % LMS Speedup switch by Bichen
    doSpeedup = LMSobj.tranparms.doSpeedup;
            
    if (p > 1)
        % run BE to generate p-1 initial points
        % could use Runge-Kutta in the future
        TRmethods = LMSmethods();
        BEobj = LMS(LMSobj.DAE, TRmethods.BE, LMSobj.tranparms);

        if (LMSobj.tranparms.trandbglvl > -1)
            fprintf(1,sprintf('LMS: first %d step(s): using BE\n', p-1));
        end
        
        %%%%%%%%%%%%%%%  modified by jian
        if 1 == LMSobj.tranparms.LTEstepControlParms.doStepControl && 1 == LMSobj.tranparms.LTEstepControlParms.dofirststep  % use default tstep
            delta=LMSobj.tranparms.LTEstepControlParms.trfirststep;
            LMSobj.tranparms.LTEstepControlParms.dofirststep = 0;
        else
            delta=tstep;
        end

        BEobj = feval(BEobj.solve, BEobj, xinitcond, tstart, delta, ...   %%%%%% modified by jian
                tstart+(p-1)*delta, store_Jacobians);                     %%%%%% modified by jian
        %%%%%%%%%%%%%%%    
            
        LMSobj.tpts = BEobj.tpts;
        LMSobj.vals = BEobj.vals;
        LMSobj.timeptidx = BEobj.timeptidx;
        if 1 == store_Jacobians
            LMSobj.Cs = BEobj.Cs;
            LMSobj.Gs = BEobj.Gs;
            LMSobj.Gus = BEobj.Gus;
        end
        t = BEobj.tpts(BEobj.timeptidx);
        if LMSobj.tranparms.trandbglvl > 1
            fprintf(1,sprintf('LMS: finished first %d step(s) using BE\n', p-1));
        end
    else % p > 1
        t = tstart;
        LMSobj.tpts = []; LMSobj.vals = []; % wipe out any previous simulation data
        LMSobj.tpts(1) = t;
        LMSobj.vals(:,1) = xinitcond; % x/xold should be a column vector
        LMSobj.timeptidx = 1;
        if 1 == store_Jacobians
            % TODO/FIXME: pre-allocate these, too
            [cee, gee, geeu] = feval(LMSobj.jacobians, t, xinitcond, LMSobj.DAE);
            LMSobj.Cs{end+1} = cee;
            LMSobj.Gs{end+1} = gee;
            LMSobj.Gus{end+1} = geeu;
        end
    end % p > 1

    do_preallocate = 0; % 1: pre-allocate LMSobj.tpts and LMSobj.vals
                    % pre-allocation seems to actually slow things
                % down on run_inverterchain_transient

    n_existing_pts = LMSobj.timeptidx;
    if 1 == do_preallocate 
        allocated_pts = ceil(abs((tstop-tstart)/tstep)*1.2);
        LMSobj.tpts(1,(n_existing_pts+1):(n_existing_pts+allocated_pts)) = zeros(1, allocated_pts);
        LMSobj.vals(:,(n_existing_pts+1):(n_existing_pts+allocated_pts)) = zeros(feval(LMSobj.DAE.nunks, LMSobj.DAE), allocated_pts);
        allocated_pts = allocated_pts + n_existing_pts;
        if LMSobj.tranparms.trandbglvl > 1
            fprintf(2,'\n   LMStimeStepping: pre-allocated %d points\n', allocated_pts);
        end
    end
    
    delta = tstep;
    maxdelta = delta*LMSobj.tranparms.stepControlParms.MaxStepFactor;
    stepctr = 0;
    totNRiters = 0;
    if LMSobj.tranparms.trandbglvl > 0 && 1 == tstop_specified
        percentage_done_incr = 5;
        next_threshold = percentage_done_incr;
        mytic = tic;
        elapsed_time_threshold = 10; % don't print progress messages unless at least this many seconds elapse since the last one
    end

    % Bichen: fqHistory is used to store previously evaluated f and q function to
    % reduce redudant evaluation in high order (>=2) LMS procedure.
    if doSpeedup
        fqHistory.Size = p; 
        fqHistory.fbterm = [];
        fqHistory.qterm = [];
    end

    plus_printout_count = 0;
    n_plusses_before_LF = 40;
    while 1 == 1 % stopping criterion is inside, immediately after this
        if 1 == tstop_specified
            done = (t >= tstop);
        else
            done = feval(LMSobj.tranparms.stopFunc, t, LMSobj.vals(:, LMSobj.timeptidx), LMSobj.tranparms.stopFuncArgs);
        end

        if 1 == done
            break; % while loop
        end

        tnew = t + delta;

        if 1 == tstop_specified && (tnew > tstop - ...
                                    max(2*LMSobj.tranparms.stepControlParms.absMinStep, ...
                                        LMSobj.tranparms.stepControlParms.relMinStep*abs(tstop-tstart))) 
            tnew=tstop;
        end
        %
        last_pp1_ts(1) = tnew;
        last_pp1_ts(2:(p+1)) = LMSobj.tpts(LMSobj.timeptidx:-1:LMSobj.timeptidx-p+1);
        %
        LMSobj.currentalphas = feval(LMSobj.TRmethod.alphasfunc, last_pp1_ts);
        % LMSobj.dcurrentalphas = feval(LMSobj.TRmethod.dalphasfunc, last_pp1_ts); % for homotopy (computed later, only if needed)
        LMSobj.currentbetas = feval(LMSobj.TRmethod.betasfunc, last_pp1_ts);
        % LMSobj.dcurrentbetas = feval(LMSobj.TRmethod.dbetasfunc, last_pp1_ts); % for homotopy (computed later, only if needed)
        %
        initNRguess = LMSobj.vals(:, LMSobj.timeptidx); % simplest kind of predictor: value at previous timepoint
        LMSobj.tnew = tnew;
        %

        % Note: if explicit method, NR will break on DAEs.
        if 1 == LMSobj.tranparms.useAFobjForNR
            % TODO: Consider a better name to replace .LMS_add_on
            LMSobj.AFobj.LMS_add_on.TRmethod.order = LMSobj.TRmethod.order;
            LMSobj.AFobj.LMS_add_on.currentalphas = LMSobj.currentalphas;
            % LMSobj.AFobj.LMS_add_on.dcurrentalphas = LMSobj.dcurrentalphas; % for homotopy (computed later, only if needed)
            LMSobj.AFobj.LMS_add_on.currentbetas = LMSobj.currentbetas;
            % LMSobj.AFobj.LMS_add_on.dcurrentbetas = LMSobj.dcurrentbetas; % for homotopy (computed later, only if needed)
            LMSobj.AFobj.LMS_add_on.tnew = LMSobj.tnew;
            LMSobj.AFobj.LMS_add_on.tpts = LMSobj.tpts;
            LMSobj.AFobj.LMS_add_on.vals = LMSobj.vals;
            LMSobj.AFobj.LMS_add_on.timeptidx = LMSobj.timeptidx;
            LMSobj.AFobj.doSpeedup = doSpeedup;
            % bichen: LMS speedup switch
            if doSpeedup
                LMSobj.AFobj.LMS_add_on.fqHistory = fqHistory;
                [xnew, iters, success, AFobjPreComputedStuff] = NR(LMSobj.AFobj, LMSobj.tranparms.NRparms, initNRguess);
                fqterm = AFobjPreComputedStuff.fqterm;
            else
                [xnew, iters, success] = NR(LMSobj.AFobj, LMSobj.tranparms.NRparms, initNRguess);
            end
        else
            [xnew, iters, success] = NR(@LMSfuncToSolve, @dLMSfuncToSolve, initNRguess, LMSobj, LMSobj.tranparms.NRparms);
        end
        totNRiters = totNRiters + iters;
        %

        % if there is an externally-supplied corrector function, call it
        if success > 0 && 1 == corrector_available
            % if NR succeeded and a corrector is available, apply it to update xnew
            LMSobj.tranparms.correctorFuncArgs.told = t;
            LMSobj.tranparms.correctorFuncArgs.xold = LMSobj.vals(:, LMSobj.timeptidx);
            [xnewer, tnewer, iters, success] = feval(LMSobj.tranparms.correctorFunc, tnew, xnew, LMSobj.tranparms.correctorFuncArgs);
            totNRiters = totNRiters + iters;
            if 1 == success
                xnew = xnewer;
                % snew/tnew updated to reflect the point actually found by the corrector (it can change tnew)
                delta = delta + (tnewer-tnew);
                tnew = tnewer;
            else
                success = 0;
            end
        end
        %
        if 0 == success % NR or corrector failed
            if 1 == LMSobj.tranparms.stepControlParms.doStepControl
                delta = delta/LMSobj.tranparms.stepControlParms.NRfailCutFactor;
                if LMSobj.tranparms.trandbglvl > 1
                    fprintf(2,'LMStimestepping: NR failed (%d iterations) at t=%g (after %d timesteps)\n', ...
                    iters, tnew, stepctr);
                    fprintf(2,'\ttimestep cut to %g\n', delta);
                end
                if LMSobj.tranparms.trandbglvl > 0
                    fprintf(2,'/');
                end

                if (delta < LMSobj.tranparms.stepControlParms.absMinStep) ...
                   || ((tstop_specified == 1) && (delta < LMSobj.tranparms.stepControlParms.relMinStep*abs(tstop-tstart)))
                    if 1 == LMSobj.tranparms.homotopyAsLastResort
                        %{
	                    ACobj = ArcCont([], [], []); % empty ArcCont object, but has default parms defined
                    	parms = ACobj.ArcContParms;
                        ArcContAnalObj.parms.StartLambda = startLambda;
                        ArcContAnalObj.parms.StopLambda = stopLambda;
                        ArcContAnalObj.parms.initDeltaLambda = initLambdaStep;
                        %}
                        LMSobj.realtnew = LMSobj.tnew;
                        warning('last ditch attempt: using homotopy after minimum timestep reached');
                        if 1 == LMSobj.timeptidx  % ie, tnew is the first step after the initial condition
                            fprintf(2,'homotopy cannot be used for the first transient simulation step');
                            if LMSobj.tranparms.trandbglvl > -1
                                fprintf(2,'minimum allowed timestep (%g) reached at first timestep; aborting transient at t=%g.\n', ...
                                          max(LMSobj.tranparms.stepControlParms.absMinStep, ...
                                              tstop_specified*LMSobj.tranparms.stepControlParms.relMinStep*abs(tstop-tstart)), tnew);
                            end
                            LMSobj.solvalid=0;
                            LMSobjOUT = LMSobj;
                            return;
                        end
	                    ACobj = ArcCont([], [], []); % empty ArcCont object, but has default parms defined
                    	ACobj.ArcContParms.NRparms = LMSobj.tranparms.NRparms; % important?
                        ACobj.ArcContParms.StartLambda = 0; 
                        ACobj.ArcContParms.StopLambda = 1e-4; % TODO: find some way to find a decent value for this scale
                        ACobj.ArcContParms.initDeltaLambda = 0.01e-4;
                        ACobj.ArcContParms.maxDeltaLambda = 0.05e-4;

                        LMSobj.ArcContParms = ACobj.ArcContParms;

                        ArcContObj = ArcCont(@Arc_LMSfuncToSolve, @dArc_LMSfuncToSolve, LMSobj);
                        initguess = LMSobj.vals(:, LMSobj.timeptidx);
                        ArcContObj = feval(ArcContObj.solve, ArcContObj, initguess);
                        if ArcContObj.solve_successful ~= 1
                            if LMSobj.tranparms.trandbglvl > -1
                                fprintf(2,'minimum allowed timestep (%g) reached and homotopy failed; aborting transient at t=%g.\n', ...
                                          max(LMSobj.tranparms.stepControlParms.absMinStep, ...
                                              tstop_specified*LMSobj.tranparms.stepControlParms.relMinStep*abs(tstop-tstart)), tnew);
                            end
                            LMSobj.solvalid=0;
                            LMSobjOUT = LMSobj;
                            unknames = feval(LMSobj.DAE.unknames, LMSobj.DAE);
                            for i=1:length(unknames)
                                figure();
                                plot(ArcContObj.sol.yvals(end,:), ArcContObj.sol.yvals(i,:), '.-');
                                grid on;
                                xlabel('\lambda');
                                ylabel(unknames{i});
                                title(sprintf('homotopy output %s at t=%g', unknames{i}, LMSobj.tnew));
                            end
                            return;
                        end
                        %[spts, yvals, finalSol] = feval(ArcContObj.getsolution, ArcContObj);
                        %xnew = finalSol;
                        xnew = ArcContObj.sol.finalSol;
                        LMSobj.solvalid=1;
                        unknames = feval(LMSobj.DAE.unknames, LMSobj.DAE);
                        for i=1:length(unknames)
                            figure();
                            plot(ArcContObj.sol.yvals(end,:), ArcContObj.sol.yvals(i,:), '.-');
                            grid on;
                            xlabel('\lambda');
                            ylabel(unknames{i});
                            title(sprintf('homotopy output %s at t=%g', unknames{i}, LMSobj.tnew));
                        end
                        % TODO: update totNRiters
                    else
                        if LMSobj.tranparms.trandbglvl > -1
                            fprintf(2,'minimum allowed timestep (%g) reached, aborting transient at t=%g.\n', ...
                                      max(LMSobj.tranparms.stepControlParms.absMinStep, ...
                                          tstop_specified*LMSobj.tranparms.stepControlParms.relMinStep*abs(tstop-tstart)), tnew);
                        end
                        LMSobj.solvalid=0;
                        LMSobjOUT = LMSobj;
                        return;
                    end
                end
                continue;
            else
                fprintf(2,'ERROR in LMS: NR failed to converge (no step control); aborting transient at t=%g.\n', tnew);
                LMSobj.solvalid=0;
                LMSobjOUT = LMSobj;
                return;
            end
        end

        if 1 == LMSobj.tranparms.stepControlParms.doStepControl
            if iters > LMSobj.tranparms.stepControlParms.NRiterRange(2) 
                delta = delta/LMSobj.tranparms.stepControlParms.cutFactor;
                if LMSobj.tranparms.trandbglvl > 1
                    fprintf(2,'\tnext timestep cut to %g on account of taking %d>%d NR iterations\n', delta, iters, LMSobj.tranparms.stepControlParms.NRiterRange(2));
                end
                if LMSobj.tranparms.trandbglvl > 0
                    fprintf(2,'|');
                end
            end

            if iters < LMSobj.tranparms.stepControlParms.NRiterRange(1) 
                newdelta = min(delta*LMSobj.tranparms.stepControlParms.increaseFactor, maxdelta);
                if (LMSobj.tranparms.trandbglvl > 1) && (delta < maxdelta)
                    fprintf(2,'\tnext timestep increased to %g on account of taking %d<%d NR iterations\n', newdelta, iters, LMSobj.tranparms.stepControlParms.NRiterRange(1));
                end
                if (LMSobj.tranparms.trandbglvl > 0) && (delta < maxdelta)
                    fprintf(2,'\\');
                end
                delta = newdelta;
            end
        end
        
        %%%%%%%%%%%%%%%%%%%%%modified by jian%%%%%%%%%%%%%%%%%
        if 1 == LMSobj.tranparms.LTEstepControlParms.doStepControl && 1 == LMSobj.tranparms.LTEstepControlParms.dofirststep  %%%use default tstep
            delta=LMSobj.tranparms.LTEstepControlParms.trfirststep;
            LMSobj.tranparms.LTEstepControlParms.dofirststep = 0;
            continue;
        end
                        
        if 1 == LMSobj.tranparms.LTEstepControlParms.doStepControl  && (k<2 || LMSobj.timeptidx > 1)
            last_pp1_ts(1) = tnew;
            last_pp1_ts(2:(k+1)) = LMSobj.tpts(LMSobj.timeptidx:-1:LMSobj.timeptidx-k+1);
            
            last_pp1_xs(:,1) = xnew;
            last_pp1_xs(:,2:(k+1)) = LMSobj.vals(:,LMSobj.timeptidx:-1:LMSobj.timeptidx-k+1);
            
            LTEvalue = feval(LMSobj.TRmethod.LTEcontrol,last_pp1_ts,last_pp1_xs, LMSobj.AFobj); 
            
            q_xnew = feval(LMSobj.AFobj.DAE.q, xnew, LMSobj.AFobj.DAE);  
            
            if LMSobj.tranparms.LTEstepControlParms.errspecflag == 1
                trtolerance = norm(q_xnew)*trreltol + trabstol;
                if norm(LTEvalue)<=trtolerance
                    delta = delta*LMSobj.tranparms.LTEstepControlParms.trincreaseFactor;
                else
                    if norm(LTEvalue)>LMSobj.tranparms.LTEstepControlParms.trredoFactor*trtolerance
                        delta = delta/LMSobj.tranparms.LTEstepControlParms.trredoCutFactor;
                        continue;
                    else
                        delta = delta/LMSobj.tranparms.LTEstepControlParms.trcutFactor;
                    end
                end
            elseif LMSobj.tranparms.LTEstepControlParms.errspecflag == 0
                trtolerance = abs(q_xnew)*trreltol + trabstol;
                if max(abs(LTEvalue)-trtolerance) <= 0
                    delta = delta*LMSobj.tranparms.LTEstepControlParms.trincreaseFactor;
                else
                    [LTEtmp, max_err_No] = max(abs(LTEvalue)-trtolerance);
                    if  abs(LTEvalue(max_err_No))> LMSobj.tranparms.LTEstepControlParms.trredoFactor*trtolerance(max_err_No)
                        delta = delta/LMSobj.tranparms.LTEstepControlParms.trredoCutFactor;
                        continue;
                    else
                        delta = delta/LMSobj.tranparms.LTEstepControlParms.trcutFactor;
                    end
                end
            end
            
        end
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

        % timestep accepted
        if LMSobj.tranparms.trandbglvl > 0
            fprintf(2,'+');
            plus_printout_count = plus_printout_count + 1;
            if plus_printout_count > n_plusses_before_LF
                fprintf(2, '\n');
                plus_printout_count = 0;
            end
            if 1 == tstop_specified
                if 100*tnew/tstop > next_threshold
                    elapsed = toc(mytic);
                    if elapsed > elapsed_time_threshold
                        fprintf(2,'\ntransient: %d%% done\n', next_threshold);
                        plus_printout_count = 0;
                        mytic = tic;
                    end
                    next_threshold = next_threshold + percentage_done_incr;
                end
            end
        end
        if LMSobj.tranparms.trandbglvl >= 2
            fprintf(2,'\n');
            fprintf(2,'timepoint %d accepted at t=%g\n', stepctr+1, tnew);
            plus_printout_count = 0;
        end
        if LMSobj.tranparms.trandbglvl >= 3
            fprintf(2,'lambda=%g\n', xnew(end,1));
            plus_printout_count = 0;
        end
        if 1 == DAE_updatefunc_available
            LMSobj.DAE = feval(LMSobj.DAE.DAEupdateFuncPerTimepoint, tnew, xnew, LMSobj.DAE);
        end

        LMSobj.timeptidx = LMSobj.timeptidx + 1;

        if 1 == do_preallocate && LMSobj.timeptidx > allocated_pts
            % increase size of allocated vectors/matrices
            alloc_increase = 50;
            LMSobj.tpts(1,LMSobj.timeptidx:(LMSobj.timeptidx+alloc_increase-1)) = zeros(1,alloc_increase);
            LMSobj.vals(:,LMSobj.timeptidx:(LMSobj.timeptidx+alloc_increase-1)) = zeros(feval(LMSobj.DAE.nunks,LMSobj.DAE),alloc_increase);
            allocated_pts = allocated_pts + alloc_increase;
            if LMSobj.tranparms.trandbglvl > 1
                fprintf(2,'\n   LMStimeStepping: updated pre-allocation to %d points\n', allocated_pts);
            end
        end
        
        LMSobj.tpts(1, LMSobj.timeptidx) = tnew;
        LMSobj.vals(:, LMSobj.timeptidx) = xnew; % xnew should be a column vector
        t = tnew;
        stepctr = stepctr + 1;

        if 1 == LMSobj.tranparms.useAFobjForNR
            if doSpeedup % bichen
                % update fqHistory
                if fqHistory.Size > 0
                    if size(fqHistory.fbterm,2) >= fqHistory.Size

                        % efficiency comparison between different implementations:
                        % 0. previous implmenetation
                        %    a = [anew, a(:,1:end-1)];
                        % 1. about 200 times slower method 0
                        %    a = circshift(a, [0 1]);    
                        %    a(:,1) = anew;
                        % 2. Using cells, slightly slower than method 0
                        %    a = {anew{:}, a{1:end-1}};
                        % 3. current implementation, about 20% faster than method 0
                        %    a(:, 2:end) = a(1:end-1);
                        %    a(:,1) = anew;

                        fqHistory.fbterm(:,2:end) = fqHistory.fbterm(:,1:end-1);
                        fqHistory.fbterm(:,1) = fqterm.fbterm;

                        fqHistory.qterm(:,2:end) = fqHistory.qterm(:,1:end-1);
                        fqHistory.qterm(:,1) = fqterm.qterm;
                    else
                        % Current implementation is about 30% faster than 
                        %     fqHistory.fbterm = [fqterm.fbterm,fqHistory.fbterm(:,1:end)];

                        fqHistory.fbterm(:,2:end+1) = fqHistory.fbterm(:,1:end);
                        fqHistory.fbterm(:,1) = fqterm.fbterm;

                        fqHistory.qterm(:,2:end+1) = fqHistory.qterm(:,1:end);
                        fqHistory.qterm(:,1) = fqterm.qterm;
                    end
                end
            end % doSpeedup
        end % useAFobjForNR

        if 1 == store_Jacobians
            % TODO/FIXME: use pre-allocation here, too
            [cee, gee, geeu] = feval(LMSobj.jacobians, tnew, xnew, LMSobj.DAE);
            LMSobj.Cs{end+1} = cee;
            LMSobj.Gs{end+1} = gee;
            LMSobj.Gus{end+1} = geeu;
        end
    end % while
    if LMSobj.tranparms.trandbglvl >= 1
        fprintf(2,'\n');
    end
    LMSobj.solvalid = 1;
    LMSobj.totNRiters = totNRiters;
    LMSobjOUT = LMSobj;
end % of LMStimeStepping












function out = LMSfuncToSolve(x, LMSobj)
    p = LMSobj.TRmethod.order;
    alphas = LMSobj.currentalphas; % length p
    betas = LMSobj.currentbetas; % length p
    DAE = LMSobj.DAE;
    tnew = LMSobj.tnew;
    % the DAE is qdot(x) + f(x) + B*u(t) = 0 => qdot(x) = g(x,t)=-f(x)-B*u(t)
    % the LMS formula is: 
    %    0 =   sum_i=0^{p} alpha_i q(x_{n-i}) 
    %          - sum_i=0^{p} beta_i g(x_{n-i},t_{n-i})
    % or 0 =   sum_i=0^{p} alpha_i q(x_{n-i}) 
    %          + sum_i=0^{p} beta_i [f(x_{n-i}) + b(t_{n-i})]

    ninputs = feval(DAE.ninputs, DAE);
    % current timepoint term
    if  ninputs > 0
        unew = feval(DAE.utransient, tnew, DAE); % homotopy: need DAE.d_utransient
    else
        unew = [];
    end
    if 1 == LMSobj.f_takes_u
        % DAE is d/dt q(x) + f(x, u(t)) = 0
        fbterm = feval(DAE.f, x, unew, DAE); % homotopy: will use DAE.d_utransient
    else
        % DAE is d/dt q(x) + f(x) + B*u(t) = 0
        fbterm = feval(DAE.f, x, DAE);
        if ninputs > 0
            fbterm = fbterm + LMSobj.B*unew; % homotopy: will use DAE.d_utransient
        end
    end
    if isfield(DAE, 'm') && isa(DAE.m, 'function_handle')
        nn = feval(DAE.nNoiseSources, DAE);
        fbterm = fbterm + feval(DAE.m, x, zeros(nn,1), DAE);
    end
    out = alphas(1)*feval(DAE.q, x, DAE) + betas(1)*fbterm; % homotopy: alpha/betas depend on tnew, their derivatives needed

    % terms for prior timepoints
    for i=2:(p+1)
        x_nmi = LMSobj.vals(:,LMSobj.timeptidx-i+2);
        out = out + alphas(i)*feval(DAE.q, x_nmi, DAE);

        if 0 ~= betas(i) % for efficiency: don't evaluate fbterm
            t_nmi = LMSobj.tpts(LMSobj.timeptidx-i+2);

            if  ninputs > 0
                u_nmi = feval(DAE.utransient, t_nmi, DAE);
            else
                u_nmi = [];
            end
            if 1 == LMSobj.f_takes_u
                % DAE is d/dt q(x) + f(x, u(t)) = 0
                fbterm = feval(DAE.f, x_nmi, u_nmi, DAE);
            else
                % DAE is d/dt q(x) + f(x) + B*u(t) = 0
                fbterm = feval(DAE.f, x_nmi, DAE) ;
                if ninputs > 0
                    fbterm = fbterm + LMSobj.B*u_nmi;
                end
            end
            if isfield(DAE, 'm') && isa(DAE.m, 'function_handle')
                nn = feval(DAE.nNoiseSources, DAE);
                fbterm = fbterm + feval(DAE.m, x_nmi, zeros(nn,1), DAE);
            end
            out = out + betas(i)*fbterm;
        end
    end
end % of LMSfuncToSolve













function [Jout, Jtn] = dLMSfuncToSolve(x, LMSobj)
    if nargout > 1
        compute_Jtn = 1;
    else
        compute_Jtn = 0;
    end
    p = LMSobj.TRmethod.order;
    alphas = LMSobj.currentalphas; % length p
    betas = LMSobj.currentbetas; % length p
    if 1 == compute_Jtn
        dalphas = LMSobj.dcurrentalphas; % length p
        dbetas = LMSobj.dcurrentbetas; % length p
    end
    DAE = LMSobj.DAE;
    tnew = LMSobj.tnew;
    % the DAE is qdot(x) + f(x) + b(t) = 0 => qdot(x) = g(x,t)=-f(x)-b(t)
    % the LMS formula is: 
    %   0 =   sum_i=0^{p} alpha_i q(x_{n-i}) 
    %    - sum_i=0^{p} beta_i g(x_{n-i},t_{n-i})
    %or 0 =   sum_i=0^{p} alpha_i q(x_{n-i}) 
    %    + sum_i=0^{p} beta_i [f(x_{n-i}) + b(t_{n-i})]

    % current timepoint term (i = 0)
    %out = alphas(1)*feval(DAE.q, x, DAE) + ...
    %     betas(1)*(feval(DAE.f, x, DAE) + ...
    %            B*feval(DAE.utransient, tnew, DAE));
    ninputs = feval(DAE.ninputs, DAE);
    % current timepoint term 
    if ninputs > 0
        unew = feval(DAE.utransient, tnew, DAE);
        if 1 == compute_Jtn
            % hack to get u'(tnew) in the absence of analytical function for du(t)/dt
            told = LMSobj.tpts(LMSobj.timeptidx);
            uold = feval(DAE.utransient, told, DAE);
            if tnew ~= told
                dunew = (unew - uold)/(tnew-told);
            else
                dunew = 0; % value should not matter, since betas(.) (which include multiplication by h) should be zero.
            end
        end
    else
        unew = [];
    end
    if 1 == LMSobj.f_takes_u
        % DAE is d/dt q(x) + f(x, u(t)) = 0
        Jfterm = feval(DAE.df_dx, x, unew, DAE);
        if 1 == compute_Jtn
            fbterm = feval(DAE.f, x, unew, DAE); % homotopy: will use DAE.d_utransient
            Jtnterm = feval(DAE.df_du, x, unew, DAE)*dunew;
        end
    else
        % DAE is d/dt q(x) + f(x) + B*u(t) = 0
        Jfterm = feval(DAE.df_dx, x, DAE);
        if 1 == compute_Jtn
            % DAE is d/dt q(x) + f(x) + B*u(t) = 0
            fbterm = feval(DAE.f, x, DAE);
            if ninputs > 0
                fbterm = fbterm + LMSobj.B*unew; % homotopy: will use DAE.d_utransient
                Jtnterm = LMSobj.B*dunew;
            else
                Jtnterm = [];
            end
        end
    end
    if isfield(DAE, 'm') && isa(DAE.m, 'function_handle')
        nn = feval(DAE.nNoiseSources, DAE);
        if 1 == compute_Jtn
            fbterm = fbterm + feval(DAE.m, x, zeros(nn,1), DAE);
        end
        Jfterm = Jfterm + feval(DAE.dm_dx, x, zeros(nn,1), DAE);
    end

    Jout = alphas(1)*feval(DAE.dq_dx, x, DAE) + betas(1)*Jfterm;
    if 1 == compute_Jtn
        % out = alphas(1)*feval(DAE.q, x, DAE) + betas(1)*fbterm; % homotopy: alpha/betas depend on tnew, their derivatives needed
        Jtn = dalphas(1)*feval(DAE.q, x, DAE) + betas(1)*Jtnterm + dbetas(1)*fbterm;
    end

    % (terms from prior timepoints don't contribute to derivative wrt x, but they can to derivatives wrt tn)
    if 1 == compute_Jtn
        % terms for prior timepoints
        for i=2:(p+1)
            x_nmi = LMSobj.vals(:,LMSobj.timeptidx-i+2);
            % out = out + alphas(i)*feval(DAE.q, x_nmi, DAE);
            if dalphas(i) ~= 0
                Jtn = Jtn + dalphas(i)*feval(DAE.q, x_nmi, DAE);
            end

            if 0 ~= dbetas(i) % for efficiency: don't evaluate fbterm/Jtn
                t_nmi = LMSobj.tpts(LMSobj.timeptidx-i+2);

                if  ninputs > 0
                    u_nmi = feval(DAE.utransient, t_nmi, DAE);
                else
                    u_nmi = [];
                end
                if 1 == LMSobj.f_takes_u
                    % DAE is d/dt q(x) + f(x, u(t)) = 0
                    fbterm = feval(DAE.f, x_nmi, u_nmi, DAE);
                else
                    % DAE is d/dt q(x) + f(x) + B*u(t) = 0
                    fbterm = feval(DAE.f, x_nmi, DAE) ;
                    if ninputs > 0
                        fbterm = fbterm + LMSobj.B*u_nmi;
                    end
                end
                if isfield(DAE, 'm') && isa(DAE.m, 'function_handle')
                    nn = feval(DAE.nNoiseSources, DAE);
                    fbterm = fbterm + feval(DAE.m, x_nmi, zeros(nn,1), DAE);
                end
                % out = out + betas(i)*fbterm;
                Jtn = Jtn + dbetas(i)*fbterm;
            end
        end
    end
end % of dLMSfuncToSolve













function newdx = TRANlimiting(dx, oldx, LMSobj)
    % JR: THIS IS A HACK (using just QSS limiting). It needs updates for
    % handling the q terms in transient.
    %
    % Tianshi: As of 2014/07 NRlimiting's definition has been changed now, this
    % routine is not working any more, but strangely no test is broken as if it
    % was never actually used at all 
    tnew = LMSobj.tnew;
    ninputs = feval(LMSobj.DAE.ninputs, LMSobj.DAE);
    % current timepoint term
    if  ninputs > 0
        u = feval(LMSobj.DAE.utransient, tnew, LMSobj.DAE);
    else
        u = [];
    end
    newdx = feval(LMSobj.DAE.NRlimiting, dx, oldx, u, LMSobj.DAE);
end % of TRANlimiting









% Bichen: Added an output struct to store fbterm, qterm, Jfterm and Jqterm
%          Thoses terms will be stored to avoid redundant evaluation

function [out_f, out_df, out_rhs, xlimOld, success, LMSPreComputedStuff] = LMS_f_df_rhs(x, funcparms)
    % funcparms is an AFobj
    p = funcparms.LMS_add_on.TRmethod.order;
    alphas = funcparms.LMS_add_on.currentalphas; % length p
    betas = funcparms.LMS_add_on.currentbetas; % length p
    DAE = funcparms.DAE;
    tnew = funcparms.LMS_add_on.tnew;
    % bichen: LMS speedup switch
    doSpeedup = funcparms.doSpeedup;
    if doSpeedup 
        fbterm_update = [];
        qterm_update = [];
    end
    % the DAE is qdot(x) + f(x) + B*u(t) = 0 => qdot(x) = g(x,t)=-f(x)-B*u(t)
    % the LMS formula is: 
    %   0 =   sum_i=0^{p} alpha_i q(x_{n-i}) 
    %    - sum_i=0^{p} beta_i g(x_{n-i},t_{n-i})
    %or 0 =   sum_i=0^{p} alpha_i q(x_{n-i}) 
    %    + sum_i=0^{p} beta_i [f(x_{n-i}) + b(t_{n-i})]

    ninputs = feval(DAE.ninputs, DAE);
    % current timepoint term
    if  ninputs > 0
        unew = feval(DAE.utransient, tnew, DAE);
    else
        unew = [];
    end
    % LMS Speedup procedure.
    if doSpeedup
        % Bichen: the following if-else-end branches are used to keep the backward compatbility
        flag.f =1; flag.q =1; 
        flag.dfdx =1; flag.dqdx =1;
        % flag.dfdu = 1; % JR 2016/03/01 - took this out, not used in LMS!
        flag.dfdu = 0;
        if 1 == DAE.f_takes_inputs
            % flag.dfdu = 1; % JR 2016/03/01 - not used in LMS!
            fqJout = feval(DAE.fqJ, x, unew, flag, DAE);
            fout = fqJout.f;
            % dfdu = fqJout.dfdu; % JR 2016/03/01 - not used in LMS!
        else
            fqJout = feval(DAE.fqJ, x, flag, DAE);
            Bmat = feval(DAE.B, DAE);
            if ~isempty(Bmat)
                fout = fqJout.f + Bmat * unew;
            else
                fout = fqJout.f;
            end
            % dfdu = Bmat; % JR 2016/03/01 - not used in LMS!
        end
        qout = fqJout.q;
        dfdx = fqJout.dfdx;
        dqdx = fqJout.dqdx;

        fbterm_new = fout;
        qterm_new = qout;
        out_f = alphas(1)*qterm_new + betas(1)*fbterm_new;
        Jfterm = dfdx;
        Jqterm = dqdx;

        % restore new evaluated terms of out_f
        out_f_new = out_f;
        % For the 1st iteration of NR, evaluate f/q(x_{n-i})
        % otherwise, just use previously stored f and q
        if funcparms.LMS_add_on.iter == 1 % JR: WHY ARE WE LOOKING AT THE NR ITERATION NOW? BREAKS MODULARITY IN A BIG WAY.
            % OK: because some setup things need to be done only once, at the first NR iteration. This is a flag.
            % We need documentation of some of these variables: 
            % - what is .fqHistory, with some simple illustrative examples
            % - what is .vals
            for i=2:(p+1)
                %%%%%%%%%%%%%% Use stored f and q %%%%%%%%%%%%%%%%%
                % Now criteria for using previous stored fqterm is following:
                %     size of fqHistory >= p AND the index of f is at least before (n-2) 
                if size(funcparms.LMS_add_on.fqHistory.fbterm,2) >= p && i > 2
                    fbterm = funcparms.LMS_add_on.fqHistory.fbterm(:,i-2);
                    qterm = funcparms.LMS_add_on.fqHistory.qterm(:,i-2);
                    out_f = out_f + alphas(i)*qterm + betas(i)*fbterm;
                    
                %%%%%%%%%%%% Evaluate f and q %%%%%%%%%%%%%%%%%%%%%%
                else
                    x_nmi = funcparms.LMS_add_on.vals(:,funcparms.LMS_add_on.timeptidx-i+2);
                    %%%%%%%%%%%%%%%%% Evaluate q %%%%%%%%%%%%%%%%%%%%
                    qterm_update = feval(DAE.q, x_nmi, DAE);
                    out_f = out_f + alphas(i)*qterm_update;
                    %%%%%%%%%%%%%%%% END Evaluate q %%%%%%%%%%%%%%%%%%


                    %%%%%%%%%%%%%%%%% Evaluate F %%%%%%%%%%%%%%%%%%%%
                    fbterm_update = zeros(size(qterm_update));
                    if 0 ~= betas(i) % for efficiency: don't evaluate fbterm
                           t_nmi = funcparms.LMS_add_on.tpts(funcparms.LMS_add_on.timeptidx-i+2);
                           if  ninputs > 0
                                   u_nmi = feval(DAE.utransient, t_nmi, DAE);
                           else
                                   u_nmi = [];
                           end
                           if 1 == DAE.f_takes_inputs
                           % DAE is d/dt q(x) + f(x, u(t)) = 0
                            fbterm_update = feval(DAE.f, x_nmi, u_nmi, DAE);
                        else
                               % DAE is d/dt q(x) + f(x) + B*u(t) = 0
                            fbterm_update = feval(DAE.f, x_nmi, DAE) ;
                               if ninputs > 0
                                   fbterm_update = fbterm_update + feval(DAE.B, DAE)*u_nmi;
                               end
                        end
                    end

                    out_f = out_f + betas(i)*fbterm_update;
                    %%%%%%%%%%%%%%% END Evaluate F %%%%%%%%%%%%%%%%%%

                end    % if size(funcparms.fqHistory.fbterm,2) >= p && i > 2
                % Store the latest f(x_{n-i}) and q(x_{n-i})
                if i == 2
                    LMSPreComputedStuff.fqterm.fbterm = fbterm_update;
                    LMSPreComputedStuff.fqterm.qterm = qterm_update;
                end
            end % for i=2:p+1

            % Store the evaluation of f(x_mni)
            out_f_pre = out_f - out_f_new;
            LMSPreComputedStuff.out_f_pre = out_f_pre;

        % If > 2 iters, out_f_pre won't change
        else
            out_f = out_f + funcparms.PreComputedStuff.out_f_pre;
            LMSPreComputedStuff.out_f_pre = funcparms.PreComputedStuff.out_f_pre;
            LMSPreComputedStuff.fqterm = funcparms.PreComputedStuff.fqterm;
        end % if funcparm.iter == 1
        out_df = alphas(1)*Jqterm + betas(1)*Jfterm;
    else % if doSpeedup == 0, do original LMS without speedup
        if 1 == DAE.f_takes_inputs
            % DAE is d/dt q(x) + f(x, u(t)) = 0
            fbterm = feval(DAE.f, x, unew, DAE);
        else
            % DAE is d/dt q(x) + f(x) + B*u(t) = 0
            fbterm = feval(DAE.f, x, DAE);
            if ninputs > 0 
                fbterm = fbterm + feval(DAE.B, DAE) * unew;
            end
        end 
        out_f = alphas(1)*feval(DAE.q, x, DAE) + betas(1)*fbterm;

        % terms for prior timepoints
        for i=2:(p+1)
            x_nmi = funcparms.LMS_add_on.vals(:,funcparms.LMS_add_on.timeptidx-i+2);
            out_f = out_f + alphas(i)*feval(DAE.q, x_nmi, DAE);

            if 0 ~= betas(i) % for efficiency: don't evaluate fbterm
                t_nmi = funcparms.LMS_add_on.tpts(funcparms.LMS_add_on.timeptidx-i+2);
                if  ninputs > 0
                    u_nmi = feval(DAE.utransient, t_nmi, DAE);
                else
                    u_nmi = [];
                end
                if 1 == DAE.f_takes_inputs
                    % DAE is d/dt q(x) + f(x, u(t)) = 0
                    fbterm = feval(DAE.f, x_nmi, u_nmi, DAE);
                else
                    % DAE is d/dt q(x) + f(x) + B*u(t) = 0
                    fbterm = feval(DAE.f, x_nmi, DAE) ;
                    if ninputs > 0
                        fbterm = fbterm + feval(DAE.B, DAE)*u_nmi;
                    end
                end
                out_f = out_f + betas(i)*fbterm;
            end % 0 ~= betas(i)
        end % for i=2:(p+1)

        if 1 == DAE.f_takes_inputs
            % DAE is d/dt q(x) + f(x, u(t)) = 0
            Jfterm = feval(DAE.df_dx, x, unew, DAE);
        else % ie, if 0 == DAE.f_takes_inputs
            % DAE is d/dt q(x) + f(x) + B*u(t) = 0
            Jfterm = feval(DAE.df_dx, x, DAE);
        end
        Jqterm = feval(DAE.dq_dx, x, DAE);
        out_df = alphas(1)*Jqterm + betas(1)*Jfterm;
        LMSPreComputedStuff = [];
    end % doSpeedup
    
    % terms from prior timepoints don't contribute to the derivative wrt x
    out_rhs = out_df * x - out_f;
    xlimOld = [];
    success = 1;
end % of LMS_f_df_rhs






%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%% internal functions: wrappers for use with ArcCont %%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%




function out = Arc_LMSfuncToSolve(y, LMSobj)
% y = [x; lambda]
% at lambda = 0, we are at t=told; at lambda = 1; at tnew
    x = y(1:end-1,1);
    lambda = y(end,1);

    startlambda = LMSobj.ArcContParms.StartLambda;
    stoplambda = LMSobj.ArcContParms.StopLambda; 
    lambdaspan = stoplambda-startlambda;

    told = LMSobj.tpts(LMSobj.timeptidx);
    % tolder = LMSobj.tpts(LMSobj.timeptidx-1); 
    realtnew = LMSobj.realtnew; % this needs to be set up by whoever calls ArcCont

    tnew = ((lambda-startlambda)*realtnew + (stoplambda-lambda)*told)/lambdaspan;
    LMSobj.tnew = tnew; % one instance where pass-by-value is helpful

    % need to recompute alphas and betas (we have changed the time-step)

    p = LMSobj.TRmethod.order;
    last_pp1_ts(1) = tnew;
    LMSobj.timeptidx = LMSobj.timeptidx - 1; % sets the first prev timept to tn-2 - one instance where pass-by-value is helpful
    last_pp1_ts(2:(p+1)) = LMSobj.tpts(LMSobj.timeptidx:-1:LMSobj.timeptidx-p+1); 
    %
    LMSobj.currentalphas = feval(LMSobj.TRmethod.alphasfunc, last_pp1_ts);
    LMSobj.dcurrentalphas = feval(LMSobj.TRmethod.dalphasfunc, last_pp1_ts); 
    LMSobj.currentbetas = feval(LMSobj.TRmethod.betasfunc, last_pp1_ts);
    LMSobj.dcurrentbetas = feval(LMSobj.TRmethod.dbetasfunc, last_pp1_ts);
    %
    out = LMSfuncToSolve(x, LMSobj);
end % of Arc_LMSfuncToSolve




function dout = dArc_LMSfuncToSolve(y, LMSobj)
% y = [x; lambda]
    x = y(1:end-1,1);
    lambda = y(end,1);

    startlambda = LMSobj.ArcContParms.StartLambda;
    stoplambda = LMSobj.ArcContParms.StopLambda; 
    lambdaspan = stoplambda-startlambda;

    told = LMSobj.tpts(LMSobj.timeptidx);
    % tolder = LMSobj.tpts(LMSobj.timeptidx-1);
    realtnew = LMSobj.realtnew; % this needs to be set up by whoever calls ArcCont

    tnew = ((lambda-startlambda)*realtnew + (stoplambda-lambda)*told)/lambdaspan;
    LMSobj.tnew = tnew; % one instance where pass-by-value is helpful

    % need to recompute alphas and betas (we have changed the time-step)

    p = LMSobj.TRmethod.order;
    last_pp1_ts(1) = tnew;
    LMSobj.timeptidx = LMSobj.timeptidx - 1; % sets the first prev timept to tn-2 - one instance where pass-by-value is helpful
    last_pp1_ts(2:(p+1)) = LMSobj.tpts(LMSobj.timeptidx:-1:LMSobj.timeptidx-p+1); 
    %
    LMSobj.currentalphas = feval(LMSobj.TRmethod.alphasfunc, last_pp1_ts);
    LMSobj.dcurrentalphas = feval(LMSobj.TRmethod.dalphasfunc, last_pp1_ts); 
    LMSobj.currentbetas = feval(LMSobj.TRmethod.betasfunc, last_pp1_ts);
    LMSobj.dcurrentbetas = feval(LMSobj.TRmethod.dbetasfunc, last_pp1_ts);
    %
    [doutx, dout_tnew] = dLMSfuncToSolve(x, LMSobj);
    dout = [doutx, (realtnew-told)*dout_tnew/lambdaspan]; % dg/dlambda is the second term
end % of Arc_LMSfuncToSolve
