%Author: Jaijeet Roychowdhury <jr@berkeley.edu> 2011/sometime
% 
% Run tests on coupled RCdiode-sprint-mass DAE
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Type "help MAPPlicense" at the MATLAB/Octave prompt to see the license      %
%% for this software.                                                          %
%% Copyright (C) 2008-2013 Jaijeet Roychowdhury <jr@berkeley.edu>. All rights  %
%% reserved.                                                                   %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%






% updated to DAEAPI_v6.2
DAE = coupledRCdiodeSpringsMasses('the-system');

DAE

% sizes

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
newparmvals{1} = 'new parm val';
fprintf(1,'setting new parameters using DAE.setparms\n');
DAE = feval(DAE.setparms, newparmvals, DAE);
fprintf(1,'showing new parameters using DAE.getparms\n');
newparms = feval(DAE.getparms, DAE)
fprintf(1,'re-setting parameters to defaults using DAE.setparms\n');
DAE = feval(DAE.setparms, defaultparmvals, DAE);
feval(DAE.getparms, DAE)

% core functions

format long g;

fprintf(1,'setting x to [1; 0.65; 0; 0.2; 0.1; 0.4; -0.1]\n');
x = [1; 0.65; 0; 0.2; 0.1; 0.4; -0.1];

fprintf(1,'setting u = E(t) to 2V\n');
u = 2;

if 0 == DAE.f_takes_inputs
	f_of_x = feval(DAE.f, x, DAE)
	format short eng;
	df_dx = full(feval(DAE.df_dx, x, DAE))
else
	f_of_x = feval(DAE.f, x, u, DAE)
	df_dx = full(feval(DAE.df_dx, x, u, DAE))
	df_du = full(feval(DAE.df_du, x, u, DAE))
end

format long g;

q_of_x = feval(DAE.q, x, DAE)
dq_dx = full(feval(DAE.dq_dx, x, DAE))

% IO related functions

B_of_x = full(feval(DAE.B, DAE))
C_of_x = full(feval(DAE.C, DAE))
D_of_x = full(feval(DAE.D, DAE))

if isa(DAE.uQSSvec,'numeric')
	fprintf(1,'DAE.uQSSvec is of numeric type, evaluating DAE.uQSS\n');
	uQSSval = feval(DAE.uQSS, DAE)
	fprintf(1,'setting DAE.uQSSvec using DAE.set_uQSS\n');
	DAE = feval(DAE.set_uQSS, 2*uQSSval, DAE);
	fprintf(1,'evaluating DAE.uQSSvec again\n');
	uQSSvalnew = feval(DAE.uQSS, DAE)
	fprintf(1,'re-setting DAE.uQSSvec to original value.\n');
	DAE = feval(DAE.set_uQSS, uQSSval, DAE);
else
	fprintf(1,'DAE.uQSSvec is not of numeric type; skipping DAE.uQSS\n');
end


% NR support functions
QSSinitguess_for_NR = feval(DAE.QSSinitGuess, u, DAE)
dx = rand(feval(DAE.nunks,DAE),1);
u = rand(feval(DAE.ninputs,DAE),1);
LimitedDx = feval(DAE.NRlimiting, dx, x, u, DAE)
