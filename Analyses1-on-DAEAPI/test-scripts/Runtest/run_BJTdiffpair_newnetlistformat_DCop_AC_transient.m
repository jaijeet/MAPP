% set up DAE
more off;
%DAE =  MNA_EqnEngine(BJT_with_cap_diffpair_ckt());
DAE =  MNA_EqnEngine(BJTdiffpair_ckt());

% find operating point
% NRguess = [-0.7; 3; 3; 5; 0; -2e-3; 0]; % should not be needed when 
					% init/limiting are working properly
% dcop = dot_op(DAE, NRguess);
dcop = dot_op(DAE);
feval(dcop.print, dcop);
qssSol = feval(dcop.getsolution, dcop);

% run AC at 4 different operating points
for Vin = [-0.1 0 0.1 0.2] % 3 different DC op pts
	%%%%% compute QSS (DC) solution
	DAE = feval(DAE.set_uQSS, 'Vin:::E', Vin, DAE);
	qss = dot_op(DAE, qssSol);
	% feval(qss.print, stateoutputs, qss);
	qssSol = feval(qss.getSolution, qss);

	%%%%% AC analysis
	% set AC analysis input as a function of frequency

	% AC analysis @ DC operating point
	sweeptype = 'DEC'; fstart=1; fstop=1e5; nsteps=10;
	ltisss = dot_ac(DAE, qssSol, feval(DAE.uQSS, DAE), fstart, fstop, ...
			nsteps, sweeptype);
	ltisss.DAEname = sprintf('%s with Vin=%g', ltisss.DAEname, Vin); %
					% sets plot title string properly
	% plot frequency sweeps of system outputs (overlay all on 1 plot)
	feval(ltisss.plot, ltisss);
	% plot frequency sweeps of state variable outputs (overlay on 1 plot)
	%feval(ltisss.plot, ltisss, stateoutputs);
end

% run transient and plot
DAE = feval(DAE.set_uQSS, 'Vin:::E', 0, DAE);
xinit = feval(dcop.getsolution, dcop);
tstart = 0; tstep = 1e-5; tstop = 5e-3;
TransObj = dot_transient(DAE, xinit, tstart, tstep, tstop);
[thefig, legends] = feval(TransObj.plot, TransObj);

% Author: J. Roychowdhury, 2013/09/21.
