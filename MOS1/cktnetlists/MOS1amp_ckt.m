function cktnetlist = MOS1amp_ckt()
%function cktnetlist = MOS1amp_ckt()
% This function returns a cktnetlist structure for a common-source amplifier
% made of MOS1 NMOS 
% 
%The circuit
%   Common-source amplifier made of N-type MOS level 1 device.
%
%To see the schematic of this circuit, run:
%
% showimage('MVSamp.jpg'); % TODO: still named MVS, but picture is the same
%
%Examples
%--------
%
% %%%%% set up DAE
% DAE = MNA_EqnEngine(MOS1amp_ckt);
% 
% %%%%% compute QSS (DC) solution
% % print input names of DAE
% DAE.inputnames(DAE)  % 'Vdd:::E'  'Vbias:::E'  'Vin:::E'
% uDC = [1;2;1]; % 'Vdd:::E'  'Vbias:::E'  'Vin:::E'
% qss = dot_op(DAE);
% feval(qss.print, qss);
% qssSol = feval(qss.getSolution, qss);
%
% % set AC analysis input as a function of frequency
% Ufargs.string = 'no args used';; % 
% Uffunc = @(f, args) 1; % constant U(j 2 pi f) \equiv 1
% DAE = feval(DAE.set_uLTISSS, 'Vin:::E', Uffunc, Ufargs, DAE);
%
% % run the AC analysis
% sweeptype = 'DEC'; fstart=1e3; fstop=1e9; nsteps=10;
% acobj = dot_ac(DAE, qssSol, uDC, fstart, fstop, nsteps, sweeptype);
%
% % plot frequency sweeps of system outputs (overlay all on 1 plot)
% feval(acobj.plot, acobj);
%
% % set transient input to the DAE
% utargs.A = 0.1; utargs.f=10e3; utargs.phi=0;
% utfunc = @(t, args) args.A*sin(2*pi*args.f*t + args.phi);
% DAE = feval(DAE.set_utransient, 'Vin:::E', utfunc, utargs, DAE);
% 
% % set up transient parameters
% tstart = 0; tstep = 0.02e-4; tstop = 3e-4;
%
% % set up and run the transient analysis
% LMSobj = dot_transient(DAE, qssSol, tstart, tstep, tstop);
%
% % plot transient results
% feval(LMSobj.plot, LMSobj);



	% MOS1_Model = MOS1ModSpec_v3_wrapper;
	MOS1_Model = MOS1ModSpec_v4_wrapper;

	% ckt name
	cktnetlist.cktname = 'MOS level 1 common source amplifier';

	% nodes (names)
	cktnetlist.nodenames = {'vdd', 'vbias', 'drain', 'gate'};
	cktnetlist.groundnodename = 'gnd';

	VddDC = 1;
	VbiasDC = 2;
	VinDC = 0;
	RLvalue = 2e3;
	CLvalue = 0; % 1e-12;

	% vddElem
	cktnetlist = add_element(cktnetlist, vsrcModSpec(), 'Vdd', {'vdd', 'gnd'}, {}, {{'E',...
	{'DC', VddDC}}});

	% vbiasElem
	cktnetlist = add_element(cktnetlist, vsrcModSpec(), 'Vbias', {'vbias', 'gnd'}, {}, {{'E',...
	{'DC', VbiasDC}}});

	% vinElem
	cktnetlist = add_element(cktnetlist, vsrcModSpec(), 'Vin', {'gate', 'vbias'}, {}, {{'E',...
	{'DC', VinDC}}});

	% mosElem
	cktnetlist = add_element(cktnetlist, MOS1_Model, 'NMOS', {'drain', 'gate', 'gnd', 'gnd'},... 
	{{'CBD', 0.5e-12}, ...
	 {'CBS', 0.5e-12}, ...
	 {'CGDO', 0.1e-12}, ...
	 {'CGSO', 0.1e-12}, ...
	 {'GAMMA', 0.85}, ...
	 {'KP', 225e-6}, ...
	 {'L', 10e-6}, ...
	 {'LAMBDA', 0.029}, ...
	 {'PHI', 0.9}, ...
	 {'VTO', 0.7}, ...
	 {'W', 20e-6}});
	 % parms are for ALD1106, from
	 % http://web.eece.maine.edu/~hummels/classes/ece343/docs/umaine.lib

	% rlElem
	cktnetlist = add_element(cktnetlist, resModSpec(), 'RL', {'vdd', 'drain'}, {{'R', RLvalue}});

	% clElem
	cktnetlist = add_element(cktnetlist, capModSpec(), 'CL', {'drain', 'gnd'}, {{'C', CLvalue}});
end
