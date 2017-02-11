function cktnetlist = current_mirror_ckt()

	% Author: Bichen Wu, 2013/10/22
	
	cktnetlist.cktname = 'current_mirror';
	cktnetlist.nodenames = {'D1', 'D2', 'M2D', 'G'};
	cktnetlist.groundnodename = 'gnd';
	
	Vd = 2;
	k = 1e-4;
	I0 = 10e-6;
	RL = 1e4;
	W = 270;
	L = 180;
	DSgmin = 1e-8;

	utfunc = @(t,args) args.offset + args.A * sin(2*pi*args.f*t);
	utargs.offset = I0;
	utargs.A = 1e-6;
	utargs.f = 2e7;
	
	cktnetlist = add_element(cktnetlist, vsrcModSpec(), 'VD1', {'D1', 'gnd'}, {}, {{'E', {'DC', Vd}}});
	cktnetlist = add_element(cktnetlist, vsrcModSpec(), 'VD2', {'D2', 'gnd'}, {}, {{'E', {'DC', Vd}}});
	cktnetlist = add_element(cktnetlist, isrcModSpec(), 'I0', {'D1', 'G'}, {}, {{'I', {'DC', I0},{'TRAN',utfunc,utargs}}});
	cktnetlist = add_element(cktnetlist, resModSpec(), 'R', {'D2', 'M2D'}, {{'R', RL}}, {});
	cktnetlist = add_element(cktnetlist, SH_MOS_ModSpec(), 'M1', {'G', 'G', 'gnd'}, {{'Type', 'N'}, {'Beta', k*W/L}, {'VT', 0.3}}, {});
	cktnetlist = add_element(cktnetlist, SH_MOS_ModSpec(), 'M2', {'M2D', 'G', 'gnd'}, {{'Type', 'N'}, {'Beta', k*W/L}, {'VT', 0.3}}, {});
  cktnetlist = add_output(cktnetlist, 'i(VD1)', [], -1);
  cktnetlist = add_output(cktnetlist, 'i(VD2)', [], -1);	
	
end % current_mirror_ckt