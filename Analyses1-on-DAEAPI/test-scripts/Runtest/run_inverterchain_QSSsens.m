%Author: Jaijeet Roychowdhury <jr@berkeley.edu> 2011/sometime
% Test script for running QSS sensitivity analysis on an inverter chain 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Type "help MAPPlicense" at the MATLAB/Octave prompt to see the license      %
%% for this software.                                                          %
%% Copyright (C) 2008-2013 Jaijeet Roychowdhury <jr@berkeley.edu>. All rights  %
%% reserved.                                                                   %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%






isOctave = exist('OCTAVE_VERSION') ~= 0;
if 1 == isOctave
        warning ('off','Octave:deprecated-function');
        warning('off','Octave:function-name-clash');
        warning('off','Octave:matlab-incompatible');
	warning('off','Octave:possible-matlab-short-circuit-operator');
	do_braindead_shortcircuit_evaluation(1);
	page_output_immediately(1);
end

nstages = 160;
VDD = 1.2;
betaN = 1e-3;
betaP = 1e-3;
VTN = 0.25;
VTP = 0.25;
RDSN = 4500;
RDSP = 4500;
CL = 1e-6;

DAE = inverterchain('somename',nstages, VDD, betaN, betaP, VTN, VTP, RDSN, RDSP, CL); % API v6.2

NRparms = defaultNRparms();
NRparms.maxiter = 100;
NRparms.reltol = 1e-5;
NRparms.abstol = 1e-10;
NRparms.residualtol = 1e-10;
NRparms.limiting = 0;
NRparms.dbglvl = 1; % minimal output
NRparms.method = 0; % 219A's NR, not SPICE's RHS

% find DC solution
uDC = 0.6;
DAE = feval(DAE.set_uQSS, uDC, DAE);
QSSobj = QSS(DAE, NRparms);
initGuess = 0.6*ones(DAE.nunks(DAE), 1);
QSSobj = feval(QSSobj.solve, initGuess, QSSobj);
[sol, iters, success] = feval(QSSobj.getSolution, QSSobj);

% Choose subset of all parameters
pobj = Parameters(DAE);
pobj = feval(pobj.Delete, {'VDD1', 'CL2', 'VDD4', 'RdsN5', 'RdsP1'}, pobj); % thin down the parms

% Choose a single output of interest
outs = StateOutputs(DAE);
outs = feval(outs.DeleteAll, outs);
lastnode = sprintf('e%d', nstages);
outs = feval(outs.Add, {lastnode}, outs);


% QSS sensitivity setup
SENS = QSSsens(DAE, sol, uDC, pobj);

% Direct sensitivity computation
adjoint = 0;
fprintf(2,'\nstarting direct sensitivity solve.\n');
tic;
SENS = feval(SENS.solve, outs, adjoint, SENS);
directsoltime = toc;
fprintf(2,'finished direct sensitivity solve.\n\n');
directsol = feval(SENS.getSolution, SENS);

% Adjoint sensitivity computation
adjoint = 1;
fprintf(2,'starting adjoint sensitivity solve.\n');
tic;
SENS = feval(SENS.solve, outs, adjoint, SENS);
adjointsoltime = toc;
fprintf(2,'finished adjoint sensitivity solve.\n\n');
adjointsol = feval(SENS.getSolution, SENS);

% Error between them
reltol = 1e-13;
ok = 1;

relerr = norm(full(directsol.Sy - adjointsol.Sy))/norm(full(directsol.Sy));
ok = ok && relerr < reltol;

fprintf(2, '\n QSSsens: adjoint solve is %gx faster than direct solve for a\n', ...
	directsoltime/adjointsoltime);
fprintf(2, '\t%dx%d output sensitivity vector and a %dx%d full sensitivity matrix.\n\n',...
	size(adjointsol.Sy,1), size(adjointsol.Sy,2), ... 
	size(directsol.Sx,1), size(directsol.Sy,2));

if 1 == ok
	fprintf(2, 'passed QSSsens on %s:\n\tdirect/adjoint relative error=%g\n', ...
		feval(DAE.daename,DAE), relerr);
else
	fprintf(2, 'FAILED QSSsens on %s:\n\tdirect/adjoint relative error=%g\n', ...
		feval(DAE.daename,DAE), relerr);
end

if 1 == isOctave
        %clear -f; % clears functions. If we don't do this,
                % running this script again results in a strange
                % error in vecvalder.times
end
