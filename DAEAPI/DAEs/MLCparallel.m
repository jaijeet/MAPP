function DAE = MLCparallel(uniqIDstr)  
%function DAE = MLCparallel(uniqIDstr)
% <TODO> Placeholder </TODO>
%author: J. Roychowdhury, 2011/09/19
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% The Circuit:
%
% unknowns are: v, qM, iL, and phi
% MNA equations are:
%
%	KCL: 	C dv/dt + dqM/dt + iL + I(t) = 0
% 	L BCR:	L diL/dt - v = 0 
%	M BCR1:	dphi/dt - v = 0
%	M BCR2: qM - givenf(phi) = 0
%
% givenf(phi) = k1*( exp(phi*k2) - 1 );
%
% I(t) is the input, defined as cos(2*pi*1000*t). 
% The entire state vector x is the output.
%
% 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% See DAEAPIv6_doc.m for documentation on the DAEAPI functions here.
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Type "help MAPPlicense" at the MATLAB/Octave prompt to see the license      %
%% for this software.                                                          %
%% Copyright (C) 2008-2013 Jaijeet Roychowdhury <jr@berkeley.edu>. All rights  %
%% reserved.                                                                   %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%






%
%
%%%%%%%%%%%%%%%% Begin main function: DAE "constructor" %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% pull in virtual base class:
	DAE = DAEAPI_common_skeleton();
% version, help string: 
	DAE.version = 'DAEAPIv6.2+delta';
	DAE.Usage = help('MLCparallel');
	if nargin < 1
		DAE.uniqIDstr = '';
	else
		DAE.uniqIDstr = uniqIDstr;
	end
	%
%data: store problem parameters, set inputs, precompute stuff
	DAE.unknameList = setup_unknames(DAE);
	DAE.eqnnameList = setup_eqnnames(DAE);
	DAE.parmnameList = setup_parmnames(DAE);
	% data: current values of parameters, can be changed by setparms
	DAE.parms = parmdefaults(DAE);
	%
	% The following 'unassigned' assignments prevent the appropriate analyses from running unless the inputs
	% are set up right. You should always keep these, and update later as appropriate.
	DAE.uQSSvec = 'unassigned'; % needed for QSS (DC analysis). Should become a real scalar/vector.
	DAE.utfunc = 'unassigned'; % needed for transient analysis. Should become a function call.
	DAE.utargs = 'unassigned'; % needed for transient analysis. Should become a structure.
	DAE.Uffunc = 'unassigned'; % needed for AC/SSS analysis. Should become a function call.
	DAE.Ufargs = 'unassigned'; % needed for AC/SSS analysis. Should become a structure

	% setting the QSS/DC input value (for the voltage source E, in this case)
	%DAE.uQSSvec = -15; % DC value of input is set here. Can be updated during runtime with set_uQSS.

	% setting a transient input function (for the current source I)
	mycos = @(t,args) cos(2*pi*args.f*t);
	args.f = 1000;
	DAE = feval(DAE.set_utransient, mycos, args, DAE);
% sizes: 
	DAE.nunks = @nunks;
	DAE.neqns = @neqns;
	DAE.ninputs = @ninputs;
	DAE.noutputs = @noutputs;
	%
% f, q: 
	DAE.f_takes_inputs = 0;
	DAE.f = @f;
	DAE.q = @q;
	%
% df, dq
	DAE.df_dx = @df_dx;
	DAE.dq_dx = @dq_dx;
	%DAE.df_du = @df_du;
	%
% input-related functions
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
	DAE.NRlimiting = @NRlimiting;
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
	out = 4;
% end nunks(...)

function out = neqns(DAE)
	out = 4;
% end neqns(...)

function out = ninputs(DAE)
	out = 1; % I(t)
% end ninputs(...)

function out = noutputs(DAE)
	out = nunks(DAE); % all x is the output
% end noutputs(...)

function out = nparms(DAE)
	out = 4; % {'C', 'L', 'k1', 'k2'};
% end nparms(...)

function out = nNoiseSources(DAE)
	out = 0; % noise is not considered for this example
% end nNoiseSources(...)

%%%%%%%%%%%% NAMES of DAE, UNKS, I/O, EQNS, PARMS, NOISE SOURCES %%%%%%%%%%%%%%
function out = uniqID(DAE)
	out = DAE.uniqIDstr;
% end daename()

function out = daename(DAE)
	out = sprintf('MLC parallel tank circuit');
% end daename()

% unknames is in unknames.m
function out = setup_unknames(DAE)
	%unknowns are: v, qM, iL, phi - in this order
	out = {'v', 'qM', 'iL', 'phi'};
% end unknames()

% eqnnames is in eqnnames.m
function out = setup_eqnnames(DAE)
	out = {'KCL', 'L-BCR', 'M-BCR1', 'M-BCR2'};
% end eqnnames()

function out = inputnames(DAE)
	out = {'I(t)'};
% end inputnames()

function out = outputnames(DAE)
	out = unknames(DAE);
% end outputnames()

% parmnames is in parmnames.m
function out = setup_parmnames(DAE)
	out = {'C', 'L', 'k1', 'k2'};
% end parmnames()

function out = NoiseSourceNames(DAE)
	out = {};
