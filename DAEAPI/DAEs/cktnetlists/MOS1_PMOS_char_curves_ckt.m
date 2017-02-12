function cktnetlist = MOS1_PMOS_char_curves_ckt()
%function cktnetlist = MOS1_PMOS_char_curves_ckt()
% This function returns a cktnetlist structure for a circuit that drives
% an MOS1 PMOS with ALD1107's parameters to generate characteristic curves
% 
%The circuit
%    An P-type MOS (MOS1 model) driven by VGG and VDD voltages sources
%    to generate characteristic curves
%
%To see the schematic of this circuit, run:
%
% showimage('MOS1_PMOS_char_curves.jpg'); % TODO: draw it
%
%Examples
%--------
%
% % set up DAE %
% DAE = MNA_EqnEngine(MOS1_PMOS_char_curves_ckt);
% 
% % DC analysis %
% dcop = op(DAE);
% dcop.print(dcop);
% qssSol = dcop.getSolution(dcop);
% 
% % double DC sweep using a for loop %
% VGBs = 0:-0.5:-3;
% VDBs = 0:-0.3:-3;
% IDs = zeros(length(VGBs), length(VDBs));
%
% % list all circuit unknowns %
% DAE.unknames(DAE)
%
% % find out Id's indice (current through vsrc) in solution vector %
% idx = unkidx_DAEAPI('Vd:::ipn', DAE)
% 
% % run DC sweep in a for loop %
% for c = 1:length(VGBs)
%     DAE = DAE.set_uQSS('Vg:::E', VGBs(c), DAE);
%     swp = dcsweep(DAE, [], 'Vd:::E', VDBs);
%     [pts, Sols] = swp.getsolution(swp);
%     IDs(c, :) = - Sols(idx, :);
% end % Vgg
% 
% % 3-D plot %
% figure; surf(VDBs, VGBs, IDs);

    MOS1_Model = MOS1ModSpec_v5_wrapper();

	% ckt name
	cktnetlist.cktname = 'MOS1 PMOS model: characteristic-curves';

	% nodes (names)
	cktnetlist.nodenames = {'vdd', 'drain', 'gate'};
	cktnetlist.groundnodename = 'gnd';

	% vddElem
	cktnetlist = add_element(cktnetlist, vsrcModSpec(), 'Vdd', {'vdd', 'gnd'}, {}, {{'DC', 3}});

	% vdElem
	cktnetlist = add_element(cktnetlist, vsrcModSpec(), 'Vd', {'drain', 'vdd'});

	% vgElem
	cktnetlist = add_element(cktnetlist, vsrcModSpec(), 'Vg', {'gate', 'vdd'});

	% mosElem
	cktnetlist = add_element(cktnetlist, MOS1_Model, 'NMOS', {'drain', 'gate', 'vdd', 'vdd'}, ...
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

end
