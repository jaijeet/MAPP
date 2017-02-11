function cktnetlist = isrcRLC_ckt()
%function cktnetlist = isrcRLC_ckt()
% This function creates a test circuit for RLC_ModSpec_wrapper.
% It describes a circuit where an RLC_ModSpec_wrapper device is driven by a
% current source.
%
%The circuit
%  gnd -- isrc -- RLC --gnd
%
%Examples
%--------
%
% % set up DAE %
% DAE = MNA_EqnEngine(isrcRLC_ckt());
%
% % DC analysis %
% dcop = dot_op(DAE);
% feval(dcop.print, dcop);
%
% % run transient and plot %
% xinit = zeros(DAE.nunks(DAE), 1); % zero-state response
% tstart = 0; tstep = 1e-8; tstop = 5e-6;
% LMSobj = dot_transient(DAE, xinit, tstart, tstep, tstop);
% LMSobj.plot(LMSobj);
%
%See also
%--------
% 
% add_element, supported_ModSpec_devices[TODO], DAEAPI, DAE_concepts,
% dot_op, dot_transient 

%
%Author: Tianshi Wang, 2014/12/10
%

	% ckt name
	cktnetlist.cktname = 'isrc-RLC';
	% nodes (names)
	cktnetlist.nodenames = {'1'}; % non-ground node
	cktnetlist.groundnodename = 'gnd';

	cktnetlist = add_element(cktnetlist, isrcModSpec, 'i1', ...
                 {'1', 'gnd'}, {}, {{'I', {'dc', 1}}});

	cktnetlist = add_element(cktnetlist, RLC_ModSpec_wrapper, 'rlc1',...
                 {'1', 'gnd'}, {{'R', 1e3}, {'C', 1e-6}});
end
