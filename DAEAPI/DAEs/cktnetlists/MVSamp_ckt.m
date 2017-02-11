function cktnetlist = MVSamp_ckt()
%function cktnetlist = MVSamp_ckt()
% This function returns a cktnetlist structure for a common-source amplifier
% made of MVS NMOS.
% 
%The circuit
%   Common-source amplifier made of an N-type MVS MOS device.
%
%To see the schematic of this circuit, run:
%
% showimage('MVSamp.jpg');
%
%Examples
%--------
%
% % set up DAE
% DAE = MNA_EqnEngine(MVSamp_ckt);
% 
% % list all unknown names
% DAE.unknames(DAE)
%
% % set up state outputs
% souts = StateOutputs(DAE);
% souts = souts.DeleteAll(souts);
% souts = souts.Add({'e_drain', 'e_gate'}, souts);
%
% % compute DC solution
% % print input names of DAE
% DAE.inputnames(DAE)  % 'Vdd:::E'  'Vbias:::E'  'Vin:::E'
% uDC = [2;0.5;0]; % 'Vdd:::E'  'Vbias:::E'  'Vin:::E'
% qss = dot_op(DAE);
% feval(qss.print, qss);
% qssSol = feval(qss.getSolution, qss);
%
% % set AC analysis input as a function of frequency
% Ufargs.string = 'no args used'; % 
% Uffunc = @(f, args) 1; % constant U(j 2 pi f) \equiv 1
% DAE = feval(DAE.set_uLTISSS, 'Vin:::E', Uffunc, Ufargs, DAE);
%
% % run the AC analysis
% sweeptype = 'DEC'; fstart=1e3; fstop=1e10; nsteps=10;
% acobj = dot_ac(DAE, qssSol, uDC, fstart, fstop, nsteps, sweeptype);
%
% % plot frequency sweeps of system outputs (overlay all on 1 plot)
% feval(acobj.plot, acobj, souts); drawnow;
%
% % set transient input to the DAE
% utargs.A = 0.2; utargs.f=1e6; utargs.phi=0;
% utfunc = @(t, args) args.A*sin(2*pi*args.f*t + args.phi);
% DAE = feval(DAE.set_utransient, 'Vin:::E', utfunc, utargs, DAE);
% 
% % set up transient parameters
% tstart = 0; tstep = 1e-8; tstop = 2e-6;
%
% % set up and run the transient analysis
% LMSobj = dot_transient(DAE, qssSol, tstart, tstep, tstop);
%
% % plot transient results
% feval(LMSobj.plot, LMSobj, souts);
% 
%See also
%--------
% 
% add_element, supported_ModSpec_devices[TODO], DAEAPI, DAE_concepts
%

	MVS_Model = MVS_1_0_1_ModSpec_vv4;
	% MVS_Model = MVS_1_0_1_ModSpec;
	% MVS_Model = MVS_1_0_1_ModSpec_wrapper;
	% ckt name
	cktnetlist.cktname = 'MVS MOS model: common source amplifier';

	% nodes (names)
	cktnetlist.nodenames = {'vdd', 'vbias', 'drain', 'gate'};
	cktnetlist.groundnodename = 'gnd';

	VddDC = 2;
	VbiasDC = 0.50;
	VinDC = 0;
	RLvalue = 1e3;
	CLvalue = 1e-12;

	% vddElem
	cktnetlist = add_element(cktnetlist, vsrcModSpec(), 'Vdd', ...
                 {'vdd', 'gnd'}, {}, {{'E', {'DC', VddDC}}});

	% vbiasElem
	cktnetlist = add_element(cktnetlist, vsrcModSpec(), 'Vbias', ...
                 {'vbias', 'gnd'}, {}, {{'E', {'DC', VbiasDC}}});

	% vinElem
	cktnetlist = add_element(cktnetlist, vsrcModSpec(), 'Vin', ...
                 {'gate', 'vbias'}, {}, {{'E', {'DC', VinDC}}});

	% mosElem
	cktnetlist = add_element(cktnetlist, MVS_Model, 'NMOS', ...
    {'drain', 'gate', 'gnd', 'gnd'},... 
    {{'Type', 1}, {'W', 1e-4}, {'Lgdr', 32e-7}, {'dLg', 9e-7}, ...
     {'Cg', 2.57e-6}, {'Beta', 1.8}, {'Alpha', 3.5}, {'etov', 1.3e-3}, ...
     {'Cif', 0}, {'Cof', 0}, {'phib', 1.2}, {'Gamma', 0}, {'mc', 0.2}, ...
     {'CTM_select', 1}, {'Rs0', 100}, {'Rd0', 100}, {'n0', 1.68}, ...
     {'nd', 0.1}, {'vxo', 1.2e7}, {'Mu', 200}, {'Vt0', 0.4}, {'delta', 0.15}});

	% rlElem
	cktnetlist = add_element(cktnetlist, resModSpec(), 'RL', ...
                 {'vdd', 'drain'}, {{'R', RLvalue}});

	% clElem
	cktnetlist = add_element(cktnetlist, capModSpec(), 'CL', ...
                 {'drain', 'gnd'}, {{'C', CLvalue}});
end
