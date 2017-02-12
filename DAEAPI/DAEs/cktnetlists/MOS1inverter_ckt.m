function cktnetlist = MOS1inverter_ckt()
%function cktnetlist = MOS1inverter_ckt()
%This function returns a cktnetlist structure for an inverter using
% MOS1ModSpec model
%
%The circuit
%   An CMOS inverter made of an N-type and a P-type MOS1ModSpec MOSFET devices.
%
%To see the schematic of this circuit, run:
%
% showimage('MVSinverter.jpg'); % TODO: update name to MOS1
%
%Examples
%--------
%
% % set up DAE %
% DAE = MNA_EqnEngine(MOS1inverter_ckt);
% 
% % OP %
% DAE = feval(DAE.set_uQSS, 'Vin:::E', 0.0, DAE);
% 
% qss = dot_op(DAE);
% % print DC operating point
% feval(qss.print, qss);
% qssSol = feval(qss.getsolution, qss);
% 
% % DC sweep %
% swp = dot_dcsweep(DAE, [], 'Vin:::E', 0, 3, 40);
% feval(swp.plot, swp);
% % TODO: plot only one variable
% 
% % transient %
% tstart = 0; tstep = 1e-6; tstop = 1e-4;
% TransObj = dot_transient(DAE, qssSol, tstart, tstep, tstop);
% feval(TransObj.plot, TransObj);
%
%See also
%--------
% 
% add_element, supported_ModSpec_devices[TODO], DAEAPI[TODO], DAE[TODO]
% dot_dcsweep
%

%
% Author: Tianshi Wang, 2014/01/30



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Type "help MAPPlicense" at the MATLAB/Octave prompt to see the license      %
%% for this software.                                                          %
%% Copyright (C) 2008-2013 Jaijeet Roychowdhury <jr@berkeley.edu>. All rights  %
%% reserved.                                                                   %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

	MOS1_Model = MOS1ModSpec_v5_wrapper();

    % ckt name
    cktnetlist.cktname = 'MOS1 inverter';

    % nodes (names)
    cktnetlist.nodenames = {'vdd', 'in', 'out'};
    cktnetlist.groundnodename = 'gnd';

    VddDC = 3;
    VinDC = 0;
    CL = 4.7e-9;
	% input function for Vin
	Vinfunc = @(t, args) args.mag * pulse(t, args.td, args.thi, args.tfs, args.tfe); 
	Vinargs.mag = 3; Vinargs.td = 0; Vinargs.thi = 1e-6; Vinargs.tfs = 50e-6; Vinargs.tfe = 51e-6;

    % vddElem
    cktnetlist = add_element(cktnetlist, vsrcModSpec(), 'Vdd', {'vdd', 'gnd'}, {}, {{'E',...
    {'DC', VddDC}}});

    % vinElem
    cktnetlist = add_element(cktnetlist, vsrcModSpec(), 'Vin', {'in', 'gnd'}, {}, {{'E',...
    {'DC', VinDC}, {'TRAN', Vinfunc, Vinargs}}});

    % nmosElem
    cktnetlist = add_element(cktnetlist, MOS1_Model, 'NMOS', {'out', 'in', 'gnd', 'gnd'}, ...
	{{'TYPE', 'N'}, ...
	 {'CBD', 0.5e-12}, ...
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

    % pmosElem
    cktnetlist = add_element(cktnetlist, MOS1_Model, 'PMOS', {'vdd', 'in', 'out', 'vdd'}, ...
	{{'TYPE', 'P'}, ...
	 {'CBD', 0.5e-12}, ...
	 {'CBS', 0.5e-12}, ...
	 {'CGDO', 0.1e-12}, ...
	 {'CGSO', 0.1e-12}, ...
	 {'GAMMA', .45}, ...
	 {'KP', 100e-6}, ...
	 {'L', 10e-6}, ...
	 {'LAMBDA', 0.0304}, ...
	 {'PHI', .8}, ...
	 {'VTO', -0.82}, ...
	 {'W', 20e-6}});
	 % parms are for ALD1107, from
	 % http://web.eece.maine.edu/~hummels/classes/ece343/docs/umaine.lib

    % clElem
    cktnetlist = add_element(cktnetlist, capModSpec(), 'CL', {'out', 'gnd'}, ...
    {{'C', CL}}, {});
end
