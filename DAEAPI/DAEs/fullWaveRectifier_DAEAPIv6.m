function DAE = fullWaveRectifier_DAEAPIv6(uniqIDstr)  % DAEAPIv6.2
%function DAE = fullWaveRectifier_DAEAPIv6(uniqIDstr)  % DAEAPIv6.2
% Fullwave reactifier feeding a load of a resistor and a parallel capacitor
%author: J. Roychowdhury, 2011/09/27
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% The Circuit:
%
% The is a full wave rectifier feeding a load of a resistor and a parallel capacitor.
% - The output nodes are P and N;
% - RL is connected between P and N;
% - CL is also between P and N;
% - from N, two diodes go to ground and the input Vin, respectively;
% - at P, two diodes come in from ground and the input Vin, respectively.
%
% Equation system: Not strict MNA, because Vin node voltage unknown has been
% eliminated, leading to a smaller system of equations, of size 2.
%
% Unknowns: x = [eP; eN].
%
% Equations:
% P KCL: - diodeInP(Vin-eP) - diodeGndP(0-eP) + (eP-eN)/RL + d/dt (C(eP-eN))
% N KCL: diodeNIn(eN-Vin) + diodeNGnd(eN-0) - (eP-eN)/RL - d/dt (C(eP-eN))
% 
% The (single) input is Vin. A DC/QSS input of 10V has been put in. You can change
% it by calling DAE.set_uQSS(...). A sinusoidal transient input at 1KHz has 
% also been put in.
%
% The (single) output is Vout = eP - eN.
%
% Note that since we cannot represent the effect of Vin as
% an additive input, we set the flag DAE.f_takes_inputs to 1. This means
% that f() becomes a function of 2 arguments: f(x,u). Similarly with df_dx.
% DAE.B(...) is not used when DAE.f_takes_inputs == 1.
%
% the DAE is: qdot(x) + f(x, u(t))  = 0.
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%
%see DAEAPIv6_doc.m for a description of the functions here.
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Type "help MAPPlicense" at the MATLAB/Octave prompt to see the license      %
%% for this software.                                                          %
%% Copyright (C) 2008-2013 Jaijeet Roychowdhury <jr@berkeley.edu>. All rights  %
%% reserved.                                                                   %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%Changelog:
%---------
%2014/07/28: Tianshi Wang <tianshi@berkeley.edu> commented out NRlimiting, use
%            default (no limiting)
%            Also updated f/q/df/dq to be compatible with DAEAPIv7
%sometime:   updated with init/limiting by someone, but NRlimiting function
%            won't run. It is also put in MAPPtest, but only AC is tested, so
%            NRlimiting is never called
%2011/09/27: Jaijeet Roychowdhury <jr@berkeley.edu> created





%%%%%%%%%%%%%%%% Begin main function: DAE "constructor" %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% pull in virtual base class:
    DAE = DAEAPI_common_skeleton();
% version, help string: 
    DAE.version = 'DAEAPIv7';
    DAE.Usage = help('fullWaveRectifier_DAEAPIv6');
    if nargin < 1
        DAE.uniqIDstr = '';
    else
        DAE.uniqIDstr = uniqIDstr;
    end
    %
%data: store problem parameters, set up inputs, precompute stuff
    DAE.unknameList = setup_unknames(DAE);
    DAE.eqnnameList = setup_eqnnames(DAE);
    DAE.parmnameList = setup_parmnames(DAE);
    DAE.limitedvarnameList = setup_unknames(DAE);
    % data: current values of parameters, can be changed by setparms
    DAE.parms = parmdefaults(DAE);
    %
    DAE.uQSSvec = 'unassigned'; % needed for QSS (DC analysis). Should become a real scalar/vector.
    DAE.utfunc = 'unassigned'; % needed for transient analysis. Should become a function call.
    DAE.utargs = 'unassigned'; % needed for transient analysis. Should become a structure.
    DAE.Uffunc = 'unassigned'; % needed for AC/SSS analysis. Should become a function call.
    DAE.Ufargs = 'unassigned'; % needed for AC/SSS analysis. should become a structure
    %
    DAE.uQSSvec = 10.0; % 10V DC input
    %
    mycos = @(t,args) 10*cos(2*pi*1000*t);
    DAE = feval(DAE.set_utransient, mycos, [], DAE); % sinusoidal transient input
