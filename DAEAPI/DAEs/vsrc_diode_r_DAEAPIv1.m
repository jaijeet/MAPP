function DAE = vsrc_diode_r_DAEAPIv1()
%function DAE = vsrc_diode_r_DAEAPIv1()
%
% VSRC-resistor-diode circuit, MNA-ish scalar equation
% n2 KCL: -(E-e2)/R + diode(e2; Is, Vt) = 0
%
%the DAE is: qdot(x,parms) + f(x,parms) + b(t,parms) = 0
%
%DAE.nunks (function handle). Use: nunks = feval(DAE.nunks);
%DAE.neqns (function handle). Use: neqns = feval(DAE.neqns);
%DAE.nparms (function handle). Use: nparms = feval(DAE.nparms);
%
%Arguments for DAE.f(), DAE.q(), DAE.b(), DAE.df_dx(), DAE.dq_dx() below:
%	x is a column vector of size nunks. E.g., x = rand(nunks,1);
%	parms is a cell array of parameter values (see DAE.parmdefaults)
%		E.g., parms = feval(DAE.parmdefaults);
%	t is a scalar (time)
%
%DAE.f (function handle). Use: outf = feval(DAE.f, x, DAE);
%		outf is a column vector of size neqns
%DAE.q (function handle). Use: outq = feval(DAE.q, x, parms);
%		outq is a column vector of size neqns
%DAE.b (function handle). Use: outb = feval(DAE.b, t, parms);
%		outb is a column vector of size neqns
%
%DAE.df_dx (function handle). Use: Jf = feval(DAE.df_dx, x, parms);
%		Jf is a matrix with neqns rows and nunks cols
%DAE.dq_dx (function handle). Use: Jq = feval(DAE.dq_dx, x, parms);
%		Jq is a matrix with neqns rows and nunks cols
%
%DAE.daename (function handle). Use: name = feval(DAE.daename);
%		name is a string.
%DAE.unknames (function handle). Use: unames = feval(DAE.unknames);
%		unames is a cell array containing names of unknowns (strings)
%DAE.eqnnames (function handle). Use: eqnames = feval(DAE.eqnnames);
%		eqnames is a cell array containing names of equations (strings)
%DAE.parmnames (function handle). Use: pnames = feval(DAE.parmnames);
%		pnames is a cell array containing DAE parameter names (strings)
%
%DAE.parmdefaults (function handle). Use: parms = feval(DAE.parmdefaults);
%		parms is a cell array containing DAE parameter default values
%
% TODO: 
%   10.0000
%   -9.2238
%   0.7762

	DAE.dioModSpecobj = diodeModSpec;
	DAE.vsrcModSpecobj = vsrcModSpec;
	%
	DAE.nunks = @nunks;
	DAE.neqns = @neqns;
	DAE.nparms = @nparms;
	DAE.ninputs = @ninputs;
	%
	DAE.f = @f;
	DAE.q = @q;
	DAE.b = @b;
	DAE.LimitedVarList = @LimitedVarList;
	%
	DAE.df_dx = @df_dx;
	DAE.dq_dx = @dq_dx;
	%
	DAE.daename = @daename;
	DAE.unknames = @unknames;
	DAE.eqnnames = @eqnnames;
	DAE.parmnames = @parmnames;
	%
	DAE.parmdefaults = @parmdefaults;
	%
	DAE.f_takes_u = 1;
	DAE.u_QSS = 10;
	DAE.uQSS = @(inDAE) inDAE.u_QSS;
	%
	DAE.C = @DAEC;
	DAE.D = @DAED;
	DAE.outputnames = @outputnames;
% end top-level handle return

%%%%%%%%%%%%%%%%%%%%%%%%%%%% SIZES %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function out = nunks(DAE)
	out = 3;
% end nunks(...)

function out = neqns(DAE)
	out = 3;
% end neqns(...)

function out = nparms(DAE)
	out = 4;
% TODO: many parms in diode_ModSpec don't matter here
% end nparms(...)

function out = ninputs(DAE)
	out = 1;
% end ninputs(...)

