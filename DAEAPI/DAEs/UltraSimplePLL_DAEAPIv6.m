function DAE = UltraSimplePLL_DAEAPIv6(uniqIDstr, f0,VCOgain)  % DAEAPIv6.2
%function DAE = UltraSimplePLL_DAEAPIv6(uniqIDstr, f0,f1,VCOgain)  % DAEAPIv6.2
% Simple PLL: linear VCO phase model and a PWL phase detector
%author: J. Roychowdhury, 2010/02/15
%
%
% Ultra Simple PLL: linear VCO phase model and a PWL phase detector
%		    - no LPF
%
% linear VCO model: output is phi_o, input is vi, equation is:
% 	phi_o(t) = 2 pi f0 t + VCOgain * \int_0^t vi(\tau) d \tau
%	=> d/dt phi_o(t) = 2 pi f0 + VCOgain * vi(t)
%
% phase detector model: inputs are phi_in(t) and phi_o(t)
%	output = PWL_f(phi_in - phi_o)
%	PWL_f(x) is periodic with a period of 2 pi
%		if (0 < x < pi/2) 
%			PWL_f = 2/pi * x
%		elseif (pi/2 < x < 3*pi/2) 
%			PWL_f = 1 - (2/pi)(x-pi/2) = 2 - 2x/pi = 2(1-x/pi)
%		elseif (3 pi/2 < x < 2*pi) 
%			PWL_f = -1 + (2/pi)(x-3pi/2) = 2x/pi -1 -3 = -4 + 2x/pi
%
% finally, the full PLL:
%	vi = PWL_f(phi_i - phi_o) % error voltage 
%		AND
%	d/dt phi_o(t) = 2 pi f0 + VCOgain * vi(t)
%
%          --------------------------------------------------------------
%	=> | d/dt phi_o(t) = 2 pi f0 + VCOgain * PWL_f(phi_i(t) - phi_o) |
%          --------------------------------------------------------------
%
% the input: phi_i(t) = 2*pi*f1_t;
%
% recasting into DAEAPI v6.2 format:
%		d/dt q(x) + f(x,u(t)) = 0, y(t) = C*x(t) + D*u(t)
%
%	d/dt phi_o(t) - 2 pi f0 - VCOgain * PWL_f(phi_i(t) - phi_o)  = 0
%
%	x = phi_o
%	q(x) = x
%	%B = 1
%	u(t) = 2*pi*f1*t (note: unbounded, could cause problems)
%	f(x, u(t)) = - 2*pi*f0 - VCOgain*PWL_f( u(t) - x )
%	C = 1 % ie, output y(t) = x
%	D = 0
%
%	df_dx = VCOgain*dPWL_f(u(t) - x); (warning: dPWL_f is discontinuous,
%			could easily lead to convergence and other problems)
%	df_du = -VCOgain*dPWL_f(u(t) - x);
%
%
%%%%
%see DAEAPIv6_doc.m for a description of the functions here.
%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Type "help MAPPlicense" at the MATLAB/Octave prompt to see the license      %
%% for this software.                                                          %
%% Copyright (C) 2008-2013 Jaijeet Roychowdhury <jr@berkeley.edu>. All rights  %
%% reserved.                                                                   %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%Changelog:
%---------
%2014/07/27: Tianshi Wang <tianshi@berkeley.edu>: deleted init/limiting related
%            stuff
%2014/01/31: Tianshi Wang <tianshi@berkeley.edu>: nargin checks for backward
%            compatibility
%2013/09/25: Tianshi Wang <tianshi@berkeley.edu>: init/limiting related updates
%2010/02/15: Jaijeet Roychowdhury <jr@berkeley.edu>





% pull in virtual base class:
	DAE = DAEAPI_common_skeleton();
% version, help string: 
	DAE.version = 'DAEAPIv6.2';
	DAE.Usage = help('UltraSimplePLL_DAEAPIv6');
	if nargin < 1
		DAE.uniqIDstr = '';
	else
		DAE.uniqIDstr = uniqIDstr;
	end
	%
%data: store problem parameters, assign inputs, precompute stuff
	DAE.f0 = f0;
	DAE.VCOgain = VCOgain;

	DAE.unknameList = setup_unknames(DAE);
	DAE.eqnnameList = setup_eqnnames(DAE);
	DAE.parmnameList = setup_parmnames(DAE);
	% data: current values of parameters, can be changed by setparms
	DAE.parms = parmdefaults(DAE);
	%

	DAE.uQSSvec = 'unassigned'; % should become a real scalar/vector
	DAE.utfunc = 'unassigned'; % should become a function call
	DAE.utargs = 'unassigned'; % should become a structure
	DAE.Uffunc = 'unassigned'; % should become a function call
	DAE.Ufargs = 'unassigned'; % should become a structure
	%
	%
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
	%
% NR limiting support
	% DAE.NRlimiting = @NRlimiting;
	%
% parameter support - see also input- and output-related function sections
	DAE.nparms = @nparms;
	DAE.parmdefaults  = @parmdefaults;
	DAE.parmnames = @parmnames_DAEAPI;
	DAE.getparms  = @default_getparms_DAE;
	DAE.setparms  = @default_setparms_DAE;
	% first derivatives with respect to parameters - for sensitivities
	%DAE.df_dp  = @df_dp;
	%DAE.dq_dp  = @dq_dp;
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
	out = 1;
% end nunks(...)

function out = neqns(DAE)
	out = 1;
% end neqns(...)

function out = ninputs(DAE)
	out = 1;
% end ninputs(...)

function out = noutputs(DAE)
	out = 1;
% end noutputs(...)

function out = nparms(DAE)
	out = 0; % 