% sizes: 
    DAE.nunks = @nunks;
    DAE.neqns = @neqns;
    DAE.ninputs = @ninputs;
    DAE.noutputs = @noutputs;
    %
% f, q: 
    DAE.f_takes_inputs = 1;
    DAE.f = @f;
    DAE.q = @q;
    %
% df, dq
    DAE.df_dx = @df_dx;
    DAE.dq_dx = @dq_dx;
    DAE.df_du = @df_du;
    %
% input-related functions
    % discontinued: DAE.b = @btransient; DAE.bQSS; DAE.bLTISSS; 
    %
    DAE.B = @B;
    %DAE.dB_dx = @dB_dx; no support yet
    %DAE.dB_dp = @dB_dp; no support yet
    %
% output-related functions
    % what makes sense here for transient, LTISSS, etc.?
    DAE.C = @C;
    %DAE.dC_dx = @dC_dx; no support yet
    %DAE.dC_dp = @dC_dp; no support yet
    DAE.D = @D;
    %DAE.dD_dx = @dD_dx; no support yet
    %DAE.dD_dp = @dD_dp; no support yet
    %
% names
    DAE.uniqID   = @uniqID;
    DAE.daename   = @daename;
    DAE.unknames  = @unknames_DAEAPI;
    DAE.eqnnames  = @eqnnames_DAEAPI;
    DAE.inputnames  = @inputnames;
    DAE.outputnames  = @outputnames;
    DAE.renameUnks = @renameUnks_DAEAPI;
    DAE.renameEqns = @renameEqns_DAEAPI;
    DAE.renameParms = @renameParms_DAEAPI;
    %
% QSS initial guess support
    DAE.QSSinitGuess = @QSSinitGuess;
    % DAE.NRinitGuess = @NRinitGuess;
    %
% NR limiting support
    DAE.support_initlimiting = 1;
    %DAE.NRlimiting = @NRlimiting;
    DAE.x_to_xlim_matrix = eye(feval(DAE.nunks,DAE));
    %
% parameter support - see also input- and output-related function sections
    DAE.nparms = @nparms;
    DAE.parmdefaults  = @parmdefaults;
    DAE.parmnames = @parmnames_DAEAPI;
    DAE.getparms  = @default_getparms_DAE;
    DAE.setparms  = @default_setparms_DAE;
    % first derivatives with respect to parameters - for sensitivities
    DAE.df_dp  = @df_dp;
    DAE.dq_dp  = @dq_dp;
    % data: current values of parameters, can be changed by setparms
    %
% helper functions exposed by DAE
    DAE.internalfuncs = @internalfuncs;
    %
% functions for supporting noise
    % 
    DAE.nNoiseSources = @nNoiseSources;
    DAE.NoiseSourceNames = @NoiseSourceNames;
    DAE.NoiseStationaryComponentPSDmatrix = 'undefined'; % @NoiseStationaryComponentPSDmatrix;
    DAE.m = 'undefined'; % @m;
    DAE.dm_dx = 'undefined'; % @dm_dx;
    DAE.dm_dn = 'undefined'; % @dm_dn;
%
% end DAE "constructor"

%%%%%%%%%%%%%%%%%%%%%%%%%%%% SIZES %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function out = nunks(DAE)
    out = 2;
% end nunks(...)

function out = neqns(DAE)
    out = 2;
% end neqns(...)

function out = ninputs(DAE)
    out = 1; % Vin
% end ninputs(...)

function out = noutputs(DAE)
    out = 1; % Vout = eCL - eCR
% end noutputs(...)

function out = nparms(DAE)
    out = 10; % RL, CL, {diodeInP,diodeGndP,diodeNIn,diodeNGnd}_{Is,Vt}
% end nparms(...)

function out = nNoiseSources(DAE)
    out = 0; % noise is not considered for this example
% end nNoiseSources(...)

%%%%%%%%%%%% NAMES of DAE, UNKS, I/O, EQNS, PARMS, NOISE SOURCES %%%%%%%%%%%%%%
function out = uniqID(DAE)
    out = DAE.uniqIDstr;
% end daename()

function out = daename(DAE)
    out = sprintf('Full wave diode rectifier');
% end daename()

% unknames is in unknames.m
function out = setup_unknames(DAE)
    out = {'eP', 'eN'};
