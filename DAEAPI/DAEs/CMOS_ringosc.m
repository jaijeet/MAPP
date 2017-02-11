function DAE = CMOS_ringosc(uniqIDstr) 


%%%%%%%%%%%%%%%% Begin main function: DAE "constructor" %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% pull in virtual base class:
	DAE = DAEAPI_common_skeleton();
% version, help string: 
	%DAE.version = 'DAEAPIv6.2';
	%DAE.Usage = help('CMOS_ringosc');
	if nargin < 1
                 DAE.uniqIDstr = '';
        else
                 DAE.uniqIDstr = uniqIDstr;
        end
	DAE.nameStr = sprintf('3-stage CMOS-based Ring Osc');
	DAE.unknameList = {'v1', 'v2', 'v3'};
	DAE.eqnnameList = {'KCL1', 'KCL2', 'KCL3'};
	%DAE.inputnameList = {'none'};
	%DAE.outputnameList = {'justv1'};
	%DAE.limitedvarnameList = {};

	DAE.parmnameList = setup_parmnames(DAE);
	DAE.parms = parmdefaults(DAE);

    %DAE.freq = 'unassigned';
    %DAE.N = 'unassigned';
    %DAE.utfunc = 'unassigned'; % needed for transient analysis. Should become a function call.
	%DAE.utargs = 'unassigned'; % needed for transient analysis. Should become a structure.
	%DAE.Uffunc = 'unassigned'; % needed for AC/SSS analysis. Should become a function call.
	%DAE.Ufargs = 'unassigned'; % needed for AC/SSS analysis. should become a structure
    
    % no need to define uHBvec, because no i/p is there.
    
	% setting a DC input of 0V
	%DAE.uQSSvec = 0; 
    
    %N = 219; % odd no.
    %%%%freq = 1/3.27e-7; % for init guess
    %%%%DAE.freq = freq;
    %DAE.N = N;
% sizes: 
	%DAE.nunks = @nunks;
	%DAE.neqns = @neqns;
	%DAE.ninputs = @ninputs;
	%DAE.noutputs = @noutputs;
	%
% f, q: 
	DAE.f_takes_inputs = 0;
	DAE.f = @f;
	%DAE.f = @(x, y) zeros(3,1);
	DAE.q = @q;
	%
% df, dq
	DAE.df_dx = @df_dx;
	DAE.dq_dx = @dq_dx;
	%
% input-related functions
	%DAE.set_utransient = @set_utransient; % must be vectorized wrt t
	%DAE.utransient = @utransient;
	%DAE.set_uQSS = @set_uQSS;
	%DAE.uQSS = @uQSS;
    %DAE.uOneToneHB = @uOneToneHB;
    %DAE.UOneToneHB = @UOneToneHB;
	%DAE.set_uLTISSS = @set_uLTISSS; % must be vectorized wrt f
	%DAE.uLTISSS = @uLTISSS;
	%
	%DAE.B = @B;
	%
% output-related functions
	% what makes sense here for transient, LTISSS, etc.?
	%DAE.C = @C;
	%DAE.D = @D;
	%
% names
	%DAE.uniqID   = @uniqID;
	%DAE.daename   = @daename;
	%DAE.unknames  = @unknames;
	%DAE.eqnnames  = @eqnnames;
	%DAE.inputnames  = @inputnames;
	%DAE.outputnames  = @outputnames;
	%DAE.renameUnks = @renameUnks;
	%DAE.renameEqns = @renameEqns;
	%DAE.renameParms = @renameParms;
	%
% HB initial guess support
	%DAE.HBinitGuess = @HBinitGuess;
	%
% NR limiting support
	%DAE.NRlimiting = @NRlimiting;
	%
% parameter support - see also input- and output-related function sections
	%DAE.nparms = @nparms;
	DAE.parmdefaults  = @parmdefaults;
	%DAE.parmnames = @parmnames;
	%DAE.getparms  = @getparms;
	%DAE.setparms  = @setparms;
	% first derivatives with respect to parameters - for sensitivities
	%DAE.df_dp  = @df_dp;
	%DAE.dq_dp  = @dq_dp;
	%
% helper functions exposed by DAE
	%DAE.internalfuncs = @internalfuncs;
	%
% functions for supporting noise
	% 
	%DAE.nNoiseSources = @nNoiseSources;
	%DAE.NoiseSourceNames = @NoiseSourceNames;
	%DAE.NoiseStationaryComponentPSDmatrix = @NoiseStationaryComponentPSDmatrix;
	%DAE.m = @m;
	%DAE.dm_dx = @dm_dx;
	%DAE.dm_dn = @dm_dn;
%
% end DAE "constructor"

%%%%%%%%%%%%%%%%%%%%%%%%%%%% SIZES %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%function out = nunks(DAE)
%	out = 3;
% end nunks(...)

%function out = neqns(DAE)
%	out = 3;
% end neqns(...)