%%%%%%%%%%%%%%%%%%%%%%%%%%%% CORE FUNCTIONS %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [out, xold] = f(x, u,  DAE, init_on, limit_on, xold)
	e1 = x(1); 
	i1 = x(2); 
	v1 = x(3); 
	% pnames = parmnames;
	% idxIs = find(strcmp(pnames, 'Is'));
	% idxR = find(strcmp(pnames, 'R'));
	% idxVt = find(strcmp(pnames, 'Vt'));
	% idxE = find(strcmp(pnames, 'E'));
	% Is = parms{idxIs}; Vt = parms{idxVt}; R = parms{idxR}; E = parms{idxE};
	dio = DAE.dioModSpecobj;
	vsrc = DAE.vsrcModSpecobj;

% distribute x into models
	% vsrc model
	vecXe = x(2); %i1
	vecYe = [];
	vecLime = [];
	vecLimOlde = [];
	if init_on
		vecLime = feval(vsrc.initGuess, [], vsrc);
		% vecLime = 0
	elseif limit_on
		vecLime = feval(vsrc.limiting, vecXe, vecYe, vecLimOlde, [], vsrc);
		% vecLime = vecLimOlde
	end
	vecZe = feval(vsrc.fe, vecXe, vecYe, u, vecLime, vsrc);
	% vecZ_e = E;
	vecWe = feval(vsrc.fi, vecXe, vecYe, u, vecLime, vsrc);
	% vecW_e = [];
	

	% diode_res model
	vecX = x(1); %e1
	vecY = x(3); %v1
	vecLim = x(3); %v1
	vecLimOld = xold; %v1old
	if init_on
		vecLim = feval(dio.initGuess, [], dio);
		% vecLim = 0.6145; %vcrit
			% 6.1115912400852e-01 in ngspice
	elseif limit_on
		vecLim = feval(dio.limiting, vecX, vecY, vecLimOld, [], dio);
		% vecYlim = pnjlim(vecLimOld, vecY, 0.026, 0.6145); 
	end
	vecZ = feval(dio.fe, vecX, vecY, [], vecLim, dio);
	% vecZ = (vecX-vecY)/R;
	vecW = feval(dio.fi, vecX, vecY, [], vecLim, dio);
	% vecW = diodeId(vecLim, Is, Vt) - (vecX-vecY)/R;
% resemble f from model
	out(1,1) = vecZ + vecXe;
	out(2,1) = x(1) - vecZe;
	out(3,1) = vecW;
% xold is the value diode() is evaluated on. 
	xold = vecLim;
% end f(...)

function out = q(x, parms)
	out = zeros(3,1);
% end q(...)

function out = b(t, parms)
	out = zeros(3,1); % constant E included in f()
% end b(...)

%%%%%%%%%%%%%%%%%%%%%% FIRST DERIVATIVES wrt x %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [Jf, xold, dfdx, dfdlim, dlimdx] = df_dx(x, u, DAE, init_on, limit_on, xold)
	e1 = x(1); 
	i1 = x(2); 
	v1 = x(3); 
	dio = DAE.dioModSpecobj;
	vsrc = DAE.vsrcModSpecobj;

