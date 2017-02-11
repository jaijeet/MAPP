function cktnetlist = vsrc_sinh_ckt(use_initlimiting)
    cktnetlist.cktname = 'vsrc_sinh_ckt';
    cktnetlist.nodenames = {'1'}; % non-ground nodes
    cktnetlist.groundnodename = 'gnd';

    cktnetlist = add_element(cktnetlist, vsrcModSpec(), 'V1', ...
       {'1', 'gnd'}, {}, {{'DC', 1}});
	if use_initlimiting
		cktnetlist = add_element(cktnetlist, sinhIV_initlimiting(), 'S1', {'1', 'gnd'});
	else
		cktnetlist = add_element(cktnetlist, sinhIV(), 'S1', {'1', 'gnd'});
	end
end % vsrc_sinh_ckt
