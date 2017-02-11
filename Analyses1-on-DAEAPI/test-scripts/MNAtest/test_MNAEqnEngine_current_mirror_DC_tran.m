DAE = MNA_EqnEngine(current_mirror_ckt());

% run DC
NRparms = defaultNRparms();
NRparms.limiting = 0;
qss = QSS(DAE, NRparms);
qss = feval(qss.solve, qss);
feval(qss.print, qss);
DCsol = feval(qss.getsolution, qss);
% run Tran
tstart = 0;
tstep = 1e-9;
tstop = 1e-7;

LMSObj = dot_tran(DAE,DCsol, tstart, tstep, tstop);

% run AC
	% set up AC analysis input as a function of frequency
	Ufargs.string = 'no args used'; % 

	constonefuncH = @(f, args) 1;
	DAE = feval(DAE.set_uLTISSS, 'I0:::I', constonefuncH, [], DAE);

	% set up the AC analysis @ DC operating point
	us = feval(DAE.uQSS, DAE); % get the current DC inputs (values of all indep. sources)
	ltisss = LTISSS(DAE, feval(qss.getsolution,qss), us);
	% set AC sweep parameters: 1Hz to 100kHz, decade plot with 5 freq. points/decade
	sweeptype = 'DEC'; fstart=1; fstop=1e10; nsteps=50;

	% run the AC analysis
	ltisss = feval(ltisss.solve, fstart, fstop, nsteps, sweeptype, ltisss);

	% plot frequency sweeps of state variable outputs (overlay on 1 plot)
	feval(ltisss.plot, ltisss, StateOutputs(DAE));
	drawnow;

	fprintf(2,'\n');

% feval(LMSObj.plot,LMSObj);
figure,plot(LMSObj.tpts,LMSObj.vals(5,:),LMSObj.tpts,LMSObj.vals(6,:));
set(gca,'FontName','Times New Roman','FontSize',15,'FontWeight','bold');
legend('Input','Output');
xlabel('Time (s)','FontName','Times New Roman','FontSize',18,'FontWeight','bold');
ylabel('V (v)','FontName','Times New Roman','FontSize',18,'FontWeight','bold');
title(['current mirror tran: Vinput vs Voutput'],'FontName','Times New Roman','FontSize',18,'FontWeight','bold');
set(gcf,'color','white');