% end unknames()

% eqnnames is in eqnnames.m
function out = setup_eqnnames(DAE)
    out = {'P_KCL', 'N_KCL'};
% end eqnnames()

function out = inputnames(DAE)
    out = {'Vin'};
% end inputnames()

function out = outputnames(DAE)
    out = {'Vout=eP-eN'};
% end outputnames()

% parmnames is in parmnames.m
function out = setup_parmnames(DAE)
    % RL, CL, {diodeInP,diodeGndP,diodeNIn,diodeNGnd}_{Is,Vt}
    out = {'RL', 'CL'};
    i = 3;
    diodes = {'diodeInP','diodeGndP','diodeNIn','diodeNGnd'};
    dparms = {'Is', 'Vt'};
    for j = 1:length(diodes)
        for k = 1:length(dparms)
            out{i} = sprintf('%s_%s', diodes{j}, dparms{k});
            i = i+1;
        end
    end
% end parmnames()

function out = NoiseSourceNames(DAE)
    out = {};
% end NoiseSourceNames()

%renameUnks is in renameUnks.m
%renameEqns is in renameEqns.m
%renameParms is in renameParms.m


%%%%%%%%%%%%%%%%%%%%% PARAMETER SUPPORT FUNCTIONS %%%%%%%%%%%%%%%%%%%%%%%%%%
function parmvals = parmdefaults(DAE)
    %order: RL, CL, {diodeInP,diodeGndP,diodeNIn,diodeNGnd}_{Is,Vt}
    parmvals = {1000, 1e-6};
    i = 3;
    diodes = {'diodeInP','diodeGndP','diodeNIn','diodeNGnd'};
    dparmvals = {1e-12, 0.025};
    for j = 1:length(diodes)
        for k = 1:length(dparmvals)
            parmvals{i} = dparmvals{k};
            i = i+1;
        end
    end
% end parmdefaults(...)

% getparms is in getparms.m
% setparms is in setparms.m

%%%%%%%%%%%%%%%%%%%%%%%%%%%% CORE FUNCTIONS %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function fout = f(x, xlim, u, DAE)
	if 3 == nargin 
		DAE = u;
		u = xlim;
		xlim = feval(DAE.xTOxlim, x, DAE);
	end
    eP = x(1); eN = x(2);
    Vin = u;

    % create variables of the same names as the parameters and assign
    % them the values in DAE.parms
    pnames = parmnames_DAEAPI(DAE);
    for i = 1:nparms(DAE)
        %assignin('base', pnames{i}, DAE.parms{i}) % doesn't seem to work, for some reason
        evalstr = sprintf('%s = DAE.parms{i};', pnames{i});
        eval(evalstr);
    end

    dobj = diode;

    % P KCL: - diodeInP(Vin-eP) - diodeGndP(0-eP) + (eP-eN)/RL + d/dt (C(eP-eN))
    IdiodeInP = feval(dobj.f, Vin-eP, diodeInP_Is, diodeInP_Vt);
    IdiodeGndP = feval(dobj.f, 0-eP, diodeGndP_Is, diodeGndP_Vt);
    fout(1,1) = -IdiodeInP - IdiodeGndP + (eP-eN)/RL;

    % N KCL: diodeNIn(eN-Vin) + diodeNGnd(eN-0) - (eP-eN)/RL - d/dt (C(eP-eN))
    IdiodeNIn = feval(dobj.f, eN-Vin, diodeNIn_Is, diodeNIn_Vt);
    IdiodeNGnd = feval(dobj.f, eN-0, diodeNGnd_Is, diodeNGnd_Vt);
    fout(2,1) = IdiodeNIn + IdiodeNGnd - (eP-eN)/RL;
% end f(...)

function qout = q(x, xlim, DAE)
	if 2 == nargin 
		DAE = xlim;
		xlim = feval(DAE.xTOxlim, x, DAE);
	end
    eP = x(1); eN = x(2);

    % create variables of the same names as the parameters and assign
    % them the values in DAE.parms
    pnames = parmnames_DAEAPI(DAE);
    for i = 1:nparms(DAE)
        %assignin('base', pnames{i}, DAE.parms{i}) % doesn't seem to work, for some reason
        evalstr = sprintf('%s = DAE.parms{i};', pnames{i});
        eval(evalstr);
    end

    % P KCL: - diodeInP(Vin-eP) - diodeGndP(0-eP) + (eP-eN)/RL + d/dt (CL(eP-eN))
    qout(1,1) = CL*(eP-eN);
    
    % N KCL: diodeNIn(eN-Vin) + diodeNGnd(eN-0) - (eP-eN)/RL - d/dt (CL(eP-eN))
    qout(2,1) = - CL*(eP-eN);