% distribute x into models
	% vsrc model
	vecXe = x(2); %i1
	vecYe = [];
	vecLime = [];
	vecLimOlde = [];
	if init_on
		vecLime = feval(vsrc.initGuess, [], vsrc);
		% vecLime = 0
	elseif limit_on
		vecLime = feval(vsrc.limiting, vecXe, vecYe, vecLimOlde, [], vsrc);
		% vecLime = vecLimOlde
	end
	dZ_dXe = feval(vsrc.dfe_dvecX, vecXe, vecYe, u, vecLime, vsrc);
	% dZ_dXe = 0;

	% diode_res model
	vecX = x(1); %e1
	vecY = x(3); %v1
	vecLim = x(3); %v1
	vecLimOld = xold; %v1old
	if init_on
		vecLim = feval(dio.initGuess, [], dio);
		% vecLim = 0.6145; %vcrit
			% 6.1115912400852e-01 in ngspice
		dLim_dY = zeros(length(vecLim), length(vecY));
		% dLim_dY = d/dvecY smoothpnjlim(vecLimOld, vecY, 0.026, 0.6145);
	elseif limit_on
		vecLim = feval(dio.limiting, vecX, vecY, vecLimOld, [], dio);
		% vecYlim = pnjlim(vecLimOld, vecY, 0.026, 0.6145); 
		dLim_dY = feval(dio.dlimiting_dvecY, vecX, vecY, vecLimOld, [], dio);
		% dLim_dY = d/dvecY smoothpnjlim(vecLimOld, vecY, 0.026, 0.6145);
	else
		vecLim = x(3); %v1
		dLim_dY = 1;
		% dLim_dY = 1;
	end
	dZ_dX = feval(dio.dfe_dvecX, vecX, vecY, [], vecLim, dio);
	% dZ_dX = 1/R;
	dZ_dY = feval(dio.dfe_dvecY, vecX, vecY, [], vecLim, dio);
	% dZ_dY = -1/R;
	dZ_dLim = feval(dio.dfe_dvecLim, vecX, vecY, [], vecLim, dio);
	% dZ_dY = 0;
	dZ_dY = dZ_dY + 0 * dZ_dLim;
	dW_dX = feval(dio.dfi_dvecX, vecX, vecY, [], vecLim, dio);
	% dW_dX = -1/R;
	dW_dY = feval(dio.dfi_dvecY, vecX, vecY, [], vecLim, dio);
	% dW_dY = 1/R;
	dW_dLim = feval(dio.dfi_dvecLim, vecX, vecY, [], vecLim, dio);
	% dW_dLim = d_diodeId(vecLim, Is, Vt);
% resemble dfdx from model
	dfdx(1,1) = dZ_dX;
	dfdx(2,1) = 1;
	dfdx(3,1) = dW_dX;
	dfdx(1,2) = 1;
	dfdx(1,3) = dZ_dY;
	dfdx(3,3) = dW_dY;
% resemble dfdlim from model
	dfdlim(3,1) = dW_dLim;
% resemble dlimdx from model
	dlimdx(1,3) = dLim_dY;
% resemble f from model
	dW_dY = dW_dY + dW_dLim * dLim_dY;
	Jf(1,1) = dZ_dX;
	Jf(2,1) = 1;
	Jf(3,1) = dW_dX;
	Jf(1,2) = 1;
	Jf(1,3) = dZ_dY;
	Jf(3,3) = dW_dY;
% xold is the value diode() is evaluated on. 
	xold = vecLim;
% end df_dx(...)

function out = LimitedVarList(DAE)
	out = zeros(1, 3);
	out(1, 3) = 1;
% end LimitedVarList

