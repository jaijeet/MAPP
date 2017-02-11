function cktnetlist = myNMOSamp_ckt()
	cktnetlist.cktname = 'myNMOSamp_ckt';
	cktnetlist.nodenames = {'vdd', 'in', 'out'};
	cktnetlist.groundnodename = 'gnd';

    cktnetlist = add_element(cktnetlist, vsrcModSpec(), 'Vdd', ...
       {'vdd', 'gnd'}, {}, {{'DC', 2}});

    mysinfunc = @(t, args) 0.8 + 0.1*sin(2*pi*100*t);

    cktnetlist = add_element(cktnetlist, vsrcModSpec(), 'Vgg', ...
       {'in', 'gnd'}, {}, {{'DC', 0.8}, {'AC', 1}, {'TRAN', mysinfunc, []}});
    cktnetlist = add_element(cktnetlist, myR(), 'R1', ...
       {'vdd', 'out'}, {{'R', 2000}});
    cktnetlist = add_element(cktnetlist, myC(), 'C1', ...
       {'out', 'gnd'}, {{'C', 0.5e-6}});
    cktnetlist = add_element(cktnetlist, myNMOS(), 'M1', ...
       {'out', 'in', 'gnd'});

    cktnetlist.outputs = {}; % clear any already-declared outputs
    cktnetlist = add_output(cktnetlist, 'in');
    cktnetlist = add_output(cktnetlist, 'out');
end % myNMOSamp_ckt