% end NoiseSourceNames()

%renameUnks is in renameUnks.m
%renameEqns is in renameEqns.m
%renameParms is in renameParms.m


%%%%%%%%%%%%%%%%%%%%% PARAMETER SUPPORT FUNCTIONS %%%%%%%%%%%%%%%%%%%%%%%%%%
function parmvals = parmdefaults(DAE)
	parmvals = {1e-6, 1e-9, 1e-12, 40};
	% order: {'C', 'L', 'k1', 'k2'};
% end parmdefaults(...)

%%%%%%%%%%%%%%%%%%%%%%%%%%%% CORE FUNCTIONS %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function fout = f(x, DAE)
	%{'v', 'qM', 'iL', 'phi'};
	v = x(1); qM = x(2); iL = x(3); phi = x(4);
	%oof = struct2cell(parms); % fieldnames, orderfields can be useful
	%{'C', 'L', 'k1', 'k2'};
	[C, L, k1, k2] = deal(DAE.parms{:});

	%	C dv/dt + dqM/dt + iL + I(t) = 0
	fout(1,1) = iL; 				% KCL
	% 	L diL/dt - v = 0 
	fout(2,1) = -v;					% L BCR
	%	dphi/dt - v = 0
	fout(3,1) = -v;					% M BCR1
	%	qM - givenf(phi) = 0
	fout(4,1) = qM - givenf(phi, k1, k2);		% M BCR2
% end f(...)

function qout = q(x, DAE)
	%{'v', 'qM', 'iL', 'phi'};
	v = x(1); qM = x(2); iL = x(3); phi = x(4);
	%oof = struct2cell(parms); % fieldnames, orderfields can be useful
	%{'C', 'L', 'k1', 'k2'};
	[C, L, k1, k2] = deal(DAE.parms{:});

	%	C dv/dt + dqM/dt + iL + I(t) = 0
	qout(1,1) = C*v + qM;
	% 	L diL/dt - v = 0 
	qout(2,1) = L*iL;
	%	dphi/dt - v = 0
	qout(3,1) = phi;
	%	qM - givenf(phi) = 0
	qout(4,1) = 0;
% end q(...)

%%%%%%%%%%%%%%%%%%%%%% FIRST DERIVATIVES wrt x %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function Jf = df_dx(x, DAE)
	%x = {'v', 'qM', 'iL', 'phi'};
	v = x(1); qM = x(2); iL = x(3); phi = x(4);
	%oof = struct2cell(parms); % fieldnames, orderfields can be useful
	%{'C', 'L', 'k1', 'k2'};
	[C, L, k1, k2] = deal(DAE.parms{:});

	Jf = zeros(4,4);
	% x = {'v', 'qM', 'iL', 'phi'};
	%       1     2    3      4 

	%fout(1,1) = iL; 			% KCL
	Jf(1,3) = 1;

	%fout(2,1) = -v;			% L BCR
	Jf(2,1) = -1;

	%fout(3,1) = -v;			% M BCR1
	Jf(3,1) = -1;

	%fout(4,1) = qM - givenf(phi, k1, k2);	% M BCR2
	Jf(4,2) = 1;
	Jf(4,4) = -d_givenf(phi, k1, k2);
% end df_dx(...)

function Jq = dq_dx(x, DAE)
	% x = {'v', 'qM', 'iL', 'phi'};
	v = x(1); qM = x(2); iL = x(3); phi = x(4);
	%oof = struct2cell(parms); % fieldnames, orderfields can be useful
	%{'C', 'L', 'k1', 'k2'};
	[C, L, k1, k2] = deal(DAE.parms{:});

	Jq = zeros(4,4);
	% x = {'v', 'qM', 'iL', 'phi'};
	%       1     2    3      4 

	%qout(1,1) = C*v + qM;
	Jq(1,1) = C;
	Jq(1,2) = 1;

	%qout(2,1) = L*iL;
	Jq(2,3) = L;

	%qout(3,1) = phi;
	Jq(3,4) = 1;

	%qout(4,1) = 0;
% end dq_dx(...)

%%%%%%%%%%%%%%%%%%%%%% INPUT-related functions %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function out = B(DAE)
	if (nargin > 1)
	   fprintf(2,'B(x, DAE) not supported yet (need tensor support first)\n');
	   return;
	end
	out = zeros(neqns(DAE),ninputs(DAE));
	out(1,1) = 1; % I(t), the input, adds to the first equation
% end B(...)

%%%%%%%%%%%%%%%%%%%%%% OUTPUT-related functions %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function out = C(DAE)
	out = eye(nunks(DAE));;
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
	out = zeros(nunks(DAE),1); % note: zeros is a really bad guess.
%end QSSinitGuess

%%%%%%%%%%%%%%%%% NR LIMITING SUPPORT %%%%%%%%%%%%%%%%%%%%%%
function newdx = NRlimiting(dx, xold, u, DAE)
	newdx = dx;
% end NRlimiting

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
function  out = givenf(phi, k1, k2)
	out = k1*(exp(phi*k2) - 1);
% end givenf

function dout = d_givenf(phi, k1, k2)
	%out = k1*(exp(phi*k2) - 1);
	dout = k1*k2*exp(phi*k2);
% end d_givenf
