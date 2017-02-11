function cktnetlist = sinh_R_ckt(use_initlimiting)
    cktnetlist.cktname = 'sinh_R_ckt';
    cktnetlist.nodenames = {'1', '2'}; % non-ground nodes
    cktnetlist.groundnodename = 'gnd';

    cktnetlist = add_element(cktnetlist, vsrcModSpec(), 'V1', ...
       {'1', 'gnd'}, {}, {{'DC', 1}});
    cktnetlist = add_element(cktnetlist, resModSpec(), 'R1', {'1', '2'}, {{'R', 1}});
	if use_initlimiting
		cktnetlist = add_element(cktnetlist, sinhIV_initlimiting(), 'S1', {'2', 'gnd'});
	else
		cktnetlist = add_element(cktnetlist, sinhIV(), 'S1', {'2', 'gnd'});
	end
end % sinh_R_ckt