% end q(...)

%%%%%%%%%%%%%%%%%%%%%% FIRST DERIVATIVES wrt x %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function Jf = df_dx(x, xlim, u, DAE)
	if 3 == nargin 
		DAE = u;
		u = xlim;
		xlim = feval(DAE.xTOxlim, x, DAE);
	end
    eP = x(1); eN = x(2);
    Vin = u;

    % create variables of the same names as the parameters and assign
    % them the values in DAE.parms
    pnames = parmnames_DAEAPI(DAE);
    for i = 1:nparms(DAE)
        %assignin('base', pnames{i}, DAE.parms{i}) % doesn't seem to work, for some reason
        evalstr = sprintf('%s = DAE.parms{i};', pnames{i});
        eval(evalstr);
    end

    dobj = diode;

    % P KCL: - diodeInP(Vin-eP) - diodeGndP(0-eP) + (eP-eN)/RL + d/dt (C(eP-eN))
    [IdiodeInP,d_IdiodeInP] = feval(dobj.f, Vin-eP, diodeInP_Is, diodeInP_Vt);
    [IdiodeGndP, d_IdiodeGndP] = feval(dobj.f, 0-eP, diodeGndP_Is, diodeGndP_Vt);
    %fout(1,1) = -IdiodeInP - IdiodeGndP + (eP-eN)/RL;
    %
    %x:    eP    eN
    %    1    2
    Jf(1,1) = d_IdiodeInP + d_IdiodeGndP + 1/RL;
    Jf(1,2) = -1/RL;

    % N KCL: diodeNIn(eN-Vin) + diodeNGnd(eN-0) - (eP-eN)/RL - d/dt (C(eP-eN))
    [IdiodeNIn, d_IdiodeNIn] = feval(dobj.f, eN-Vin, diodeNIn_Is, diodeNIn_Vt);
    [IdiodeNGnd, d_IdiodeNGnd] = feval(dobj.f, eN-0, diodeNGnd_Is, diodeNGnd_Vt);
    %fout(2,1) = IdiodeNIn + IdiodeNGnd - (eP-eN)/RL;
    %
    %x:    eP    eN
    %    1    2
    Jf(2,1) = -1/RL;
    Jf(2,2) = d_IdiodeNIn + d_IdiodeNGnd + 1/RL;
	if 3 == nargin
	    Jf = Jf + ...
	           feval(DAE.df_dxlim, x, xlim, u, DAE)...
	           *feval(DAE.xTOxlimMatrix, DAE);
	end
% end df_dx(...)

function Jq = dq_dx(x, xlim, DAE)
	if 2 == nargin 
		DAE = xlim;
		xlim = feval(DAE.xTOxlim, x, DAE);
	end
    eP = x(1); eN = x(2);

    % create variables of the same names as the parameters and assign
    % them the values in DAE.parms
    pnames = parmnames_DAEAPI(DAE);
    for i = 1:nparms(DAE)
        %assignin('base', pnames{i}, DAE.parms{i}) % doesn't seem to work, for some reason
        evalstr = sprintf('%s = DAE.parms{i};', pnames{i});
        eval(evalstr);
    end

    % P KCL: - diodeInP(Vin-eP) - diodeGndP(0-eP) + (eP-eN)/RL + d/dt (CL(eP-eN))
    %qout(1,1) = CL*(eP-eN);
    Jq(1,1) = CL;
    Jq(1,2) = -CL;
    
    % N KCL: diodeNIn(eN-Vin) + diodeNGnd(eN-0) - (eP-eN)/RL - d/dt (CL(eP-eN))
    %qout(2,1) = - CL*(eP-eN);
    Jq(2,1) = -CL;
    Jq(2,2) = CL;
	if 2 == nargin
	    Jq = Jq + ...
	           feval(DAE.dq_dxlim, x, xlim, DAE) ...
	           *feval(DAE.xTOxlimMatrix, DAE);
	end
