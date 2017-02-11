function cktnetlist = delay_line_ckt()

	% Author: Bichen Wu, 2013/10/22

	% ckt name
	cktnetlist.cktname = 'Shichman-Hodges MOS Delay line';

	% nodes (names)
	cktnetlist.nodenames = {'e1', 'e2', 'e3', 'e4', 'e5', 'dd','ctrl', 'in', 'out', 'dummy1', 'dummy2', 'dummy3', 'dummy4'};
	cktnetlist.groundnodename = '0';

	k = 10e-3;
	CL = 1e-15;
	Cgs = CL/100;
	Cgd = CL/100;
	Vdd = 2.5;
	Vctrl = 0.8;
	Vin = 2.5;

	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Delay line %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	cktnetlist = add_element(cktnetlist, SH_MOS_ModSpec_nolimiting(), 'M1', {'e1', 'e1', 'dummy1'}, ...
	{{'Type', 'P'}, {'Beta', k*270/180}, {'VT', 0.3}, {'Cgs',Cgs}, {'Cgd', Cgd}}, {});
	cktnetlist = add_element(cktnetlist, SH_MOS_ModSpec_nolimiting(), 'M2', {'e3', 'e1', 'dummy2'}, ...
	{{'Type', 'P'}, {'Beta', k*270/180}, {'VT', 0.3}, {'Cgs',Cgs}, {'Cgd', Cgd}}, {});

	cktnetlist = add_element(cktnetlist, SH_MOS_ModSpec_nolimiting(), 'M3', {'e2', 'e2', 'dummy3'}, ...
	{{'Type', 'N'}, {'Beta', k*225/180}, {'VT', 0.3}, {'Cgs',Cgs}, {'Cgd', Cgd}}, {});
	cktnetlist = add_element(cktnetlist, SH_MOS_ModSpec_nolimiting(), 'M4', {'e4', 'e2', 'dummy4'}, ...
	{{'Type', 'N'}, {'Beta', k*225/180}, {'VT', 0.3}, {'Cgs',Cgs}, {'Cgd', Cgd}}, {});

	cktnetlist = add_element(cktnetlist, SH_MOS_ModSpec_nolimiting(), 'M5', {'e5', 'in', 'e3'}, ...
	{{'Type', 'P'}, {'Beta', k*120/180}, {'VT', 0.3}, {'Cgs',Cgs}, {'Cgd', Cgd}}, {});
	cktnetlist = add_element(cktnetlist, SH_MOS_ModSpec_nolimiting(), 'M6', {'e5', 'in', 'e4'}, ...
	{{'Type', 'N'}, {'Beta', k*120/180}, {'VT', 0.3}, {'Cgs',Cgs}, {'Cgd', Cgd}}, {});

	cktnetlist = add_element(cktnetlist, SH_MOS_ModSpec_nolimiting(), 'M7', {'e1', 'ctrl', 'e2'}, ...
	{{'Type', 'N'}, {'Beta', k*120/90}, {'VT', 0.3}, {'Cgs',Cgs}, {'Cgd', Cgd}}, {});

	cktnetlist = add_element(cktnetlist, SH_MOS_ModSpec_nolimiting(), 'M8', {'out', 'e5', 'dd'}, ...
	{{'Type', 'P'}, {'Beta', k*360/180}, {'VT', 0.3}, {'Cgs',Cgs}, {'Cgd', Cgd}}, {});
	cktnetlist = add_element(cktnetlist, SH_MOS_ModSpec_nolimiting(), 'M9', {'out', 'e5', '0'}, ...
	{{'Type', 'N'}, {'Beta', k*180/180}, {'VT', 0.3}, {'Cgs',Cgs}, {'Cgd', Cgd}}, {});

	cktnetlist = add_element(cktnetlist, capModSpec(), 'C1', {'e5', '0'},{{'C', CL}}, {});

	cktnetlist = add_element(cktnetlist, vsrcModSpec(), 'Vdd', {'dd', '0'}, {}, {{'E',{'DC', Vdd}}});
	cktnetlist = add_element(cktnetlist, vsrcModSpec(), 'Vctrl', {'ctrl', '0'}, {}, {{'E',{'DC', Vctrl}}});
	cktnetlist = add_element(cktnetlist, vsrcModSpec(), 'Vin', {'in', '0'}, {}, {{'E',{'DC', Vin}}});
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% End Delay line %%%%%%%%%%%%%%%%%%%%%%%%%
	cktnetlist = add_element(cktnetlist, vsrcModSpec(), 'Vdummy1', {'dummy1', 'dd'}, {}, {{'E', {'DC', 0.0}}});
	cktnetlist = add_element(cktnetlist, vsrcModSpec(), 'Vdummy2', {'dummy2', 'dd'}, {}, {{'E', {'DC', 0.0}}});
	cktnetlist = add_element(cktnetlist, vsrcModSpec(), 'Vdummy3', {'dummy3', '0'}, {}, {{'E', {'DC', 0.0}}});
	cktnetlist = add_element(cktnetlist, vsrcModSpec(), 'Vdummy4', {'dummy4', '0'}, {}, {{'E', {'DC', 0.0}}});


end

