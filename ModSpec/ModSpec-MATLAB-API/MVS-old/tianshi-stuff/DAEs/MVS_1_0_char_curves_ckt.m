function cktnetlist = MVS_1_0_char_curves_ckt()
	% ckt name
	cktnetlist.cktname = 'MVS MOS model: characteristic-curves';

	% nodes (names)
	cktnetlist.nodenames = {'drain', 'gate'};
	cktnetlist.groundnodename = 'gnd';

	VddDC = 0;
	VggDC = 0;

	% vddElem
	cktnetlist = add_element(cktnetlist, vsrcModSpec(), 'Vdd', {'drain', 'gnd'}, {}, {{'E',...
	{'DC', VddDC}}});

	% vggElem
	cktnetlist = add_element(cktnetlist, vsrcModSpec(), 'Vgg', {'gate', 'gnd'}, {}, {{'E',...
	{'DC', VggDC}}});

	% mosElem
	cktnetlist = add_element(cktnetlist, MVS_1_0_ModSpec(), 'NMOS', {'drain', 'gate', 'gnd', 'gnd'}, ...
	 { {'tipe', 1}, {'W', 1e-4}, {'Lgdr', 32e-7}, {'dLg', 9e-7}, ...
	 {'Cg', 2.57e-6}, {'parm_beta', 1.8}, {'parm_alpha', 3.5}, ...
	 {'Cif', 1.38e-12}, {'Cof', 1.47e-12}, {'phib', 1.2}, ...
	 {'parm_gamma', 0.1}, {'mc', 0.2}, {'CTM_select', 1}, {'Rs0', 100}, ...
	 {'Rd0', 100}, {'n0', 1.68}, {'nd', 0.1}, {'vxo', 1.2e7}, ...
	 {'parm_mu', 200}, {'Vt0', 0.4}, {'delta', 0.15} });
end