%function out = ninputs(DAE)
%	out = 0; % 
% end ninputs(...)

%function out = noutputs(DAE)
%	out = 3; % 
% end noutputs(...)

%function out = nparms(DAE)
%	out = 1; % CL 
% end nparms(...)

%function out = nNoiseSources(DAE)
%	out = 0; % noise is not considered for this example
% end nNoiseSources(...)

%%%%%%%%%%%% NAMES of DAE, UNKS, I/O, EQNS, PARMS, NOISE SOURCES %%%%%%%%%%%%%%
%function out = uniqID(DAE)
%	out = DAE.uniqIDstr;
% end daename()

%function out = daename(DAE)
%	out = sprintf('Ring_Osc_of_CMOS_inverters');
% end daename()

%function out = unknames(DAE)
%	out = DAE.unknameList; 
% end

% unknames is in unknames.m
%function out = setup_unknames(DAE)
%	out{1} = sprintf('v1');
%	out{2} = sprintf('v2');
%	out{3} = sprintf('v3');
% end unknames()

% eqnnames is in eqnnames.m
%function out = setup_eqnnames(DAE)
%	out{1} = sprintf('KCL1');
%	out{2} = sprintf('KCL2');
%	out{3} = sprintf('KCL3');
% end eqnnames()

%function out = inputnames(DAE)
%	out = {'None'};
% end inputnames()

%function out = outputnames(DAE)
%	out = {'just_v1'};
% end outputnames()

% parmnames is in parmnames.m
function out = setup_parmnames(DAE)
	out = {'CL'};
% end parmnames()

%function out = NoiseSourceNames(DAE)
%	out = {};
% end NoiseSourceNames()

%renameUnks is in renameUnks.m
%renameEqns is in renameEqns.m
%renameParms is in renameParms.m

%%%%%%%%%%%%%%%%%%%%% PARAMETER SUPPORT FUNCTIONS %%%%%%%%%%%%%%%%%%%%%%%%%%
function parmvals = parmdefaults(DAE)
	parmvals = {.99e-7}; 
% end parmdefaults(...)

% getparms is in getparms.m
% setparms is in setparms.m

%%%%%%%%%%%%%%%%%%%%%%%%%%%% CORE FUNCTIONS %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function fout = f(x, DAE)
	v1 = x(1); v2 = x(2); v3 = x(3); 

	inv = SH_CMOS_inverter; 
	fout(1,1) = feval(inv.f, v1, v3, inv);
	fout(2,1) = feval(inv.f, v2, v1, inv);
	fout(3,1) = feval(inv.f, v3, v2, inv); 
% end f(...)

function qout = q(x, DAE)
	v1 = x(1); v2 = x(2); v3 = x(3); 
	[CL] = deal(DAE.parms{:});

	qout(1,1) = CL*v1;
        qout(2,1) = CL*v2;
        qout(3,1) = CL*v3;
% end q(...)

%%%%%%%%%%%%%%%%%%%%%% FIRST DERIVATIVES wrt x %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function Jf = df_dx(x, DAE)
    	v1 = x(1); v2 = x(2); v3 = x(3); 

	Jf = zeros(3,3);

	inv = SH_CMOS_inverter; 

	Jf(1,1) = feval(inv.df_dx, v1, v3, inv);
	Jf(1,2) = 0;
	Jf(1,3) = feval(inv.df_du, v1, v3, inv);

	Jf(2,1) = feval(inv.df_du, v2, v1, inv);
	Jf(2,2) = feval(inv.df_dx, v2, v1, inv);
	Jf(2,3) = 0;

	Jf(3,1) = 0;
	Jf(3,2) = feval(inv.df_du, v3, v2, inv);
	Jf(3,3) = feval(inv.df_dx, v3, v2, inv);
% end df_dx(...)

function Jq = dq_dx(x, DAE)
	[CL] = deal(DAE.parms{:});

	Jq = zeros(3,3);

	Jq(1,1) = CL; 
	Jq(2,2) = CL; 
	Jq(3,3) = CL; 
% end dq_dx(...)

%%%%%%%%%%%%%%%%%%%%%% INPUT-related functions %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%function out = B(DAE)
	%	No input. Autonomous system. 
%	out = [0;0;0]; % no need to define B. it will never be called.
% end B(...)

% set_utransient is in set_utransient.m
% utransient is in utransient.m
% set_uQSS is in set_uQSS.m
% uQSS is in uQSS.m
% set_uLTISSS is in set_uLTISSS.m
% uLTISSS is in uLTISSS.m

%%%%%%%%%%%%%%%%%%%%%% OUTPUT-related functions %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%function out = C(DAE)
%	out = [1,0,0]; % v1
% end C(...)

%function out = D(DAE)
%	out = [0;0;0]; % for 3 outputs (?)
% end D(...)

