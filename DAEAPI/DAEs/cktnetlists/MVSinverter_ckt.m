function cktnetlist = MVSinverter_ckt()
%function cktnetlist = MVSinverter_ckt()
%This function returns a cktnetlist structure for an inverter made of MVS
%devices.
%
%The circuit
%   An CMOS inverter made of N-type and P-type MVS MOSFET devices.
%
%To see the schematic of this circuit, run:
%
% showimage('MVSinverter.jpg');
%
%Examples
%--------
%
% % set up DAE
% DAE = MNA_EqnEngine(MVSinverter_ckt);
% 
% % DC operating point analysis
% DAE = feval(DAE.set_uQSS, 'Vin:::E', 0.0, DAE);
% qss = dot_op(DAE);
% % print DC operating point
% feval(qss.print, qss);
% qssSol = feval(qss.getsolution, qss);
% 
% % DC sweep
% swp = dcsweep(DAE, [], 'Vin:::E', 0:1/40:1);
% % feval(swp.plot, swp); % this will plot all DAE states
%
% % get DC sweep solutions and plot Vout-Vin curve
% [Vins, sols] = swp.getSolution(swp);
% outidx = DAE.unkidx('e_out', DAE);
% plot(Vins, sols(outidx, :), '-r.', 'LineWidth', 2);
% xlabel('Vin'); ylabel('Vout'); title('DC sweep results of MVS inverter');
% grid on; box on;
% 
% % transient
% tstart = 0; tstep = 1e-13; tstop = 0.1e-9;
% TransObj = dot_transient(DAE, qssSol, tstart, tstep, tstop);
%
% % plot seleted state outputs
% souts = StateOutputs(DAE);
% souts = souts.DeleteAll(souts);
% souts = souts.Add({'e_in'  'e_out'}, souts);
% feval(TransObj.plot, TransObj, souts);
%
%See also
%--------
% 
% add_element, supported_ModSpec_devices[TODO], DAEAPI, DAE_concepts,
% dcsweep
%

%
% Author: Tianshi Wang, 2014/01/30



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Type "help MAPPlicense" at the MATLAB/Octave prompt to see the license      %
%% for this software.                                                          %
%% Copyright (C) 2008-2013 Jaijeet Roychowdhury <jr@berkeley.edu>. All rights  %
%% reserved.                                                                   %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

	% MVS_Model = MVS_1_0_1_ModSpec();
	MVS_Model = MVS_1_0_1_ModSpec_vv4();

    % MVS_Model = MVS_ModSpec();
    % MVS_Model = MVS_ModSpec_noabs();
    % MVS_Model = MVS_ModSpec_gmin();
    % MVS_Model = MVS_ModSpec_gmin_initlimiting();
	% MVS_Model = MVS_1_0_1_ModSpec_backup();
	% MVS_Model = MVS_1_0_1_ModSpec_wrapper();

    % ckt name
    cktnetlist.cktname = 'MVS inverter';

    % nodes (names)
    cktnetlist.nodenames = {'vdd', 'in', 'out'};
    cktnetlist.groundnodename = 'gnd';

    VddDC = 1;
    VinDC = 0;
    CL = 3e-15;
	RL = 1e9;
	% input function for Vin
	Vinfunc = @(t, args) pulse(t, args.td, args.thi, args.tfs, args.tfe); 
	Vinargs.td = 0; Vinargs.thi = 1e-12; Vinargs.tfs = 50e-12; Vinargs.tfe = 51e-12;

    % vddElem
    cktnetlist = add_element(cktnetlist, vsrcModSpec(), 'Vdd', {'vdd', 'gnd'}, {}, {{'E',...
    {'DC', VddDC}}});

    % vinElem
    cktnetlist = add_element(cktnetlist, vsrcModSpec(), 'Vin', {'in', 'gnd'}, {}, {{'E',...
    {'DC', VinDC}, {'TRAN', Vinfunc, Vinargs}}});


    % nmosElem
    cktnetlist = add_element(cktnetlist, MVS_Model, 'NMOS', {'out', 'in', 'gnd', 'gnd'}, ...
    {{'Type', 1}, {'W', 1e-4}, {'Lgdr', 32e-7}, {'dLg', 9e-7}, {'Cg', 2.57e-6},...
   	{'Beta', 1.8}, {'Alpha', 3.5}, {'Tjun', 300}, {'Cif', 1.38e-12}, {'Cof', 1.47e-12},...
   	{'phib', 1.2}, {'Gamma', 0.1}, {'mc', 0.2}, {'CTM_select', 1}, {'Rs0', 100},...
   	{'Rd0', 100}, {'n0', 1.68}, {'nd', 0.1}, {'vxo', 1.2e7}, {'Mu', 200}, {'Vt0', 0.4}, {'delta', 0.15}});

    % pmosElem
    cktnetlist = add_element(cktnetlist, MVS_Model, 'PMOS', {'vdd', 'in', 'out', 'vdd'}, ...
    {{'Type', -1}, {'W', 1.0e-4}, {'Lgdr', 32e-7}, {'dLg', 8e-7}, {'Cg', 2.57e-6},...
   	{'Beta', 1.8}, {'Alpha', 3.5}, {'Tjun', 300}, {'Cif', 1.38e-12}, {'Cof', 1.47e-12},...
   	{'phib', 1.2}, {'Gamma', 0.1}, {'mc', 0.2}, {'CTM_select', 1}, {'Rs0', 100},...
   	{'Rd0', 100}, {'n0', 1.68}, {'nd', 0.1}, {'vxo', 7542204}, {'Mu', 165}, {'Vt0', 0.5535}, {'delta', 0.15}}); 

    % clElem
    cktnetlist = add_element(cktnetlist, capModSpec(), 'CL', {'out', 'gnd'}, ...
    {{'C', CL}}, {});

    % rlElem
    % cktnetlist = add_element(cktnetlist, resModSpec(), 'RL', {'out', 'gnd'}, ...
    % {{'R', RL}}, {});
end