% end nparms(...)

function out = nNoiseSources(DAE)
	out = 0; %
% end nNoiseSources(...)

%%%%%%%%%%%% NAMES of DAE, UNKS, I/O, EQNS, PARMS, NOISE SOURCES %%%%%%%%%%%%%%
function out = uniqID(DAE)
	out = DAE.uniqIDstr;
% end daename()

function out = daename(DAE)
	out = sprintf('UltraSimplePLL', nunks(DAE));
% end daename()

% unknames is in unknames.m
function out = setup_unknames(DAE)
	out{1} = '\phi_o(t)';
% end unknames()

% eqnnames is in eqnnames.m
function out = setup_eqnnames(DAE)
	out{1} = 'PLL phase ODE';
% end eqnnames()

function out = inputnames(DAE)
	out = {'\phi_in(t)'};
% end inputnames()

function out = outputnames(DAE)
	out = {'\phi_o(t)'};
% end outputnames()

% parmnames is in parmnames.m
function out = setup_parmnames(DAE)
	out = {};
% end parmnames()

function out = NoiseSourceNames(DAE)
	out = {};
% end NoiseSourceNames()

%renameUnks is in renameUnks.m
%renameEqns is in renameEqns.m
%renameParms is in renameParms.m



%%%%%%%%%%%%%%%%%%%%% PARAMETER SUPPORT FUNCTIONS %%%%%%%%%%%%%%%%%%%%%%%%%%
function parmvals = parmdefaults(DAE)
	parmvals = {};
% end parmdefaults(...)

% getparms is in getparms.m
% setparms is in setparms.m



%%%%%%%%%%%%%%%%%%%%%%%%%%%% CORE FUNCTIONS %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function fout = f(x, u, DAE)
	% f(x, u(t)) = - 2*pi*f0 - VCOgain*PWL_f( u(t) - x )
	%b = B(DAE)*utransient(t,DAE); % = eg, 2*pi*f1*t
	fout = -2*pi*DAE.f0 - DAE.VCOgain*PWL_f( u - x );
% end f(...)

function qout = q(x, DAE)
	qout = x;
% end q(...)

%%%%%%%%%%%%%%%%%%%%%% FIRST DERIVATIVES wrt x, u %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function Jf = df_dx(x, u, DAE)
	% f(x, u(t)) = - 2*pi*f0 - VCOgain*PWL_f( u(t) - x )
	% df_dx = VCOgain*dPWL_f(u(t) - x); (warning: dPWL_f is discontinuous,
	%	 could easily lead to convergence and other problems)
	%b = B(DAE)*utransient(t,DAE); % = eg, 2*pi*f1*t
	%fout = -2*pi*DAE.f0 - DAE.VCOgain*PWL_f( b - x );
	Jf = DAE.VCOgain*dPWL_f(u - x);
% end df_dx(...)

function Jq = dq_dx(x, DAE)
	Jq = 1;
% end dq_dx(...)

function dfdu = df_du(x, u, DAE)
	% f(x, u(t)) = - 2*pi*f0 - VCOgain*PWL_f( u(t) - x )
	% df_du = - VCOgain*dPWL_f(u(t) - x);
	dfdu = - df_dx(x, u, DAE); 
% end df_du(...)

%%%%%%%%%%%%%%%%%%%%%% INPUT-related functions %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function out = B(DAE)
	if (nargin > 1)
	   fprintf(2,'B(x, DAE) no supported yet (need tensor support first)\n');
	   return;
	end
	out = 1;
% end B(...)

%%%%%%%%%%%%%%%%%%%%%% OUTPUT-related functions %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function out = C(DAE)
	out = 1;
% end C(...)

function out = D(DAE)
	out = 0;
% end D(...)

%%%%%%%%%%%%%%%%%%% FIRST DERIVATIVES wrt parms %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function P_f = df_dp(x, PObj, DAE)
	P_f = sparse([]);
	% NO parameter derivative support yet
% end df_dp(...)

function P_q = dq_dp(x, PObj, DAE)
	P_q = sparse([]);
	% NO parameter derivative support yet
% end dq_dp(...)

%%%%%%%%%%%%%%%%% QSS/NR INITIAL GUESS SUPPORT %%%%%%%%%%%%%%%%%%%%%%
function out = QSSinitGuess(u, DAE)
	% in principle, could use some heuristic dependent on the input
	% and the parameters,
	out = 0;
%end QSSinitGuess

%%%%%%%%%%%%%%%%% NR LIMITING SUPPORT %%%%%%%%%%%%%%%%%%%%%%

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
function out = PWL_f(x)
%       PWL_f(x) is periodic with a period of 2 pi
%               if (0 < x < pi/2) 
%                       PWL_f = 2/pi * x
%               elseif (pi/2 < x < 3*pi/2) 
%                       PWL_f = 1 - (2/pi)(x-pi/2) = 2 - 2x/pi = 2(1-x/pi)
%               elseif (3 pi/2 < x < 2*pi) 
%                       PWL_f = -1 + (2/pi)(x-3pi/2) = 2x/pi -1 -3 = -4 + 2x/pi

        x = mod(x,2*pi); % guaranteed between 0 and 2 pi

        if x <= pi/2
                out = 2/pi * x;
        elseif x < 3*pi/2
                out = 2*(1-x/pi);
        else
                out = 2*(x/pi-2);
        end
% end of PWL_f(x)

function out = dPWL_f(x)
        x = mod(x,2*pi); % guaranteed between 0 and 2 pi

        if x <= pi/2
                out = 2/pi;
        elseif x <= 3*pi/2
                out = -2/pi;
        else
                out = 2/pi;
        end
% end of dPWL_f(x)
