%Author: Bichen <bichen@berkeley.edu> 2013/11/07
% Test script for running transient analysis on a ring oscillator based on BSIM3 CMOS model
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Type "help MAPPlicense" at the MATLAB/Octave prompt to see the license      %
%% for this software.                                                          %
%% Copyright (C) 2008-2013 Jaijeet Roychowdhury <jr@berkeley.edu>. All rights  %
%% reserved.                                                                   %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%




DAE = STA_EqnEngine(delay_line_ckt());

%tstart = 0; tstep = 1e-9; tstop =  0.1e-7; 
%tstart = 0; tstep = 1e-9; tstop =  0.5e-7; 
tstart = 0; tstep = 5e-11; tstop =  20e-9; 
tran_step = tstep/2;

args.td = 0;
args.thi = 0.01;
args.tfs = 0.5;
args.tfe = 0.51;
args.T = 10e-9;
args.A = 2.5;

DAE = feval(DAE.set_uQSS, 'Vin:::E', 0, DAE);

PUL_func = @(t, args) args.A * pulse(t/args.T, args.td, args.thi,args.tfs, args.tfe);
DAE = feval(DAE.set_utransient, 'Vin:::E', PUL_func, args, DAE);

%%%%%%% sine-wave ctrl input %%%%%%%%%%%%
% args1.A = 0.4;
% args1.offset = 1.1;
% args1.f = 1/tstop; 
% ctrl_func = @(t, args) args.offset + args.A * sin(args.f*2*pi);

%%%%%%% DC ctrl input %%%%%%%%%%%%%%%%%
args1.A = 0.7;
%args1.A = 1.1;
%args1.A = 1.5;
ctrl_func = @(t, args) args.A;

DAE = feval(DAE.set_utransient, 'Vctrl:::E', ctrl_func, args1, DAE);
%DAE = feval(DAE.set_uHB, 'vdd:::E', const_func, [], DAE);
%DAE = feval(DAE.set_uHB, 'iInj1:::I', zero_func, [], DAE);

% run DC
qss = QSS(DAE);
qss = feval(qss.solve, qss);
feval(qss.print, qss);
DCsol = feval(qss.getsolution, qss);


if 1 == 1
	% run transient and plot
	%xinit = 0*DCsol;
	xinit = DCsol;
	trans = run_transient_GEAR2(DAE, xinit, tstart, tran_step, tstop);
	%[thefig, legends] = feval(trans.plot, trans);
	figure,plot(trans.tpts, trans.vals(8,:));
	hold all;
	plot(trans.tpts, trans.vals(9,:));
	legend('input','output');
	Title = sprintf('Vctrl : %d',args1.A);

	set(gca,'FontName','Times New Roman','FontSize',15,'FontWeight','bold');
	legend('input','output');
	xlabel('Time (s)','FontName','Times New Roman','FontSize',18,'FontWeight','bold');
	ylabel('V (v)','FontName','Times New Roman','FontSize',18,'FontWeight','bold');
	title([Title],'FontName','Times New Roman','FontSize',18,'FontWeight','bold');
	set(gcf,'color','white');

end %