% end dq_dx(...)

function dfdu = df_du(x, xlim, u, DAE)
	if 3 == nargin 
		DAE = u;
		u = xlim;
		xlim = feval(DAE.xTOxlim, x, DAE);
	end
    eP = x(1); eN = x(2);
    Vin = u;

    % create variables of the same names as the parameters and assign
    % them the values in DAE.parms
    pnames = parmnames_DAEAPI(DAE);
    for i = 1:nparms(DAE)
        %assignin('base', pnames{i}, DAE.parms{i}) % doesn't seem to work, for some reason
        evalstr = sprintf('%s = DAE.parms{i};', pnames{i});
        eval(evalstr);
    end

    dobj = diode;

    % P KCL: - diodeInP(Vin-eP) - diodeGndP(0-eP) + (eP-eN)/RL + d/dt (C(eP-eN))
    [IdiodeInP,d_IdiodeInP] = feval(dobj.f, Vin-eP, diodeInP_Is, diodeInP_Vt);
    %fout(1,1) = -IdiodeInP - IdiodeGndP + (eP-eN)/RL;
    %
    %u:    Vin
    %    1
    dfdu(1,1) = - d_IdiodeInP;

    % N KCL: diodeNIn(eN-Vin) + diodeNGnd(eN-0) - (eP-eN)/RL - d/dt (C(eP-eN))
    [IdiodeNIn, d_IdiodeNIn] = feval(dobj.f, eN-Vin, diodeNIn_Is, diodeNIn_Vt);
    %fout(2,1) = IdiodeNIn + IdiodeNGnd - (eP-eN)/RL;
    %
    %u:    Vin
    %    1
    dfdu(2,1) = - d_IdiodeNIn;
% end df_du(...)

%%%%%%%%%%%%%%%%%%% FIRST DERIVATIVES wrt parms %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function P_f = df_dp(x, xlim, PObj, DAE)
    P_f = sparse([]);
    % NO parameter derivative support yet
% end df_dp(...)

function P_q = dq_dp(x, xlim, PObj, DAE)
    P_q = sparse([]);
    % NO parameter derivative support yet
% end dq_dp(...)


%%%%%%%%%%%%%%%%%%%%%% INPUT-related functions %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function out = B(DAE)
    if (nargin > 1)
       fprintf(2,'out = B(x, DAE) not supported yet (no tensor support).\n');
       return;
    end
    out = 1; % but not used
% end B(...)

%%%%%%%%%%%%%%%%%%%%%% OUTPUT-related functions %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function out = C(DAE)
    out = [1,-1]; % Vout = eP - eN
% end C(...)


function out = D(DAE)
    out = 0;
% end D(...)

%%%%%%%%%%%%%%%%% QSS/NR INITIAL GUESS SUPPORT %%%%%%%%%%%%%%%%%%%%%%
function out = QSSinitGuess(u, DAE)
    % in principle, could use some heuristic dependent on the input
    % and the parameters,
    % x = [eP; eR];
    knee = 0.6;
    if u > knee
        out = [u-knee; knee];
    elseif u < -0.7
        out = [-knee; u+knee];
    else
        out = [0; 0];
    end
%end QSSinitGuess

function out = NRinitGuess(x, u, DAE)
    % in principle, could use some heuristic dependent on the input
    % and the parameters,
    % x = [eP; eR];
    knee = 0.6;
    if u > knee
        out = [u-knee; knee];
    elseif u < -0.7
        out = [-knee; u+knee];
    else
        out = [0; 0];
    end
%end QSSinitGuess


