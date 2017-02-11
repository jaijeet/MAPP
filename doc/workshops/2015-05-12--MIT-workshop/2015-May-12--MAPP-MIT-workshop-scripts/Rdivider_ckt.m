function cktnetlist = Rdivider_ckt()
	cktnetlist.cktname = 'Rdivider_ckt';
	cktnetlist.nodenames = {'1', '2', '3'}; % non-ground nodes
	cktnetlist.groundnodename = 'gnd';

    cktnetlist = add_element(cktnetlist, myR(), 'R1', {'1', '2'}, {{'R', 1000}});
    cktnetlist = add_element(cktnetlist, myR_vpn(), 'R2', {'2', '3'}, {{'R', 1000}});
    cktnetlist = add_element(cktnetlist, myR_implicit(), 'R3', {'3', 'gnd'}, {{'R', 1000}});

    cktnetlist = add_element(cktnetlist, vsrcModSpec(), 'V1', ...
       {'1', 'gnd'}, {}, {{'DC', 1}});

    cktnetlist.outputs = {}; % clear any already-declared outputs
    cktnetlist = add_output(cktnetlist, '1');
    cktnetlist = add_output(cktnetlist, '2');
    cktnetlist = add_output(cktnetlist, '3');
end % Rdivider_ckt
