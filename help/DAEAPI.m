%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%    This documents the functions in the DAEAPIv7 API
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%The DAE system with state x(t), inputs u(t) and outputs y(t), parameters p,
%and noise inputs n(t) is given by: 
%
% if the flag DAE.f_takes_inputs == 0:
%
%    qdot(x, p) + f(x, p) + B*u(t) + m(x, n(t), p) = 0
%    y = C*x + D*u(t)
%
% if the flag DAE.f_takes_inputs == 1:
%
%    qdot(x, p) + f(x, u(t), p) + m(x, n(t), p) = 0
%    y = C*x + D*u(t)
%
% [Note that B is not used if flag DAE.f_takes_inputs == 1].
% [Note also that B*u(t) is denoted by b(t) in various places below].
%
% B, C and D are matrices that multiply the inputs and state vector. M(x)
% is a matrix function multiplying the noise input vector.
%
% The input u(t) needs to be specified differently for different analyses:
%     - for QSS/DC: DAE.uQSS (same as DAE.uQSS, and set up by 
%       DAE.set_uQSS/DAE.set_uDC) is used.
%        - to specify an input in the DAE itself, set DAE.uQSSvec in DAE's
%          constructor.
%     - for transient: DAE.utransient (set up by DAE.set_utransient) is used.
%        - to specify an input in the DAE itself, set DAE.utfunc and DAE.utargs
%          in DAE's constructor.
%     - for SSS/AC: DAE.uLTISSS (same as DAE.uAC, set up by 
%          DAE.set_uLTISSS/DAE>set_uAC) is used.
%        - to specify an input in the DAE itself, set DAE.uffunc and DAE.ufargs
%          in DAE's constructor.
%     - for HB (one tone): DAE.uHB (set up by DAE.set_uHB) is used.
%        - to specify an input in the DAE itself, set DAE.uHBfunc and
%          DAE.uHBargs in DAE's constructor.
%    - unless you incorporate the inputs as an additional argument to f() - ie,
%      f_takes_inputs == 1 - you will also need to define B(DAE) correctly to
%      couple the input to the DAE. 
%    - you need to define C(DAE) and D(DAE) to get the outputs correctly.
%
%%%%%%%%%%%%%%%%%%%%%% DAEAPIv7 FUNCTIONS %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%DAE.version (string). Use: versionstring = DAE.version;
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%% CONSTRUCTOR %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%DAEAPI(uniqID, other arguments);
%    - the first argument uniqID should be a short unique ID string, containing
%      no whitespace or special characters.
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%% SIZES %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%DAE.nunks (function handle). Use: nunks = feval(DAE.nunks,DAE);
%    - returns the number of unknowns (size of the state vector x).
%DAE.neqns (function handle). Use: neqns = feval(DAE.neqns,DAE);
%    - returns the number of state equations (ie, size of q(x) and f(x)).
%DAE.ninputs (function handle). Use: ninps = feval(DAE.ninputs,DAE);
%    - returns the number of inputs (ie, size of u(t)).
%DAE.noutputs (function handle). Use: nouts = feval(DAE.noutputs,DAE);
%    - returns the number of outputs (ie, size of y(t)).
%DAE.nparms/nparams (function handle). Use: nparms = feval(DAE.nparms,DAE);
%    - returns the number of parameters (ie, size of DAE.parms).
%DAE.nNoiseSources (function handle). Use: m = feval(DAE.nNoiseSources,DAE);
%    - returns the number of noise inputs (ie, size of n(t)).
%
%%%%%%%%%%%% NAMES of DAE, UNKS, I/O, EQNS, PARMS, NOISE SOURCES %%%%%%%%%%%%%%
%
%DAE.uniqID (function handle). Use: name = feval(DAE.uniqID, DAE);
%    - returns the unique ID for the object, set up by the constructor's
%      first argument.
%DAE.name (function handle). Use: name = feval(DAE.name, DAE);
%    - name is a string - just a name for the DAE.
%    - NOTE: DAE.daename and DAE.DAEname are synonyms for DAE.name.
%DAE.unknames (function handle). Use: unames = feval(DAE.unknames,DAE);
%    - unames is a cell array containing names of unknowns (strings)
%    - note: internally, the unknames are kept in a cell array DAE.unknameList
%DAE.renameUnks (function handle). Use:
%   DAE = feval(DAE.renameUnks, oldnames_cellarray, newnames_cellarray, DAE);
%    - renames unknowns specified by oldnames_cellarray (useful after composing
%      DAEs)
%DAE.eqnnames (function handle). Use: eqnames = feval(DAE.eqnnames,DAE);
%    - eqnames is a cell array containing names of equations (strings) 
%    - note: internally, the eqnnames are kept in a cell array DAE.eqnnameList
%DAE.time_units (string). Use: DAE.time_units = 'hour'. Set by default to
%'sec'.
%
%
%DAE.renameEqns (function handle). Use:
%   DAE = feval(DAE.renameEqns, oldnames_cellarray, newnames_cellarray, DAE);
%    - renames equations specified by oldnames_cellarray (useful after
%      composing DAEs)
%DAE.inputnames (function handle). Use: inpnames = feval(DAE.inputnames,DAE);
%    - inpnames is a cell array containing names of the inputs (strings)
%DAE.outputnames (function handle). Use: opnames = feval(DAE.outputnames,DAE);
%    - opnames is a cell array containing names of the outputs (strings)
%DAE.parmnames/paramnames (function handle). 
%    Use: pnames = feval(DAE.parmnames,DAE);
%    - pnames is a cell array containing DAE parameter names (strings)
%    - note: internally, the parmnames are kept in a cell array
%      DAE.parmnameList
%DAE.renameParms (function handle). Use:
%   DAE = feval(DAE.renameParms, oldnames_cellarray, newnames_cellarray, DAE);
%    - renames parameters specified by oldnames_cellarray (useful after
%      composing DAEs)
%DAE.NoiseSourceNames (function handle): 
%    - Use: nnames = feval(DAE.NoiseSourceNames, DAE);
%
%%%%%%%%%%%%%%%%%%%%% PARAMETER SUPPORT FUNCTIONS %%%%%%%%%%%%%%%%%%%%%%%%%%
%
%DAE.parmdefaults/paramdefaults (function handle). 
%    Use: parms = feval(DAE.parmdefaults,DAE);
%    - parms is a cell array containing DAE parameter default values.
%
%DAE.getparms/getparams (function handle). Use:
%    parmvals = getparms(DAE)
%      - returns current values of all defined parameters (stored in DAE.parms)
%    OR: parmval = getparms(parmname, DAE)
%            ^                   ^         
%          value               string
%    OR: parmvals = getparms(parmnames, DAE)
%            ^                     ^ 
%       cellarray            cellarray
%
%DAE.setparms/setparams (function handle). Use:
%    outDAE = setparms(parms, DAE)
%                       ^     
%                 cellarray with values of all defined parameters.
%        sets current values of parameters (DAE.parms) to argument parms. 
%        parms should be a cell array containing values of all DAE parameters.
%        OR as outDAE = setparms(parmname, newval, DAE)
%                               ^         ^
%                             string    value
%        sets current value of the named parameter parmname to newval. 
%    OR as outDAE = setparms(parmnames, newvals, DAE)
%                               ^         ^
%                               cell arrays
%        sets current values of the named parameters in parmnames to newvals. 
%    DAE.setparms(...) can be used to update parameters during runtime. 
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%% CORE FUNCTIONS %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%Note on arguments for f(), q(), b*(), and other functions below:
%    x is a column vector of size nunks. E.g., x = rand(nunks,1);
%    u is a column vector of size ninputs.
%    t is scalar (time); freq is scalar (frequency).
%
%if DAE.f_takes_inputs == 0, then:
%    DAE.f (function handle). Use: outf = feval(DAE.f, x, DAE);
%        outf is a column vector of size neqns. Evaluates f(x).
%        x _must_ be a _column_ vector.
%else if DAE.f_takes_inputs == 1, then:
%    DAE.f (function handle). Use: outf = feval(DAE.f, x, u, DAE);
%        outf is a column vector of size neqns. Evaluates f(x,u).
%        u represents values of the inputs. x and u _must_ be _column_ vectors.
%
%DAE.q (function handle). Use: outq = feval(DAE.q, x, DAE);
%        outq is a column vector of size neqns. evaluates q(x).
%        x _must_ be a _column_ vector.
%
%DAE.fq (function handle). DAE.fq is a single function that evaluates and
%    returns f and q. It need not be defined, but if it is, it will be used by
%    some analyses (currently, only transient) for efficiency, in stead of
%    separate calls to f and q.  Defining fq does NOT remove the need for
%    defining f and q which are needed by many analyses and other components
%    of MAPP.  f and q can be set up simply by calling fq with appropriate
%    flags (see below); this is recommended.
%
%    Use:
%       if DAE.f_takes_inputs == 0, then:
%           [outf, outq] = feval(DAE.fq, x, u, flags, DAE);
%       if DAE.f_takes_inputs == 1, then:
%           [outf, outq] = feval(DAE.fq, x, flags, DAE);
%
%       - if flags.f is 1, outf is a column vector of size neqns, 
%         evaluating DAE.f.
%       - if flags.q is 1, outq is a column vector of size neqns, 
%         evaluating DAE.q.
%
%    The return values of .fq must be consistent with those of f/q.
%
%%%%%%%%%%%%%%%%%%%%%% FIRST DERIVATIVES wrt x %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%DAE.df_dx (function handle). Use:
%if DAE.f_takes_inputs == 0, then:
%    DAE.df_dx (function handle). Use: Jf = feval(DAE.df_dx, x, DAE);
%        Jf is a sparse matrix with neqns rows and nunks cols.
%else if DAE.f_takes_inputs == 1, then:
%    DAE.df_dx (function handle). Use: Jf = feval(DAE.df_dx, x, u, DAE);
%        Jf is a sparse matrix with neqns rows and nunks cols.
%
%DAE.dq_dx (function handle). Use: Jq = feval(DAE.dq_dx, x, DAE);
%        Jq is a sparse matrix with neqns rows and nunks cols.
%
%DAE.df_du (function handle):
%    Derivative of f(x,u) with respect to u. Needed for linearization.
%    This should be defined only if DAE.f_takes_inputs == 1.
%    Use: dfdu = feval(DAE.df_du, x, u, DAE);
%
%DAE.fqJ (function handle). DAE.fqJ is a single function that evaluates and
%    returns f, q, df_dx, dq_dx and df_du. It need not be defined, but if it
%    is, it will be used by some analyses (currently, only transient) for 
%    efficiency, in stead of separate calls to f, q, df_dx, dq_dx and df_du.
%    Defining fqJ does NOT remove the need for defining f, q, df_dx, dq_dx and
%    df_du, which are needed by many analyses and other components of MAPP.
%    f, q, df_dx, dq_dx, df_du and fq can be set up simply by calling fqJ with
%    appropriate flags set (see below); this is recommended.
%
%    Use:
%        if DAE.f_takes_inputs == 0, then:
%            fqJout = feval(DAE.fqJ, x, u, flags, DAE);
%        if DAE.f_takes_inputs == 1, then:
%            fqJout = feval(DAE.fqJ, x, flags, DAE);
%
%    fqJout is a structure with the following fields:
%    - if flags.f is 1, fqJout.f is a column vector of size neqns, 
%        evaluating DAE.f.
%    - if flags.q is 1, fqJout.q is a column vector of size neqns, 
%        evaluating DAE.q.
%    - if flags.dfdx is 1, fqJout.dfdx is a neqns-by-nunks matrix, 
%        evaluating DAE.df_dx.
%    - if flags.dqdx is 1, fqJout.dqdx is a neqns-by-nunks matrix, 
%        evaluating DAE.dq_dx.
%    - if flags.dfdu is 1, fqJout.dfdu is a neqns-by-ninputs matrix, 
%        evaluating DAE.df_du.
%
%    The return values of .fqJ must be consistent with those of
%                 f/q/df_dx/dq_dx/df_du.
%
%%%%%%%%%%%%%%%%%%%% INPUT- and OUTPUT-related functions %%%%%%%%%%%%%%%%%%%%%%
%
%DAE.uQSS or DAE.uDC (function handle). Use: outu = feval(DAE.uQSS, DAE);
%    outu is a real column vector of size ninputs. this function 
%    can be used for quiescent steady state (DC) analysis without
%    having to rely on utransient(t=0). 
%
%    - internally, this returns the stored vector DAE.uQSSvec.
%      uQSSvec be set in the DAE's constructor; this is typically
%      how a DC input will be hardcoded into the DAE's definition.
%      It can also be updated later using DAE.set_uQSS (see below).
%    
%    - TODO: clarify what should happen in each analysis if both 
%      utransient and uQSS are specified.
%
%DAE.set_uQSS or DAE.set_uDC (function handle). Use:
%   DAE = feval(DAE.set_uQSS, qssinputvec, DAE);
%    updates DAE.uQSSvec. See DAE.uQSS. 
%
%DAE.utransient (function handle). Use: outu = feval(DAE.utransient, t, DAE);
%    outu is a column vector of size ninputs; this can be used for
%    transient analysis. 
%    - internally, this calls the stored function handle 
%      utfunc, with arguments (t, utargs). utargs is a structure
%      that is also stored internally; it can contain any
%      parameters or data needed by utfunc. utfunc and utargs
%         can both be set in the constructor of the DAE; this is typically
%      how an input will be hardcoded into the DAE's definition. 
%      utfunc and utargs can also be updated during runtime using 
%      DAE.set_utransient (see below).
%    - note: utfunc(t, utargs) should be vectorized wrt the argument t.
%
%DAE.set_utransient (function handle). Use:
%   DAE = feval(DAE.set_utransient, utfunc, utargs, DAE);
%    updates utfunc and utargs. See DAE.utransient. 
%
%DAE.uLTISSS (function handle). Use: outu = feval(DAE.uLTISSS, f, DAE);
%    outu is a complex column vector of size ninputs - it represents
%    the complex amplitude of a sinusoidal input at frequency f. This fucntion 
%    can be used for LTI SSS (sinusoidal steady state, or AC) analysis.
%    - internally, this calls the stored function handle 
%      Uffunc, with arguments (f, Ufargs). ufargs is a structure
%      that is also stored internally; it can contain any
%      parameters or data needed by Uffunc. Uffunc and Ufargs
%      can both be set in the constructor of the DAE; this is typically
%      how an AC input will be hardcoded into the DAE's definition. 
%      Uffunc and Ufargs can also be updated during runtime using 
%      DAE.set_uLTISSS (see below).
%
%    - note: Uffunc(f, Ufargs) should be vectorized wrt the argument f.
%
%DAE.set_uLTISSS (function handle). Use:
%   DAE = feval(DAE.set_uLTISSS, Uffunc, Ufargs, DAE);
%    updates Uffunc and Ufargs. See DAE.uLTISSS. 
%
%DAE.uHB (function handle). Use: outu = feval(DAE.uHB, f, DAE);
%    outu is a complex sparse matrix of size ninputs x N_HB - it represents
%    the complex amplitude of each harmonic at frequency f. This function 
%    is used for harmonic balance (HB) analysis.
%    - internally, this calls the stored function handle 
%      uHBunc, with arguments (f, uHBargs). uHBargs is a structure
%      that is also stored internally; it can contain any
%      parameters or data needed by uHBfunc. uHBfunc and uHBargs
%      can both be set in the constructor of the DAE; this is typically
%      how a HB input will be hardcoded into a DAE's definition. 
%      uHBfunc and uHBargs can also be updated during runtime using 
%      DAE.set_uHB (see below).
%
%DAE.set_uHB (function handle). Use:
%   DAE = feval(DAE.set_uHB, uHBfunc, uHBargs, DAE);
%    updates uHBfunc and uHBargs. See DAE.uHB. 
%
%DAE.B (function handle). Use: bee = feval(DAE.B, DAE);
%    returns B. bee is a matrix of size neqns x ninputs.
%    Not used when DAE.f_takes_inputs == 1.
%
%DAE.C (function handle). Use: cee = feval(DAE.C, DAE);
%    returns C. cee is a matrix of size noutputs x nunks
%
%DAE.D (function handle). Use: dee = feval(DAE.D, DAE);
%    returns D. dee is a matrix of size noutputs x ninputs
%
%%%%%%%%%%%%%%%%%%%% NEWTON-RAPHSON ALGORITHM SUPPORT %%%%%%%%%%%%%%%%%%%%%%%%%
%
%DAE.support_initlimiting (bool flag):
% If DAE.support_initlimiting == 0 (default value), DAE's init/limiting support
%     for NR algorithm is turned off
% If DAE.support_initlimiting == 1, DAE's init/limiting support for NR
%     algorithm is turned on and the following API functions should be provided
%     or updated:
%
% - DAE.limitedvarnames (function handle).
%   - Use: lvnames = feval(DAE.limitedvarnames, DAE);
%   - returns names of the limited variables. Normally they are subset or
%     linear combinations of unknowns x
%
% - DAE.nlimitedvars (function handle).
%   - Use: nlvs = feval(DAE.nlimitedvars, DAE));
%   - returns number of limited variables
%
% - DAE.xTOxlim (function handle).
%   - Use: xlim = feval(DAE.xTOxlim, x, DAE));
%   - convert unknowns x to limited variables xlim when init/limiting is not
%     in effect
%   - by default, this is equivalent to xlim = xTOxlimMat * x;
%
% - DAE.xTOxlimMatrix (function handle).
%   - Use: xTOxlimMat = feval(DAE.xTOxlimMatrix, DAE));
%   - limited vaiable xlim is assumed to be subset or linear combination of x.
%     This function returns a matrix that can convert x to xlim
%     xlim = xTOxlimMatrix * x;
%
% - DAE.NRlimiting (function handle).
%   - Use: xlimNew = feval(DAE.NRlimiting, x, xlimOld, u, DAE);
%   - returns new values for limited variables based on the current x, u as
%     well as xlim's "old" values used in the last NR iteration
%
% - DAE.dNRlimiting_dx (function handle).
%   - Use: dxlimNewdx = feval(DAE.NRlimiting, x, xlimOld, u, DAE);
%     %TODO: dNRlimiting_du --> not seems to be used anywhere, but it will be
%     supported
%
% - DAE.NRinitGuess (function handle).
%   - Use: xlimInit = feval(DAE.NRinitGuess, u, DAE);
%   - returns initial values for limited variables in the first NR iteration
%
%Requirement: when .support_initlimiting is 1, f/q/fq should support both
%    calling syntaxes:
%    if DAE.f_takes_inputs == 1
%        feval(DAE.f, x, u, DAE) <--> feval(DAE.f, x, xlim, u, DAE)
%        feval(DAE.fq, x, u, flags, DAE) <--> feval(DAE.fq, x, xlim, u, flags, 
%                                                                         DAE);
%    if DAE.f_takes_inputs == 0
%        feval(DAE.f, x, DAE) <--> feval(DAE.f, x, xlim, DAE)
%        feval(DAE.fq, x, flags, DAE) <--> feval(DAE.fq, x, xlim, flags, DAE);
%    feval(DAE.q, x, DAE) <--> feval(DAE.q, x, xlim, DAE)
%
%    when xlim is not provided, it is calculated in f/q/fq as
%    xlim = feval(DAE.xTOxlim, x, DAE);
%
%
%%%%%%%%%%%%%%%%%%%%% NOISE SUPPORT FUNCTIONS %%%%%%%%%%%%%%%%%%%%%%%%%%
%
%DAE.NoiseStationaryComponentPSDmatrix (function handle):
%    Use: Snn = feval(DAE.NoiseStationaryComponentPSDmatrix, f, DAE);
%    specifies the stationary, 1-sided PSD matrix function of n(t), as 
%    a function of frequency f.
%    NOTE: this function should return single-sided PSDs. Eg,
%    2*q*Id for shot noise; 4kT/R for thermal noise current.
%
%DAE.m (function handle):
%    Use: m = feval(DAE.m, x, n, DAE);
%    returns m(x, n).
%    Note: m(...) should be for 1-sided PSDs
%
%DAE.dm_dx (function handle):
%    Use: Jm = feval(DAE.dm_dx, x, n, DAE);
%    returns d/dx m(x, n).
%
%DAE.dm_dn (function handle):
%    Use: M = feval(DAE.dm_dn, x, n, DAE);
%    returns d/dn m(x, n)
%    Note: M should be for 1-sided PSDs
%
%%%%%%%%%%%%%%%%% INTERNAL HOOKS/FUNCTIONS EXPOSED BY DAE API %%%%%%%%%%%%%%%%%
%
%DAE.internalfuncs (function handle). Returns a structure of named
%    function handles to internal functions exposed by
%    the DAE; may also contain other info, such as
%    usage strings. Use:
%    ifs = feval(DAE.internalfuncs, DAE)
%    stoichmat = feval(ifs.stoichmatfunc,DAE)
%    n = feval(DAE.nunks, DAE);
%    parms = feval(DAE.parmdefaults, DAE);
%    x = rand(n,1);
%    forwardrates = feval(ifs.forwardratefunc, x, parms, DAE);
%    dforwardrates = feval(ifs.dforwardratefunc, x, parms, DAE);
%
%%%%%%%%%%%%%%%%%%%% NOT PROPERLY IMPLEMENTED YET (placeholders) %%%%%%%%%%%%%%
%
%In the following functions, argument PObj is a Parameters object, which
%    contains a list of (real-valued) parameters with respect to
%    which parameter sensitivity analysis is to be performed.
%
%DAE.df_dp (function handle): Use: Pf = feval(DAE.df_dp, x, PObj, DAE);
%    returns df(x,p)/dp, where p are the parameters in PObj.
%
%DAE.dq_dp (function handle): Use: Pq = feval(DAE.dq_dp, x, PObj, DAE);
%    returns dq(x,p)/dp, where p are the parameters in PObj.
%
%DAE.dm_dp (function handle):
%
%
% -----------------------------------------------------------------
% USEFUL UTILITY FUNCTIONS FOR DAEs (but not part of the API)
% -----------------------------------------------------------------
% unkidx: finds the index in the x vector of an unknown, given its name
%    Example usage: i = unkidx('e1', DAE);
%    
% eqnidx: finds the index of an equation in all the DAE equations, given its
%   name
%    Example usage: i = eqnidx('KCL_n1', DAE);



%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Type "help MAPPlicense" at the MATLAB/Octave prompt to see the license     %
%% for this software.                                                         %
%% Copyright (C) 2008-2020 Jaijeet Roychowdhury <jr@berkeley.edu>. All rights %
%% reserved.                                                                  %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
