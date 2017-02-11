function AFO = AlgebraicFunction(f_df_rhs_handle, DAE)
%function AFO = AlgebraicFunction(f_df_rhs_handle, DAE)
% Algebraic function is primarily used as input to non-linear solvers, e.g. NR.
% Ideally it should be derived from devices and netlist using an equation
% engine. Currently it is set up by reusing DAE's equation engines then
% extracting information from DAEs.
%
% Non-linear solvers (NR, etc.) solve algebraic functions in the following
% form:
%     f(x) = 0    (1)
% where x is an unknown vector and f is a vector function.
%
% To solve for x, the derivative of f(x), namely df(x) is often required.
% To use SPICE-compatible NR, another function rhs(x) is also needed.
% Therefore, f(x), df(x), rhs(x) constitute the major components of an AF
% object.
%
% In the simplest implementation without convergence aids, rhs(x) is equivalent
% to 
%     rhs(x) = df(x) * x - f(x);    (2)
% In this way, rhs(x) can be considered as consistent with f(x) and df(x).
%
% When convergence aids such as initialization and limiting are used in the NR
% algorithm, (2) may not always hold. In these cases, the rules for calculating
% rhs(x) can be found in help topic of NRinitlimiting.
%
%
%Arguments:
%  f_df_rhs_handle: function handle, returns f(x), df_dx(x), rhs(x), use:
%      [fx, dfx, rhsx, success] = feval(f_df_rhs_handle, x, AFO);
%
%  DAE: A DAEAPI structure/object. See help DAEAPI.
%
%Outputs:
%  AFO: an algebraic function structure/object, containing the following fields:
%
%    data members:
%      .DAE: DAE structure/object
%      .do_limit: flag, == 1 if considering limiting in f/df/rhs evaluation,
%                 default is 0 
%      .do_init:  flag, == 1 if considering initialization in f/df/rhs
%                 evaluation, default is 0 
%      .xlimOld: old values (from last successful NR iteration) of limited
%                variables
%      .LMS_add_on: used to store information needed by LMS transient analysis
%      .PreComputedStuff: used to store previously computed stuff while
%                         evaluating the algebraic function (f_df_rhs), which
%                         can be used to reduce redundant evaluations in TRAN
%                         and to implement Jacobian bypass
%
%    function members:
%      .nunks: function handle, returns number of unknowns, use:
%          nunks = feval(AFO.nunks, AFO);
%
%      .neqns: function handle, returns number of equations, use:
%          neqns = feval(AFO.neqns, AFO);
%
%      .nlimitedvars: function handle, returns number of limited variables, use:
%          nlimitedvars = feval(AFO.nlimitedvars, AFO);
%
%      .f_df_rhs: function handle, evaluates f/df/rhs(x) all together, use:
%          [fx, dfx, rhsx, success]  = AFO.f_df_rhs(x, AFO);
%
%      .f: function handle, evaluates f(x)
%          [fx, success] = AFO.f(x, AFO);
%
%      .df: function handle, evaluates df(x)
%          [dfx, success] = AFO.df(x, AFO);
%
%      .rhs: function handle, evaluates rhs(x)
%          [rhsx, success] = AFO.rhs(x, AFO);
%
%      .f_and_df: function handle, evaluates f(x) and df(x)
%          [fx, dfx, success] = AFO.f_and_df(x, AFO);
%    
%      .set_limit: function handle, sets up limiting flag (.do_limit), use:
%          AFO = AFO.set_limit(0/1, AFO);
%
%      .set_init: function handle, sets up init flag (.do_init), use:
%           AFO = AFO.set_init(0/1, AFO);
%
%      .set_xlimOld: function handle, sets up init flag (.do_init), use:
%           AFO = AFO.set_xlimOld(xlimOld, AFO);
%
%      .get_limit: function handle, returns limiting flag (.do_limit), use:
%           limitflag = AFO.get_limit(AFO);
%
%      .get_init: function handle, returns init flag (.do_init), use:
%           initflag = AFO.get_init(AFO);
%
%      .get_xlimOld: function handle, returns old values of limited variables
%           (.xlimOld), use:
%           xlimOld = AFO.get_xlimOld(AFO);
%
%Examples
%--------
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
%
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
%See also
%--------
%
% NRinitlimiting, NR, QSS
%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Type "help MAPPlicense" at the MATLAB/Octave prompt to see the license      %
%% for this software.                                                          %
%% Copyright (C) 2008-2013 Jaijeet Roychowdhury <jr@berkeley.edu>. All rights  %
%% reserved.                                                                   %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Changelog:
%------------
%2014/08/16: Tianshi Wang <tianshi@berkeley.edu>: added examples
%2014/05/20: Bichen Wu<bichen@berkeley.edu>: added .LMS_add_on and
%             .PrecomputedStuff to the AFobj.
%2012/12/20: Tianshi Wang <tianshi@berkeley.edu>: created and documented

    AFO = AlgebraicFunction_skeleton();
    
    AFO.DAE = DAE;

    AFO.n_unks = feval(DAE.nunks, DAE);
    AFO.n_eqns = feval(DAE.neqns, DAE);
    if 1 == DAE.support_initlimiting
        AFO.n_limitedvars = feval(DAE.nlimitedvars, DAE);
    else
        AFO.n_limitedvars = 0;
    end
    AFO.f_df_rhs = f_df_rhs_handle;
end
