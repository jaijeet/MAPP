function cktnetlist = MVSamp_ckt()
%function cktnetlist = MVSamp_ckt()
% TODO: descriptions
%
%Examples
%--------
%
% %%%%% set up DAE
% DAE = MNA_EqnEngine(MVSamp_ckt);
% 
% %%%%% compute QSS (DC) solution
% uDC = [1;0.55;1]; % 'Vdd:::E'  'Vbias:::E'  'Vin:::E' TODO: need API
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
% utargs.A = 0.1; utargs.f=1e9; utargs.phi=0;
% utfunc = @(t, args) args.A*sin(2*pi*args.f*t + args.phi);
% DAE = feval(DAE.set_utransient, 'Vin:::E', utfunc, utargs, DAE);
% 
% % set up transient parameters
% tstart = 0; tstep = 5e-11; tstop = 2e-9;
%
% % set up and run the transient analysis
% LMSobj = dot_transient(DAE, qssSol, tstart, tstep, tstop);
%
% % plot transient results
% feval(LMSobj.plot, LMSobj);



	% MVS_Model = MVS_ModSpec;
	MVS_Model = MVS_fast_ModSpec;
	% ckt name
	cktnetlist.cktname = 'MVS MOS model: common source amplifier';

	% nodes (names)
	cktnetlist.nodenames = {'vdd', 'vbias', 'drain', 'gate'};
	cktnetlist.groundnodename = 'gnd';

	VddDC = 1;
	VbiasDC = 0.55;
	VinDC = 0;
	RLvalue = 1e3;
	CLvalue = 1e-12;

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
	cktnetlist = add_element(cktnetlist, MVS_Model, 'NMOS', {'drain', 'gate', 'gnd', 'gnd'},... 
    {{'Type', 1}, {'W', 1e-4}, {'Lgdr', 32e-7}, {'dLg', 9e-7}, {'Cg', 2.57e-6},...
    {'Beta', 1.8}, {'Alpha', 3.5}, {'etov', 1.3e-3}, {'Cif', 0}, {'Cof', 0},...
    {'phib', 1.2}, {'Gamma', 0}, {'mc', 0.2}, {'CTM_select', 1}, {'Rs0', 100},...
    {'Rd0', 100}, {'n0', 1.68}, {'nd', 0.1}, {'vxo', 1.2e7}, {'Mu', 200},...
    {'Vt0', 0.4}, {'delta', 0.15}});

	% rlElem
	cktnetlist = add_element(cktnetlist, resModSpec(), 'RL', {'vdd', 'drain'}, {{'R', RLvalue}});

	% clElem
	cktnetlist = add_element(cktnetlist, capModSpec(), 'CL', {'drain', 'gnd'}, {{'C', CLvalue}});
end
