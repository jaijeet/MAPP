function cktnetlist = Hys_osc()
	cktnetlist.cktname = 'Hys_osc';
	cktnetlist.nodenames = {'1', '2'};
	cktnetlist.groundnodename = 'gnd';

    cktnetlist = add_element(cktnetlist, vsrcModSpec(), 'Vdd', {'1', 'gnd'}, {}, {{'DC', 3}});

    cktnetlist = add_element(cktnetlist, Hys(), 'H1', {'2', 'gnd'}, {{'tau', 1e-7}, {'A', 3}, {'B', -2}});

    cktnetlist = add_element(cktnetlist, resModSpec(), 'R1', {'1', '2'}, {{'R', 2}});
    cktnetlist = add_element(cktnetlist, capModSpec(), 'C1', {'2', 'gnd'}, {{'C', 1e-6}});

    cktnetlist.outputs = {}; % clear any already-declared outputs
    cktnetlist = add_output(cktnetlist, '2');
    cktnetlist = add_output(cktnetlist, 'i(H1)');
end % myR_Hys_osc
