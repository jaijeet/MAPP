function TRparms = defaultTranParms()
%function TRparms = defaultTranParms()
%Returns default parameters for Linear Multi-Step methods (LMS):
%    TRparms.NRparms: Newton-Raphson parms for LMS:
%        = defaultNRparms(), but with the following changes:
%          .maxiter = 20;
%          .reltol = 1e-4; 
%          .abstol = 1e-9;
%          .terminating_newline = 0;
%          .limiting = 1;
%
%    TRparms.stepControlParms: (values shown below are the defaults)
%          .doStepControl = 1; % 1 => enable timestep control
%          .NRiterRange = [3, 8]; % NRiter range over which timestep
%                     % will not be changed.
%          .absMinStep = 1e-19; % absolute minimum timestep before
%                       % transient aborts. Also used to jump
%                       % forward to tstop if the previous timept
%                       % is about this close.
%          .relMinStep = 1e-12; % relative minimum timestep (relative
%                        % to tstop-tstart) before transient aborts.
%                        % Also used to jump forward to tstop if 
%                        % the previous timept is about this close.
%          .MaxStepFactor = 2; % factor by which initial supplied
%                      % timestep can be increased.
%          .increaseFactor = 1.05; % by how much to increase tstep if
%                      % NR iters is too low.
%          .cutFactor = 1.1; % by how much to decrease tstep if NR
%                    % iters is too high.
%          .NRfailCutFactor = 2; % by how much to decrease tstep if NR
%                    % fails.
%
%   TRparms.LTEstepControlParms: (values shown below are the defaults)
%         .doStepControl=1;  % 0 => enable LTE timestep control
%         .dofirststep=1;    % 1 => enable the fist tstep will be trfirststep
%          .errspecflag=0;    % 1 => norm spec  0 => per-q-element spec
%         .trfirststep=1e-5; % default first tstep value 
%         .trreltol = 5e-6;  % relative error spec for LTE control
%         .trabstol = 5e-11; % absolute error spec for LTE control
%         .trincreaseFactor = 1.1; % by how much to increase tstep if LTE 
%                                  % is smaller than error spec 
%         .trcutFactor = 1.2; % by how much to decrease next tstep if LTE 
%                             % is larger than error spec
%         .trredoFactor = 4; % if LTE value is larger than 
%                            % trredoFactor*error_spec, rerun this tstep 
%         .trredoCutFactor =2; % by how much to decrease this tstep if 
%                              % rerun this tstep 
%
%    TRparms.trandbglvl = TRparms.NRparms.dbglvl by default
%           -1: not even errors
%            0: errors only
%            1: minimal output: 
%              - '+' for successful timestep
%              - '/' for cut/redone timestep due to NR failure
%              - '|' for reduced timestep due to too many NR iterations
%              - '\' for increased timestep due to too many NR
%                  iterations
%            2: informational output
%
%    TRparms.stopFunc = 'undefined'; 
%        used by LMStimeStepping to set up alternative ways to stop
%        timestepping. if defined, stopFunc should be a function handle
%         callable as follows:
%            done = feval(stopFunc, t, x, stopFuncArgs);
%        where
%            t is a timepoint value
%            x is the solution of the DAE at t
%            stopFuncArgs is a structure containing any other 
%                information that stopFunc might need.
%            and done == 1 if the transient simulation should stop,
%                0 otherwise.
%        For example, the stopFunc used by Euler Newton Curve Tracing
%        to stop ODE solution when a component of the solution x
%        crosses a threshold is:
%        stopFunc = @(s, y, arg) (y(end,1)-arg.StopLambda)* ...
%         ((arg.StopLambda > arg.StartLambda)*2-1) >= 0 ...
%         || s >= arg.MaxArcLength;
%            
%    TRparms.stopFuncArgs = 'undefined'; 
%        Any arguments needed by stopFunc, above.
%
%    TRparms.correctorFunc = 'undefined'; 
%         correctorFunc should be set to a function handle if it is
%         desired to refine xnew (obtained by applying the LMS formula,
%         typically an explicit one) at each timestep. It is useful for
%         homotopy, where FE is used as predictor (ie, the LMS
%         algorithm), and MPPI_NR for the corrector. The arguments and
%         return values of correctorFunc should be as follows:
%
%         [newx, newt, iters, success] = feval(correctorFunc, t, x, args)
%           where:
%            t is a timepoint value
%            x is the solution of the DAE at t
%            newx is the new/corrected/udpated value of x
%            newx is the new/corrected/udpated value of t
%            iters is the number of (presumably NR) interations
%                taken to do the correction
%            success == 1 if correctorFunc succeeded, 0 otherwise
%
%    TRparms.correctorFuncArgs = 'unassigned'; 
%
%    TRparms.useAFobjForNR = 1 (default). If set to 1, uses Tianshi's
%           AlgebraicFunction object interface for NR. If set to 0, uses
%           JR's original simple interface to NR, where you specify f and
%           df handles to NR as its arguments.
%
%    TRparms.doSpeedup = 1 (default). If set to 1, uses Bichen's efficient
%           version of LMS routines - leads to a very significant speedup
%           (upto about 5x for longer transients with expensive devices like
%           BSIM). But currently, this is supported only for useAFobjForNR==1.
%
%    TRparms.homtopyAsLastResort = 0 (default). If set to 1, attempts homotopy 
%           after repeated N-R failures cut the timestep to the minimum 
%           (see .stepControlParms above). Currently implemented only in 
%           JR's original simple interface, where you specify f and
%           df handles to NR as its arguments (ie, not in Tianshi's
%           AlgebraicFunction object interface [TODO]).
%
%
%Examples
%--------
% nsegs = 1; R = 1e3; C = 1e-6;
% DAE =  RClineDAEAPIv6('', nsegs, R, C);
% 
% % set transient input to the DAE
% utargs.A = 1; utargs.f=1e3; utargs.phi=0;
% utfunc = @(t, args) args.A*sin(2*pi*args.f*t + args.phi);
% DAE = feval(DAE.set_utransient, utfunc, utargs, DAE);
% 
% % set up LMS object
% TRparms = defaultTranParms(); 
% TRparms.stepControlParms.doStepControl = 0; % disable timestep control
% TRmethods = LMSmethods(); % defines FE, BE, TRAP, and GEAR2 
% TransObjTRAP = LMS(DAE, TRmethods.TRAP, TRparms);
% 
% % run transient and plot
% xinit = 1;
% tstart = 0;
% tstep = 10e-6;
% tstop = 5e-3;
% TransObjTRAP = feval(TransObjTRAP.solve, TransObjTRAP, ...
%       xinit, tstart, tstep, tstop);
% [thefig, legends] = feval(TransObjTRAP.plot, TransObjTRAP);
%
%
%See also
%--------
%
%    LMS, NR, defaultNRparms, transientPlot
%