%%%%%%%%%%%%%%%%%%% FIRST DERIVATIVES wrt parms %%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%% HB/NR INITIAL GUESS SUPPORT %%%%%%%%%%%%%%%%%%%%%%
function out = HBinitGuess( DAE) % should be able to call transient analysis
	tstart = 0; tstop = 1.3e-3;  tstep = 1e-5;
    %xinit = [1 0 -1]';
    if feval(DAE.nunks,DAE) == 3
    xinit = [.1651;.3830;1.1683];
    else
    xinit = [1.0485 .7858 .0324 1.0477 .7919 .0338 1.0493 .7795 .0311 1.0501 .7730 .0299].';
    end
    
    TransObjBE = LMS(DAE); % default method is BE
    tranparms = TransObjBE.tranparms;
    tranparms.stepControlParms.doStepControl = 0; % uniform timesteps only.
    
    TransObjTRAP = LMS(DAE,TransObjBE.TRAPparms, tranparms); 
    TransObjTRAP = feval(TransObjTRAP.solve, TransObjTRAP, xinit, tstart, tstep, tstop);
    out_tmp = TransObjTRAP.vals(:,1:end);
    l=9;
    [~,t1] = max(out_tmp(1,1:floor(.5*tstop/tstep))); 
    [~,t2] = max(out_tmp(1,(t1+1+l):end)); 
    N = t2+l; 
    T = N*tstep;
    %freq = 1/T;
    %N = N + (mod(N,2)==0); % to make N odd
    %plot(out_tmp(1,1:N)); hold on; plot(out_tmp(2,1:N),'k'); hold on;
    %plot(out_tmp(3,1:N),'c');
    %out_2D = (fft(out_tmp(:,1:N).').')/N;
    %out =[out_2D(:); T];
    out = out_tmp(:,t1:t1+t2+l-1);
    if mod(N,2)==0
    out = spline((0:N-1)/N,out,(0:N)/(N+1));
    end
    if 1==1
    N = N + (mod(N,2)==0);
    out = [reshape(1/N*fft(out,[],2),N*size(out,1),1);T];
    end
	%out = zeros(nunks(DAE),DAE.N);
    %out(1,2) = 1*(0.5000 - 0.0000i); out(1,end) =  conj(out(1,2));
    %out(2,2) = 1*(-0.2500 - 0.4330i); out(2,end) = conj(out(2,2));
    %out(3,2) = 1*(-0.2500 + 0.4330i); out(3,end) = conj(out(3,2));
%end HBinitGuess

%%%%%%%%%%%%%%%%% NR LIMITING SUPPORT %%%%%%%%%%%%%%%%%%%%%%
%function newdx = NRlimiting(dx, xold,~, DAE)
%	newdx = dx; % limiting not put in yet
% end NRlimiting

%%%%%%%%%%%%%%%%%%%%% NOISE SUPPORT FUNCTIONS %%%%%%%%%%%%%%%%%%%%%%%%%%
%function out = NoiseStationaryComponentPSDmatrix(f,DAE)
	% in the same order as for NoiseSourceNames
	% returns a square PSD matrix of size nNoiseSources
	% NOTE: these should be one-sided PSDs
%	m = nNoiseSources(DAE);
%	out = 'undefined';
	% unit PSDs; all the action is moved to m(x,n)
%end NoiseStationaryComponentPSDmatrix(f,DAE)

%function out = m(x,n,DAE)
	% NOTE: m should be for one-sided PSDs
	% M is of size neqns. n is of size nNoiseSources
	%
%	ne = neqns(DAE);
%	out = zeros(ne,1);
% end m(x,n,DAE)

%function Jm = dm_dx(x,n,DAE)
%	nu = nunks(DAE);
%	ne = neqns(DAE);
%	Jm = sparse(ne,nu);
% end dm_dx(x,n,DAE)

%function M = dm_dn(x,n,DAE)
	% M is of size neqns. n is of size nNoiseSources
	% NOTE: M should be for one-sided PSDs
	%
%	k = 1.3806503e-23; % Boltzmann's const
%	q = 1.60217646e-19; % electronic charge
%	T = 300; % Kelvin; absolute temperature FIXME: this should be a parameter

%	n = nunks(DAE);
%	nn = nNoiseSources(DAE);
%	M = sparse([]); M(nsegs,nsegs) = 0;
%	M = M*sqrt(4*k*T/R);
%	M = 'undefined';
% end dm_dn(x,n,DAE)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%% INTERNAL FUNCTIONS EXPOSED BY API %%%%%%%%%%%%%%%%%%%%%%
%function ifs = internalfuncs(DAE)
%	ifs = 'No internal functions exposed by this DAE system.';
	%ifs.stoichmatfunc = @stoichmatfunc;
	%ifs.stoichmatfuncUsage = 'feval(stoichmatfunc, DAE)';
% end internalfuncs

%%%%%%%%%%%%%%%% STUFF BELOW IS NOT PART OF DAE API %%%%%%%%%%%%%%%%%%%%%%%%

