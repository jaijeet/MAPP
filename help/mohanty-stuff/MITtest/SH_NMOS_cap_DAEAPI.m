function DAE = SHNMOS_cap_DAEAPI(uniqIDstr)
	DAE = DAEAPI_common_skeleton();
	DAE.version = 'DAEAPIv6.2';
	DAE.Usage = help('SH_CMOS_inverter_DAEAPIv6');
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
	%DAE.inputnamenameList = setup_inputnames(DAE);
	% data: current values of parameters, can be changed by setparms
	DAE.parms = parmdefaults(DAE);
	%
	DAE.uQSSvec = 'unassigned'; % needed for QSS (DC analysis). Should become a real scalar/vector.
	DAE.utfunc = 'unassigned'; % needed for transient analysis. Should become a function call.
	DAE.utargs = 'unassigned'; % needed for transient analysis. Should become a structure.
	DAE.Uffunc = 'unassigned'; % needed for AC/SSS analysis. Should become a function call.
	DAE.Ufargs = 'unassigned'; % needed for AC/SSS analysis. should become a structure
	%
	DAE.uQSSvec = [1.0;1.0]; % 1V DC input
	%
    % sizes: 
	DAE.nunks = @nunks;
	DAE.neqns = @neqns;
	DAE.ninputs = @ninputs;
	DAE.noutputs = @noutputs;
	%
% f, q: 
	%DAE.f_takes_inputs = 1;
	DAE.f = @f;
	DAE.q = @q;
	%
% df, dq
	%DAE.df_dx = @df_dx;
	%DAE.dq_dx = @dq_dx;
	%DAE.df_du = @df_du;
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
	DAE.NRlimiting = @NRlimiting;
	%
% parameter support - see also input- and output-related function sections
	DAE.nparms = @nparms;
	DAE.parmdefaults  = @parmdefaults;
	DAE.parmnames = @parmnames_DAEAPI;
	DAE.getparms  = @default_getparms_DAE;
	DAE.setparms  = @default_setparms_DAE;
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
	out = 2; 
% end ninputs(...)

function out = noutputs(DAE)
	out = 4; % Vout = e1
% end noutputs(...)

function out = nparms(DAE)
	out = 5;
% end nparms(...)


%%%%%%%%%%%% NAMES of DAE, UNKS, I/O, EQNS, PARMS, NOISE SOURCES %%%%%%%%%%%%%%
function out = uniqID(DAE)
	out = DAE.uniqIDstr;
% end daename()

function out = daename(DAE)
	out = sprintf('NMOS with capacitors');
% end daename()

% unknames is in unknames.m
function out = setup_unknames(DAE)
	out = {'Ivds', 'Ivgs', 'eD', 'eG'};
% end unknames()

% eqnnames is in eqnnames.m
function out = setup_eqnnames(DAE)
	out = {'KCL1', 'KCL2'};
% end eqnnames()

function out = inputnames(DAE)
	out = {'Vds','Vgs'};
% end inputnames()

function out = outputnames(DAE)
	out = {'Ivds','Ivgs'};
% end outputnames()

% parmnames is in parmnames.m
function out = setup_parmnames(DAE)
	out = {'beta', 'Vt', 'Cdg', 'Cgs', 'Cds'};
% end parmnames()


%%%%%%%%%%%%%%%%%%%%% PARAMETER SUPPORT FUNCTIONS %%%%%%%%%%%%%%%%%%%%%%%%%%
function parmvals = parmdefaults(DAE)
	parmvals = {1e-6, 0.3, 0, 0, 1e-15};
%end parmdefaults(...)

% getparms is in getparms.m
% setparms is in setparms.m


%%%%%%%%%%%%%%%%%%%%%%%%%%%% CORE FUNCTIONS %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function fout = f(x, u, DAE)
	VDS = u(1);
	VGS = u(2);
	IVDS = x(1);
	IVGS = x(2);
    eD = x(3);
    eG = x(4);
	[betaN, Vt, Cdg, Cgs, Cds] = deal(DAE.parms{:});

    inversion = 0;
    if VDS < 0
        % drain source inversion
        inversion = 1;
        vds = - VDS;
        vgs = VGS - VDS;
    else
        vds = VDS;
        vgs = VGS;
    end

    if vgs < Vt
        IDS = 0;
    else
        if vds - vgs > -Vt
            IDS = 0.5 * betaN * (vgs - Vt)^2;
        else
            IDS = betaN * (vgs - Vt - 0.5*vds) * vds;
        end
    end

    if inversion > 0.5
        IDS = -IDS;
    end

	fout(1,1) = IVDS + IDS;
	fout(2,1) = IVGS;
    fout(3,1) = eD - VDS;
    fout(4,1) = eG - VGS;
% end f(...)

function qout = q(x, DAE)
	IVDS = x(1);
	IVGS = x(2);
    eD = x(3);
    eG = x(4);
	[betaN, Vt, Cdg, Cgs, Cds] = deal(DAE.parms{:});
	qout(1,1) = Cdg*(eD-eG) + Cds*eD;
	qout(2,1) = -Cdg*(eD-eG) + Cgs*eG;
	qout(3,1) = 0;
    qout(4,1) = 0;
% end q(...)

%%%%%%%%%%%%%%%%%%%%%% OUTPUT-related functions %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function out = C(DAE)
	out = eye(4);
% end C(...)

function out = D(DAE)
	out = zeros(4,2);
% end D(...)

%%%%%%%%%%%%%%%%% QSS/NR INITIAL GUESS SUPPORT %%%%%%%%%%%%%%%%%%%%%%
function out = QSSinitGuess(u, DAE)
	% in principle, could use some heuristic dependent on the input
	% and the parameters,
	out = [0;0;0;0];
%end QSSinitGuess

%%%%%%%%%%%%%%%%% NR LIMITING SUPPORT %%%%%%%%%%%%%%%%%%%%%%
function newdx = NRlimiting(dx, xold, u, DAE)
	newdx = dx;
% end NRlimiting