%Changelog:
%---------
%2014/07/05: JR <jr@berkeley.edu>: renamed to defaultTranParms.
%2014/06/30: Bichen Wu<bichen@berkeley.edu>: added a switch to turn on/off LMS
%            speedup
%2014/02/07: Jian Yao <jianyao@berkeley.edu>: added default parms of LTE-based 
%            method. 
%

    NRparms = defaultNRparms();
    NRparms.maxiter = 20;
    NRparms.reltol = 1e-4; 
    NRparms.abstol = 1e-9;
    NRparms.terminating_newline = 0;
    NRparms.limiting = 1; % FIXME: transient limiting may be different from QSS limiting
    TRparms.NRparms = NRparms;
    %
    stepControlParms.doStepControl = 1; % 1 => enable timestep control
    stepControlParms.NRiterRange = [3, 8]; % NRiter range over which timestep will not be changed.
    stepControlParms.absMinStep = 1e-19; % absolute minimum timestep before
                                         % transient aborts.  Also used to
                                         % jump forward to tstop if the
                                         % previous timept is about this
                                         % close.
    stepControlParms.relMinStep = 1e-12; % relative minimum timestep (relative
                                         % to tstop-tstep) before transient
                                         % aborts.  Also used to jump forward
                                         % to tstop if the previous timept is
                                         % about this close.
    stepControlParms.MaxStepFactor = 2; % factor by which initial supplied timestep can be increased.
    stepControlParms.increaseFactor = 1.05; % by how much to increase tstep if NR iters is too low.
    stepControlParms.cutFactor = 1.1; % by how much to decrease tstep if NR iters is too high.
    stepControlParms.NRfailCutFactor = 2; % by how much to decrease tstep if NR fails.
    TRparms.stepControlParms = stepControlParms;
    %
    
        %%%%%%%%% Added by jian %%%%%%%%%%%
        LTEstepControlParms.doStepControl=0;  % 1 => enable LTE timestep control
        LTEstepControlParms.dofirststep=1;    % 1 => enable the fist tstep will be trfirststep
        LTEstepControlParms.errspecflag=0;    % 1 => norm spec  0 => per-q-element spec
        LTEstepControlParms.trfirststep=1e-5; % default first tstep value 
        LTEstepControlParms.trreltol = 5e-6;  % relative error spec for LTE control
        LTEstepControlParms.trabstol = 5e-11; % absolute error spec for LTE control
        LTEstepControlParms.trincreaseFactor = 1.1; % by how much to increase tstep if LTE is smaller than error spec 
        LTEstepControlParms.trcutFactor = 1.2; % by how much to decrease next tstep if LTE is larger than error spec
        LTEstepControlParms.trredoFactor = 4; % if LTE value is larger than trredoFactor*error_spec, rerun this tstep 
        LTEstepControlParms.trredoCutFactor =2; % by how much to decrease this tstep if rerun this tstep 
        TRparms.LTEstepControlParms = LTEstepControlParms; 
        %
    
    TRparms.trandbglvl = NRparms.dbglvl;
        % -1: not even errors
        %  0: errors only
        %  1 (default): minimal output: 
        %    - '+' for successful timestep
        %    - '/' for cut/redone timestep due to NR failure
        %    - '|' for reduced timestep due to too many NR iterations
        %    - '\' for increased timestep due to too many NR iterations
        %  2: informational output
    %

    % stopFunc should be set up during constructor time if LMStimestepping is called
    % without a tstop argument. If the tstop argument is supplied, then these
    % will be ignored.
    TRparms.stopFunc = 'unassigned'; % will be defined to (t > tstop) in LMStimestepping
    TRparms.stopFuncArgs = 'unassigned'; % will be defined to tstop in LMStimestepping

    % correctorFunc should be set up during constructor time if a corrector step is
    % desired to refine xnew at each timestep. Useful for homotopy, where FE is
    % used as predictor, and MPPI_NR for the corrector.
    TRparms.correctorFunc = 'unassigned'; 
    TRparms.correctorFuncArgs = 'unassigned'; 
    % bichen: LMS speedup switch. Acceptable values are {0,1}
    % if 1, do LMS speedup
    % if 0, do original LMS without speedup
    TRparms.doSpeedup = 1;
    %
    TRparms.useAFobjForNR = 1;  
    TRparms.homotopyAsLastResort = 1;
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Type "help MAPPlicense" at the MATLAB/Octave prompt to see the license      %
%% for this software.                                                          %
%% Copyright (C) 2008-2013 Jaijeet Roychowdhury <jr@berkeley.edu>. All rights  %
%% reserved.                                                                   %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
