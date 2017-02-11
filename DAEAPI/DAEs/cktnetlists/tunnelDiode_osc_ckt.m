function cktnetlist = tunnelDiode_osc_ckt()
%function cktnetlist = tunnelDiode_osc_ckt()
%This function returns a cktnetlist structure for a tunnel diode oscillator
% 
%The circuit:
%    gnd -- vsrc --n1 -- L -- n2 -- R // C // tunnelDiode -- gnd 
%
%To see the schematic of this circuit, run:
%
% showimage('tunnelDiode_osc.jpg');
%
%Examples
%--------
% % set up DAE %
% DAE = MNA_EqnEngine(tunnelDiode_osc_ckt());
% 
% % DC analysis
% dcop = dot_op(DAE);
% feval(dcop.print, dcop);
% 
% % DC analysis confirms that at DC operation point, the tunnel diode is
% % within its negative resistance range.
% 
% % run transient and plot %
% xinit = zeros(DAE.nunks(DAE), 1);
% xinit(1) = 0.3;
% tstart = 0; tstep = 0.1e-9; tstop = 30e-9;
% LMSobj = dot_transient(DAE, xinit, tstart, tstep, tstop);
% feval(LMSobj.plot, LMSobj);
%
%See also
%--------
% 
% add_element, supported_ModSpec_devices[TODO], DAEAPI[TODO], DAE[TODO]
% dot_op, dot_transient 

%
%Author: Tianshi Wang, 2013/09/28
%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Type "help MAPPlicense" at the MATLAB/Octave prompt to see the license      %
%% for this software.                                                          %
%% Copyright (C) 2008-2013 Jaijeet Roychowdhury <jr@berkeley.edu>. All rights  %
%% reserved.                                                                   %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

	% ckt name
	cktnetlist.cktname = 'tunnelDiode LC oscillator';
	% nodes (names)
	cktnetlist.nodenames = {'n1', 'n2'}; % non-ground nodes
	cktnetlist.groundnodename = 'gnd';

	vM = vsrcModSpec();
		DCval = 0.2;
	cktnetlist = add_element(cktnetlist, vM, 'vsrc1', {'n1', 'gnd'}, {},    {{'E', {'dc', DCval}}});

	cktnetlist = add_element(cktnetlist, tunnelDiode_ModSpec_wrapper(), 'd1', {'n2', 'gnd'});
	cktnetlist = add_element(cktnetlist, resModSpec(), 'r1', {'n2', 'gnd'}, 1e9);
    cktnetlist = add_element(cktnetlist, indModSpec(), 'l1', {'n1', 'n2'}, 2e-6);
    cktnetlist = add_element(cktnetlist, capModSpec(), 'c1', {'n2', 'gnd'}, 0.5e-12);
