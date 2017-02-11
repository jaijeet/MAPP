function cktnetlist = myRC_ckt()
	cktnetlist.cktname = 'myRC_ckt';
	cktnetlist.nodenames = {'1', '2'}; % non-ground nodes
	cktnetlist.groundnodename = 'gnd';

    cktnetlist = add_element(cktnetlist, myR(), 'R1', {'1', '2'}, {{'R', 1000}});
    cktnetlist = add_element(cktnetlist, myC(), 'C1', {'2', 'gnd'}, 1e-6);

    mysinfunc = @(t, args) sin(2*pi*1000*t);

    cktnetlist = add_element(cktnetlist, vsrcModSpec(), 'V1', ...
       {'1', 'gnd'}, {}, {{'DC', 1}, {'AC', 1}, {'TRAN', mysinfunc, []}});
end % myRC_ckt
