%Author: Jaijeet Roychowdhury <jr@berkeley.edu> 2011/sometime or before
% Test script to test connectCktsAtNodes script
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Type "help MAPPlicense" at the MATLAB/Octave prompt to see the license      %
%% for this software.                                                          %
%% Copyright (C) 2008-2013 Jaijeet Roychowdhury <jr@berkeley.edu>. All rights  %
%% reserved.                                                                   %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%






R = 10; L=1e-9; C = 1e-6;
DAE1 = RLCseries_floating('RLC', R, L, C);
	% unks: 'e1'      'e2'      'e3'      'e4'      'iL'
	% eqns: 'KCL1'    'KCL2'    'KCL3'    'KCL4'    'BCRL'
DAE2 = vsrc('vsrc1');
	% unks: 'e1'    'iE'
	% eqns: 'KCL1'    'BCRE'

nodes1 = {'e1'};
KCLs1  = {'KCL1'};
nodes2 = {'e1'};
KCLs2 =  {'KCL1'};

nodesKCLs1 = {nodes1, KCLs1};
nodesKCLs2 = {nodes2, KCLs2};

DAE = connectCktsAtNodes('vsrc-rlc', DAE1, nodesKCLs1, nodesKCLs2, DAE2);

DAE3 = vsrc('vsrc2');
	% unks: 'e1'    'iE'
	% eqns: 'KCL1'    'BCRE'

nodes1 = {'RLC.e4'};
KCLs1  = {'RLC.KCL4'};
nodes2 = {'e1'};
KCLs2 =  {'KCL1'};

nodesKCLs1 = {nodes1, KCLs1};
nodesKCLs2 = {nodes2, KCLs2};

DAE = connectCktsAtNodes('vsrc-rlc-vsrc', DAE, nodesKCLs1, nodesKCLs2, DAE3);

% test every function
% sizes

more off;

nunks = feval(DAE.nunks, DAE)
neqns = feval(DAE.neqns, DAE)
ninputs = feval(DAE.ninputs, DAE)
noutputs = feval(DAE.noutputs, DAE)
nparms = feval(DAE.nparms, DAE)

% names

uniqID = feval(DAE.uniqID, DAE)
daename = feval(DAE.daename, DAE)
unknames = feval(DAE.unknames, DAE)
eqnnames = feval(DAE.eqnnames, DAE)
inputnames = feval(DAE.inputnames, DAE)
outputnames = feval(DAE.outputnames, DAE)
parmnames = feval(DAE.parmnames, DAE)


% parameter support

defaultparmvals = feval(DAE.parmdefaults, DAE)
newparmvals = defaultparmvals;
newparmvals{1} = 20;
newparmvals{3} = 2*newparmvals{3};
fprintf(1,'setting new parameters (all) using DAE.setparms\n');
DAE = feval(DAE.setparms, newparmvals, DAE);
fprintf(1,'showing new parameters using DAE.getparms\n');
newparms = feval(DAE.getparms, DAE)
fprintf(1,'setting new parameters (some) using DAE.setparms\n');
DAE = feval(DAE.setparms, {'vsrc-rlc.RLC.R', 'vsrc-rlc.RLC.L'}, ...
	{10, 1e-12}, DAE);
fprintf(1,'showing new parameters using DAE.getparms\n');
newparms = feval(DAE.getparms, DAE)
%fprintf(1,'re-setting parameters to defaults using DAE.setparms\n');
%DAE = feval(DAE.setparms, defaultparmvals, DAE);
%fprintf(1,'showing parameters using DAE.getparms\n');
%feval(DAE.getparms, DAE)

% core functions

feval(DAE.unknames, DAE)
fprintf(1,'setting x to [e1=1, e2=2, e3=3, e4=4, iL=1e-3, iE1=2e-3, iE2=3e-3]\n');
e1 = 1; e2 = 2; e3 = 3; e4 = 4; iL=1e-3; iE1=2e-3; iE2 = 3e-3;
x = [e1; e2; e3; e4; iL; iE1; iE2];
feval(DAE.inputnames, DAE)
fprintf(1,'setting u to [E1=10, E2=-20]\n');
E1 = 10;
E2 = -20;
u = [E1; E2;];