%{
function [out, xold] = rhs(x, u, init_on, limit_on, xold, DAE)
	e1 = x(1); 
	i1 = x(2); 
	v1 = x(3); 
	dio = DAE.dioModSpecobj;
	vsrc = DAE.vsrcModSpecobj;

% distribute x into models
	% vsrc model
	vecXe = x(2); %i1
	vecYe = [];
	vecLime = [];
	vecLimOlde = [];
	if init_on
		vecLime = feval(vsrc.initGuess, [], vsrc);
		% vecLime = 0
	elseif limit_on
		vecLime = feval(vsrc.limiting, vecXe, vecYe, vecLimOlde, [], vsrc);
		% vecLime = vecLimOlde
	end
	vecZe = feval(vsrc.fe, vecXe, vecYe, u, vecLime, vsrc);
	% vecZ_e = E;
	vecWe = feval(vsrc.fi, vecXe, vecYe, u, vecLime, vsrc);
	% vecW_e = [];
	dZ_dXe = feval(vsrc.dfe_dvecX, vecXe, vecYe, u, vecLime, vsrc);
	% dZ_dXe = 0;
	rhs_e = -dZ_dXe*vecXe + vecZe; % TODO: Why???

	% diode_res model
	vecX = x(1); %e1
	vecY = x(3); %v1
	vecLim = x(3); %v1
	vecLimOld = xold; %v1old
	if init_on
		vecLim = feval(dio.initGuess, [], dio);
		% vecLim = 0.6145; %vcrit
			% 6.1115912400852e-01 in ngspice
		dLim_dY = zeros(length(vecLim), length(vecY));
		% dLim_dY = d/dvecY smoothpnjlim(vecLimOld, vecY, 0.026, 0.6145);
	elseif limit_on
		vecLim = feval(dio.limiting, vecX, vecY, vecLimOld, [], dio);
		% vecYlim = pnjlim(vecLimOld, vecY, 0.026, 0.6145); 
		dLim_dY = feval(dio.dlimiting_dvecY, vecX, vecY, vecLimOld, [], dio);
		% dLim_dY = d/dvecY smoothpnjlim(vecLimOld, vecY, 0.026, 0.6145);
	else
		vecLim = x(3); %v1
		dLim_dY = 1;
		% dLim_dY = 1;
	end
	vecZ = feval(dio.fe, vecX, vecY, [], vecLim, dio);
	% vecZ = (vecX-vecY)/R;
	vecW = feval(dio.fi, vecX, vecY, [], vecLim, dio);
	% vecW = diodeId(vecLim, Is, Vt) - (vecX-vecY)/R;
	dZ_dX = feval(dio.dfe_dvecX, vecX, vecY, [], vecLim, dio);
	% dZ_dX = 1/R;
	dZ_dY = feval(dio.dfe_dvecY, vecX, vecY, [], vecLim, dio);
	% dZ_dY = -1/R;
	dZ_dLim = feval(dio.dfe_dvecLim, vecX, vecY, [], vecLim, dio);
	% dZ_dLim = 0;
	% dZ_dY = dZ_dY + dZ_dLim * dLim_dY;
	dW_dX = feval(dio.dfi_dvecX, vecX, vecY, [], vecLim, dio);
	% dW_dX = -1/R;
	dW_dY = feval(dio.dfi_dvecY, vecX, vecY, [], vecLim, dio);
	% dW_dY = 1/R;
	dW_dLim = feval(dio.dfi_dvecLim, vecX, vecY, [], vecLim, dio);
	% dW_dLim = d_diodeId(vecLim, Is, Vt);
	% dW_dY = dW_dY + dW_dLim * dLim_dY;

	f_d = [vecZ; vecW];
	df_d = [dZ_dX, dZ_dY, 0;...
		dW_dX, dW_dY, dW_dLim];
	rhs_d = df_d*[vecX;vecY;vecLim] - f_d;
% resemble f from model
	out(1,1) = rhs_d(1);
	out(2,1) = rhs_e; %x(1) + rhs_e;
	out(3,1) = rhs_d(2);
% xold is the value diode() is evaluated on. 
	xold = vecLim;
% end rhs(...)
%}

function Jq = dq_dx(x, parms)
	Jq = zeros(3,3);
% end dq_dx(...)

%%%%%%%%%%%%%%%%%%% NAMES of DAE, UNKS, EQNS, PARMS %%%%%%%%%%%%%%%%%%%%%%%%%
function out = daename
	out = 'vsrc-resistor-diode circuit with 3 uknowns';
% end daename()

function out = unknames
	out = {'e1', 'i1', 'v1'};
% end unknames()

function out = eqnnames
	out = {'KCL', 'BCR_E', 'BCR_D'};
% end eqnnames()

function out = parmnames
	out = {'R', 'Is', 'Vt', 'E'};
% end parmnames()

%%%%%%%%%%%%%%%%%%%%%% PARAMETER DEFAULT VALUES %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function parms = parmdefaults
	% parms = {};
	parms = {1, 1e-12, 0.026, 10};
% end parmdefaults(...)


function out_C = DAEC(DAE)
	out_C = eye(3);
% end DAEC

function out_D = DAED(DAE)
	out_D = zeros(3, 1);
% end DAED

function out = outputnames(DAE)
	out = {'e1', 'i1', 'v1'};
% end outputnames

%%%%%%%%%%%%%%%% STUFF BELOW IS NOT PART OF DAE API %%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%% other local functions %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
