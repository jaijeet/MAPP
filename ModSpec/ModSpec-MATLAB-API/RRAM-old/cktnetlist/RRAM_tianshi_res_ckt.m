function cktnetlist = RRAM_res_ckt(RRAM_Model)
%function cktnetlist = RRAM_res_ckt(RRAM_Model)
%This function returns a cktnetlist structure for a circuit with a series
%connection of vsrc, resistor and RRAM
% 
%The circuit
%  gnd-vsrc-n1-R-n2-RRAM-gnd
%
%Examples
%--------
% % set up DAE
% DAE = MNA_EqnEngine(RRAM_res_ckt());
%
% % DC analysis
% dcop = dot_op(DAE);
% feval(dcop.print, dcop);
%
% % run transient simulation
% % xinit = feval(dcop.getsolution, dcop);
% xinit = [5; 2.5; 1e-9; 0];
% tstart = 0; tstep = 0.2e-8; tstop = 15e-7; OBSOLETE
% LMSobj = dot_transient(DAE, xinit, tstart, tstep, tstop);
%
% % plot DAE outputs (defined using add_output inside vsrcRCL_ckt.m)
% feval(LMSobj.plot, LMSobj);
%
% % plot selected state outputs
% souts = StateOutputs(DAE);
% souts = souts.DeleteAll(souts);
% souts = souts.Add({'RRAM1:::l'}, souts);
% feval(LMSobj.plot, LMSobj, souts);
% souts = souts.DeleteAll(souts);
% souts = souts.Add({'Vdd:::ipn'}, souts);
% feval(LMSobj.plot, LMSobj, souts);
%
%See also
%--------
% 
% add_element, add_output, MAPPcktnetlists, cktnetlist_lowlevel,
% supported_ModSpec_devices[TODO], DAEAPI, DAE_concepts, dot_op, dot_transient 

%
%Author: Tianshi Wang, 2015/03/11
%

    if 1 > nargin
		% RRAM_Model = RRAM_UMich_ModSpec_wrapper_v0;
		% RRAM_Model = RRAM_UMich_ModSpec_wrapper_v1;
		% RRAM_Model = RRAM_UMich_ModSpec_wrapper_v2;
		% RRAM_Model = RRAM_UMich_ModSpec_wrapper_v3;
		% RRAM_Model = RRAM_UMich_ModSpec_wrapper_v4;
		RRAM_Model = RRAM_ModSpec_wrapper_v0;
    end

    % RRAM_Model = RRAM_Stanford_ModSpec_wrapper_v0;
    % RRAM_Model = RRAM_Stanford_ModSpec_wrapper_v1;
    % RRAM_Model = RRAM_Stanford_ModSpec_wrapper_v2;

	% ckt name
	cktnetlist.cktname = 'RRAM res';
	% nodes (names)
	cktnetlist.nodenames = {'n1', 'n2'}; % non-ground nodes
	cktnetlist.groundnodename = 'gnd';

	cktnetlist = add_element(cktnetlist, resModSpec, ...
				'R1', {'n1', 'n2'}, 10);
	cktnetlist = add_element(cktnetlist, RRAM_Model, ...
				'RRAM1', {'n2', 'gnd'});

    tranargs.offset = 0; tranargs.A = 5; tranargs.T = 20e-6; tranargs.phi = pi/2;
    tranfunc = @(t, args) args.offset+args.A*sawtooth(2*pi/args.T*t + args.phi, 0.5);
	cktnetlist = add_element(cktnetlist,  vsrcModSpec, 'Vdd', ...
				 {'n1', 'gnd'}, {}, {{'E', {'dc', 0.5}, {'tran', tranfunc, tranargs}}});
end
