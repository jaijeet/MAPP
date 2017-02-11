%Author: Bichen <bichen@berkeley.edu> 2013/11/07
% Test script for running transient analysis on a ring oscillator based on BSIM3 CMOS model
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Type "help MAPPlicense" at the MATLAB/Octave prompt to see the license      %
%% for this software.                                                          %
%% Copyright (C) 2008-2013 Jaijeet Roychowdhury <jr@berkeley.edu>. All rights  %
%% reserved.                                                                   %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%





DAE = MNA_EqnEngine(charge_pump_ckt());
% set DC and transient inputs for VDD
% DAE = feval(DAE.set_uQSS, 'Vup:::E', 0, DAE);
% DAE = feval(DAE.set_uQSS, 'Vdown:::E', 2, DAE);

%const_func = @(t,args) 2;
%zero_func = @(t, args) 0;

tstart = 0; tstep = 1e-9; tstop =  2.5e-7; 
tran_tstep = tstep/2;
args.ts = [tstep * 20, tstep * 21, tstep * 30, tstep*31, tstep * 50, tstep*51, tstep * 90, tstep * 91];
args.vup = [2, 0, 0, 2, 2, 0, 0, 2];
args.vdn = [0, 2, 2, 0, 0, 2, 2, 0];

DAE = feval(DAE.set_uQSS, 'Vup:::E', args.vup(1), DAE);
DAE = feval(DAE.set_uQSS, 'Vdown:::E', args.vdn(1), DAE);

PWL_UP_func = @(t, args) PWL(args.ts,args.vup,t);
PWL_DN_func = @(t, args) PWL(args.ts,args.vdn,t);
DAE = feval(DAE.set_utransient, 'Vup:::E', PWL_UP_func, args, DAE);
DAE = feval(DAE.set_utransient, 'Vdown:::E', PWL_DN_func, args, DAE);

% run DC
qss = QSS(DAE);
qss = feval(qss.solve, qss);
feval(qss.print, qss);
DCsol = feval(qss.getsolution, qss);


if 1 == 1
	% run transient and plot
	%xinit = 0*DCsol;
	xinit = DCsol;
	trans = run_transient_GEAR2(DAE, xinit, tstart, tran_tstep, tstop);
	%[thefig, legends] = feval(trans.plot, trans);
	figure,plot(trans.tpts, trans.vals(6,:));
	hold all;
	plot(trans.tpts, trans.vals(8,:));
	plot(trans.tpts, trans.vals(11,:));

	set(gca,'FontName','Times New Roman','FontSize',15,'FontWeight','bold');
	legend('Vup','Vdown','Vout');
	xlabel('Time (s)','FontName','Times New Roman','FontSize',18,'FontWeight','bold');
	ylabel('V (v)','FontName','Times New Roman','FontSize',18,'FontWeight','bold');
	title(['Charge-pump tran'],'FontName','Times New Roman','FontSize',18,'FontWeight','bold');
	set(gcf,'color','white');
end %