feval(DAE.parmnames, DAE)
parms = feval(DAE.getparms,DAE);
[R, L, C] = deal(parms{:});

feval(DAE.eqnnames, DAE)
f_of_x = feval(DAE.f, x, u, DAE)
KCL1_f = iE1 + (e1-e2)/R
KCL2_f = iL + (e2-e1)/R
KCL3_f = -iL
KCL4_f = iE2
BCRL_f = -(e2-e3)
BCRE1_f = e1 - E1
BCRE2_f = e4 - E2
handcalcf = [KCL1_f; KCL2_f; KCL3_f; KCL4_f; BCRL_f; BCRE1_f; BCRE2_f];
fprintf(2,'\n');
error_f = norm(f_of_x - handcalcf)

df_dx = feval(DAE.df_dx, x, u, DAE)
%x = [e1; e2; e3; e4; iL; iE1; iE2];
%     1   2   3   4   5    6    7
hdfdx = sparse(7,7);

%KCL1_f = iE1 + (e1-e2)/R
hdfdx(1, 6) = 1;
hdfdx(1, 1) = 1/R;
hdfdx(1, 2) = -1/R;

%KCL2_f = iL + (e2-e1)/R
hdfdx(2, 5) = 1;
hdfdx(2, 1) = -1/R;
hdfdx(2, 2) = 1/R;

%KCL3_f = -iL
hdfdx(3, 5) = -1;

%KCL4_f = iE2
hdfdx(4, 7) = 1;

%BCRL_f = -(e2-e3)
hdfdx(5, 2) = -1;
hdfdx(5, 3) = 1;

%BCRE1_f = e1 - E1
hdfdx(6, 1) = 1;

%BCRE2_f = e4 - E2
hdfdx(7, 4) = 1;

error_dfdx = norm(full(df_dx - hdfdx))

df_du = feval(DAE.df_du, x, u, DAE)
hdfdu = sparse(7,2);
hdfdu(6,1) = -1;
hdfdu(7,2) = -1;

error_dfdu = norm(full(df_du - hdfdu))

q_of_x = feval(DAE.q, x, DAE)
KCL1_q = 0
KCL2_q = 0
KCL3_q = C*(e3-e4)
KCL4_q = C*(e4-e3)
BCRL_q = L*iL
BCRE1_q = 0
BCRE2_q = 0
handcalcq = [KCL1_q; KCL2_q; KCL3_q; KCL4_q; BCRL_q; BCRE1_q; BCRE2_q];
fprintf(2,'\n');
error_q = norm(q_of_x - handcalcq)

dq_dx = feval(DAE.dq_dx, x, DAE)
%x = [e1; e2; e3; e4; iL; iE1; iE2];
%     1   2   3   4   5    6    7
hdqdx = sparse(7,7);

%KCL3_q = C*(e3-e4)
hdqdx(3, 3) = C;
hdqdx(3, 4) = -C;

%KCL4_q = C*(e4-e3)
hdqdx(4, 3) = -C;
hdqdx(4, 4) = C;

%BCRL_q = L*iL
hdqdx(5, 5) = L;

error_dqdx = norm(full(dq_dx - hdqdx))

% IO related functions

%B_of_x = feval(DAE.B, DAE) % subsumed by df_du
C_of_x = feval(DAE.C, DAE)
D_of_x = feval(DAE.D, DAE)

if isa(DAE.uQSS,'function_handle')
	fprintf(1,'DAE.uQSS is a function handle, evaluating DAE.uQSS\n');
	uQSSval = feval(DAE.uQSS, DAE)
	fprintf(1,'setting DC input using DAE.set_uQSS\n');
	DAE = feval(DAE.set_uQSS, 2*uQSSval, DAE);
	fprintf(1,'evaluating DAE.uQSS again\n');
	uQSSvalnew = feval(DAE.uQSS, DAE)
	fprintf(1,'re-setting DC input to original value.\n');
	DAE = feval(DAE.set_uQSS, uQSSval, DAE);
