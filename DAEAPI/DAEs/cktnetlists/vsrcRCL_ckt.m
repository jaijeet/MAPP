function cktnetlist = vsrcRCL_ckt()
%function cktnetlist = vsrcRCL_ckt()
%This function returns a cktnetlist structure for a vsrc-R-C-L circuit
% 
%The circuit
%  gnd-vsrc-n1-R-n2-C-n3-L-gnd
%
%Examples
%--------
%
% % set up DAE
% DAE = MNA_EqnEngine(vsrcRCL_ckt());
%
% % DC analysis
% dcop = dot_op(DAE);
% feval(dcop.print, dcop);
%
% % run transient simulation
% xinit = feval(dcop.getsolution, dcop);
% tstart = 0; tstep = 0.5e-6; tstop = 1e-3;
% LMSobj = dot_transient(DAE, xinit, tstart, tstep, tstop);
%
% % plot DAE outputs (defined using add_output inside vsrcRCL_ckt.m)
% feval(LMSobj.plot, LMSobj);
%
% % plot selected state outputs
% souts = StateOutputs(DAE);
% souts = souts.DeleteAll(souts);
% souts = souts.Add({'e_1', 'e_3'}, souts);
% feval(LMSobj.plot, LMSobj, souts);
%
%See also
%--------
% 
% add_element, add_output, MAPPcktnetlists, cktnetlist_lowlevel,
% supported_ModSpec_devices[TODO], DAEAPI, DAE_concepts, dot_op, dot_transient 

%
%2015/01/11: add_output updates, JR.
%Author: Tianshi Wang, 2013/09/28
%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Type "help MAPPlicense" at the MATLAB/Octave prompt to see the license      %
%% for this software.                                                          %
%% Copyright (C) 2008-2013 Jaijeet Roychowdhury <jr@berkeley.edu>. All rights  %
%% reserved.                                                                   %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

	% ckt name
	cktnetlist.cktname = 'gnd-vsrc-n1-R-n2-C-n3-L-gnd';
	% nodes (names)
	cktnetlist.nodenames = {'1', '2', '3', 'gnd'}; % testing ground node
                                                % inclusion
	cktnetlist.groundnodename = 'gnd'; % 

	vM = vsrcModSpec();
		DCval = 0;
		tranfunc = @(t, args) args.offset + args.A * pulse(t, args.td, args.thi, args.tfs, args.tfe);
		tranfuncargs.A = 1; tranfuncargs.td = 0.2e-3;  tranfuncargs.thi = 0.21e-3;
		tranfuncargs.tfs = 0.6e-3; tranfuncargs.tfe = 0.61e-3; tranfuncargs.offset = 0;
	cktnetlist = add_element(cktnetlist, vM,           'vsrc1', {'1', 'gnd'}, {},    {{'E', {'dc', DCval}, {'tran', tranfunc, tranfuncargs}}});

	cktnetlist = add_element(cktnetlist, resModSpec(), 'r1', {'1', '2'}, {{'R',1e3}}, {});
	cktnetlist = add_element(cktnetlist, capModSpec(), 'c1', {'3', '2'}, 1e-8, {});
	cktnetlist = add_element(cktnetlist, indModSpec(), 'l1', {'3', 'gnd'}, 3e-2);

    cktnetlist = add_output(cktnetlist, '1'); % node voltage of '1'
    cktnetlist = add_output(cktnetlist, 'e(3)', [], 'vout'); % node voltage 
                                              % of '3', with output name vout
    cktnetlist = add_output(cktnetlist, 'i(vsrc1)', 1000);
                                        % current through vsrc1, scaled by 1000