%%%%%%%%%%%%%%%%% NR LIMITING SUPPORT %%%%%%%%%%%%%%%%%%%%%%
function newdx = NRlimiting(dx, xold, uold, DAE)
    eP_dx = dx(1); eN_dx = dx(2);
    eP_old = xold(1); eN_old = xold(2);
    Vin_old = uold;

    alpha = 1;

    % create variables of the same names as the parameters and assign
    % them the values in DAE.parms
    pnames = parmnames_DAEAPI(DAE);
    for i = 1:nparms(DAE)
        %assignin('base', pnames{i}, DAE.parms{i}) % doesn't seem to work, for some reason
        evalstr = sprintf('%s = DAE.parms{i};', pnames{i});
        eval(evalstr);
    end

    % diodeInP
    diodeInP_oldx = Vin_old - eP_old;
    diodeInP_dx = - eP_dx;
    if abs(diodeInP_dx) > 1.0e-5
        vcrit = diodeInP_Vt * log(diodeInP_Vt / (sqrt(2) * diodeInP_Is));
        diodeInP_newdx = pnjlim_dx(diodeInP_dx, diodeInP_oldx, diodeInP_Vt, vcrit);
        alpha = diodeInP_newdx/diodeInP_dx;
    end

    % diodeGndP
    diodeGndP_oldx = 0 - eP_old;
    diodeGndP_dx = - eP_dx;
    if abs(diodeGndP_dx) > 1.0e-5
        vcrit = diodeGndP_Vt * log(diodeGndP_Vt / (sqrt(2) * diodeGndP_Is));
        diodeGndP_newdx = pnjlim_dx(diodeGndP_dx, diodeGndP_oldx, diodeGndP_Vt, vcrit);
        alpha = min(diodeGndP_newdx/diodeGndP_dx, alpha);
    end

    % diodeNIn
    diodeNIn_oldx = eN_old-Vin_old;
    diodeNIn_dx = eN_dx;
    if abs(diodeNIn_dx) > 1.0e-5
        vcrit = diodeNIn_Vt * log(diodeNIn_Vt / (sqrt(2) * diodeNIn_Is));
        diodeNIn_newdx = pnjlim_dx(diodeNIn_dx, diodeNIn_oldx, diodeNIn_Vt, vcrit);
        alpha = min(diodeNIn_newdx/diodeNIn_dx, alpha);
    end

    % diodeNGnd
    diodeNGnd_oldx = eN_old-0;
    diodeNGnd_dx = eN_dx;
    if abs(diodeNGnd_dx) > 1.0e-5
        vcrit = diodeNGnd_Vt * log(diodeNGnd_Vt / (sqrt(2) * diodeNGnd_Is));
        diodeNGnd_newdx = pnjlim_dx(diodeNGnd_dx, diodeNGnd_oldx, diodeNGnd_Vt, vcrit);
        alpha = min(diodeNGnd_newdx/diodeNGnd_dx, alpha);
    end
    newdx = dx*alpha;

%%%%%%%%%%%%%%%%%%%%% NOISE SUPPORT FUNCTIONS %%%%%%%%%%%%%%%%%%%%%%%%%%
function out = NoiseStationaryComponentPSDmatrix(f,DAE)
    % in the same order as for NoiseSourceNames
    % returns a square PSD matrix of size nNoiseSources
    % NOTE: these should be one-sided PSDs
    m = nNoiseSources(DAE);
    out = speye(m);
    % unit PSDs; all the action is moved to m(x,n)
%end NoiseStationaryComponentPSDmatrix(f,DAE)

function out = m(x,n,DAE)
    % NOTE: m should be for one-sided PSDs
    % M is of size neqns. n is of size nNoiseSources
    %
    M = dm_dn(x,n,DAE);
    out = M*n;
% end m(x,n,DAE)

function Jm = dm_dx(x,n,DAE)
    n = nunks(DAE);
    Jm = sparse([]);
    Jm(n,n) = 0;
% end dm_dx(x,n,DAE)

function M = dm_dn(x,n,DAE)
    % M is of size neqns. n is of size nNoiseSources
    % NOTE: M should be for one-sided PSDs
    %
    k = 1.3806503e-23; % Boltzmann's const
    q = 1.60217646e-19; % electronic charge
    T = 300; % Kelvin; absolute temperature FIXME: this should be a parameter

    n = nunks(DAE);
    nn = nNoiseSources(DAE);
    M = sparse([]); M(nsegs,nsegs) = 0;
    M = M*sqrt(4*k*T/R);
% end dm_dn(x,n,DAE)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%% INTERNAL FUNCTIONS EXPOSED BY API %%%%%%%%%%%%%%%%%%%%%%
function ifs = internalfuncs(DAE)
    ifs = 'No internal functions exposed by this DAE system.';
    %ifs.stoichmatfunc = @stoichmatfunc;
    %ifs.stoichmatfuncUsage = 'feval(stoichmatfunc, DAE)';
% end internalfuncs

%%%%%%%%%%%%%%%% STUFF BELOW IS NOT PART OF DAE API %%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%% other local functions %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