else
	fprintf(1,'DAE.uQSS is not a function handle; skipping DAE.uQSS\n');
end


if isa(DAE.utransient,'function_handle')
	t = 0;
	fprintf(1,'DAE.utransient is a function handle, evaluating DAE.utransient at t=%g\n',t);
	utfunc_at_t_eq_0 = feval(DAE.utransient, t, DAE)
	fprintf(1,'setting a new transient input function using DAE.set_utransient\n');
	args = [];
	myfunc = @(ts, args) ones(ninputs,1)*(cos(2*pi*ts).*cos(2*pi*ts));
	DAE = feval(DAE.set_utransient, myfunc, args, DAE);
	fprintf(1,'evaluating DAE.utransient to plot the inputs\n');
	ts = (0:100)/100; % row vector
	inpvals = feval(DAE.utransient, ts, DAE);
	for i=1:ninputs
		figure;
		plot(ts, inpvals(i,:), '.-');
		title(sprintf('plot of input %s', inputnames{i}));
		xlabel('time');
		ylabel(inputnames{i});
		grid on; axis tight;
	end
else
	fprintf(1,'DAE.utransient is not a function handle; skipping DAE.utransient\n');
end

if isa(DAE.uLTISSS,'function_handle')
	fprintf(1,'DAE.uLTISSS is a function handle, but test for uLTISSS not implemented yet\n');
else
	fprintf(1,'DAE.uLTISSS is not a function handle; skipping DAE.uLTISSS\n');
end

% NR support functions

% The return values of the following have not been validated, but they run
QSSinitguess_for_NR = feval(DAE.QSSinitGuess, u, DAE)
dx = rand(feval(DAE.nunks,DAE),1);
u = rand(feval(DAE.ninputs,DAE),1);
LimitedDx = feval(DAE.NRlimiting, dx, x, u, DAE)

% run QSS
DAE = feval(DAE.set_uQSS, [5; -5], DAE);

qss = QSS(DAE);
qss = feval(qss.solve, qss);
outputs = StateOutputs(DAE);
feval(qss.print, outputs, qss)


% run transient
utfunc = @(t, args) [args.A1*cos(2*pi*args.f1*t); args.A2*sin(2*pi*args.f2*t)];
utargs.A1 = 1; utargs.A2 = 1; utargs.f1 = 1e3; utargs.f2 = 2.5e3;

close all;
DAE = feval(DAE.set_utransient, utfunc, utargs, DAE);

trans = LMS(DAE);
tstart = 0; tstop = 10e-3; tstep = 1e-6;
initcond = ones(7,1);
trans = feval(trans.solve, trans, initcond, tstart, tstep, tstop);
feval(trans.plot, trans, outputs)

% run LTISSS

return

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
DAE1 = BJTdiffpair_DAEAPIv6('diffpair');
	% unknames: eCL, eCR, eE
	% 'CL_KCL'    'CR_KCL'    'E_KCL'

DAE2 = RLCseries('rlc');
	% unknames: 'vC'    'v2'    'v1'    'iL'    'iE'
	% eqnnames: 'nC-KCL'    'n2-KCL'    'n1-KCL'    'L-BCR'    'E-BCR'

nodes1 = {'eE', 'eCL'};
KCLs1 = {'E_KCL', 'CL_KCL'};
nodes2 = {'vC', 'v2'};
KCLs2 = {'nC-KCL', 'n2-KCL'};

nodesKCLs1 = {nodes1, KCLs1};
nodesKCLs2 = {nodes2, KCLs2};

DAE = connectCktsAtNodes('diffpair+rlc', DAE1, nodesKCLs1, nodesKCLs2, DAE2);
