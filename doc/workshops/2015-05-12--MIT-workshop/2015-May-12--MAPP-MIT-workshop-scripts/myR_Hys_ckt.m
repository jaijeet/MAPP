function cktnetlist = myR_Hys_ckt()
	cktnetlist.cktname = 'myR_Hys_ckt';
	cktnetlist.nodenames = {'1', '2'};
	cktnetlist.groundnodename = 'gnd';

    mysinfunc = @(t, args) 1.5 + 0.5 * sin(2*pi*1e3*t);

    cktnetlist = add_element(cktnetlist, vsrcModSpec(), 'Vdd', ...
       {'1', 'gnd'}, {}, {{'DC', 1.5}, {'TRAN', mysinfunc, []}});
    cktnetlist = add_element(cktnetlist, myR(), 'R1', {'1', '2'}, {{'R', 0.5}});
    cktnetlist = add_element(cktnetlist, Hys(), 'H1', {'2', 'gnd'}, {{'tau', 1e-5}});

    cktnetlist.outputs = {}; % clear any already-declared outputs
    cktnetlist = add_output(cktnetlist, '1');
    cktnetlist = add_output(cktnetlist, '2');
end % myR_Hys_ckt
