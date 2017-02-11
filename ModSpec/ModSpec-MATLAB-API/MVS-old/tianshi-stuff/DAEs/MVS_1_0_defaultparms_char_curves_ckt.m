function cktnetlist = MVS_1_0_defaultparms_char_curves_ckt()
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
	cktnetlist = add_element(cktnetlist, MVS_1_0_ModSpec(), 'NMOS', {'drain', 'gate', 'gnd', 'gnd'});
end
