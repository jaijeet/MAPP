function cktnetlist = MOS1_char_curves_ckt()
%function cktnetlist = MOS1_char_curves_ckt()
% This function returns a cktnetlist structure for a circuit that drives
% an MOS1 NMOS with ALD1106's parameters to generate characteristic curves
% 
%The circuit
%    An N-type MOS (MOS1 model) driven by VGG and VDD voltages sources
%    to generate characteristic curves
%
%To see the schematic of this circuit, run:
%
% showimage('MOS1_char_curves.jpg'); % TODO: copy from MVS_char_curves.jpg
%
%Examples
%--------
%
% % set up DAE %
% DAE = MNA_EqnEngine(MOS1_char_curves_ckt);
% 
% % DC analysis %
% dcop = op(DAE);
% dcop.print(dcop);
% qssSol = dcop.getSolution(dcop);
% 
% % double DC sweep using a for loop %
% VGBs = 0:0.5:5;
% VDBs = -1:0.5:5;
% IDs = zeros(length(VGBs), length(VDBs));
%
% % list all circuit unknowns %
% DAE.unknames(DAE)
%
% % find out Id's indice (current through vsrc) in solution vector %
% idx = unkidx_DAEAPI('Vdd:::ipn', DAE)
% 
% % run DC sweep in a for loop %
% for c = 1:length(VGBs)
%     DAE = DAE.set_uQSS('Vgg:::E', VGBs(c), DAE);
%     swp = dcsweep(DAE, [], 'Vdd:::E', VDBs);
%     [pts, Sols] = swp.getsolution(swp);
%     IDs(c, :) = - Sols(idx, :);
% end % Vgg
% 
% % 3-D plot %
% figure; surf(VDBs, VGBs, IDs);

    % MOS1_Model = MOS1ModSpec_v1_wrapper();
    % MOS1_Model = MOS1ModSpec_v2_wrapper();
    MOS1_Model = MOS1ModSpec_v5_wrapper();

	% ckt name
	cktnetlist.cktname = 'MOS1 model: characteristic-curves';

	% nodes (names)
	cktnetlist.nodenames = {'drain', 'gate'};
	cktnetlist.groundnodename = 'gnd';

	% vddElem
	cktnetlist = add_element(cktnetlist, vsrcModSpec(), 'Vdd', {'drain', 'gnd'});

	% vggElem
	cktnetlist = add_element(cktnetlist, vsrcModSpec(), 'Vgg', {'gate', 'gnd'});

	% mosElem
	cktnetlist = add_element(cktnetlist, MOS1_Model, 'NMOS', {'drain', 'gate', 'gnd', 'gnd'}, ...
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

end
