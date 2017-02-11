function cktnetlist = mvs_char_curves_ckt()
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
	cktnetlist = add_element(cktnetlist, mvsModSpec(), 'NMOS', {'drain', 'gate', 'gnd', 'gnd'}, ...
		{{'phit', 8.617e-5*(273+27)}, {'tipe', 1}, {'W', 1e-4},...
		{'Lgdr', 45e-7}, {'dLg', 7.56e-7}, {'Cg', 2.55e-6}}); 
end
