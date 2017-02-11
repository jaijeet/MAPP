function cktnetlist = charge_pump_ckt()

	% Author: Bichen Wu, 2013/10/22

	% ckt name
	cktnetlist.cktname = 'Shichman-Hodges MOS Charge Pump';

	% nodes (names)
	cktnetlist.nodenames = {'vdd', 'g12', 's5', 'g34', 's6', 'up', 'upbar', 'down', 'downbar', 'downbarbar', 'cpout', 'dummy1', 'dummy2', 'dummy3', 'dummy4'};
	cktnetlist.groundnodename = 'gnd';

	VddDC = 2;
	I0 = 20e-6;
	k = 1e-4;
	RL = 1e9;
	CL = 1e-12;

	Cgs = CL/100;
	Cgd = CL/100;

	cktnetlist = add_element(cktnetlist, vsrcModSpec(), 'Vdummy1', {'dummy1', 'vdd'}, {}, {{'E', {'DC', 0.0}}});
	cktnetlist = add_element(cktnetlist, vsrcModSpec(), 'Vdummy2', {'dummy2', 'vdd'}, {}, {{'E', {'DC', 0.0}}});
	cktnetlist = add_element(cktnetlist, vsrcModSpec(), 'Vdummy3', {'dummy3', 'gnd'}, {}, {{'E', {'DC', 0.0}}});
	cktnetlist = add_element(cktnetlist, vsrcModSpec(), 'Vdummy4', {'dummy4', 'gnd'}, {}, {{'E', {'DC', 0.0}}});

	% VElem
	cktnetlist = add_element(cktnetlist, vsrcModSpec(), 'Vdd', {'vdd', 'gnd'}, {}, {{'E',...
	{'DC', VddDC}}});
	% VElem
	cktnetlist = add_element(cktnetlist, vsrcModSpec(), 'Vdown', {'down', 'gnd'}, {}, {{'E',...
	{'DC', 0}}});
	% VElem
	cktnetlist = add_element(cktnetlist, vsrcModSpec(), 'Vup', {'up', 'gnd'}, {}, {{'E',...
	{'DC', 2}}});

	% IElem
	cktnetlist = add_element(cktnetlist, isrcModSpec(), 'I01', {'g12', 'gnd'}, {}, {{'I',...
	{'DC', I0}}});
	% pmos1Elem
	cktnetlist = add_element(cktnetlist, SH_MOS_ModSpec_nolimiting(), 'M1', {'g12', 'g12', 'dummy1'}, ...
	{{'Type', 'P'}, {'Beta', k*270/180}, {'VT', 0.3}, {'Cgs',Cgs}, {'Cgd', Cgd}}, {});
	% pmos1Elem
	cktnetlist = add_element(cktnetlist, SH_MOS_ModSpec_nolimiting(), 'M2', {'s5', 'g12', 'dummy2'}, ...
	{{'Type', 'P'}, {'Beta', k*270/180}, {'VT', 0.3}, {'Cgs',Cgs}, {'Cgd', Cgd}}, {});

	% IElem
	cktnetlist = add_element(cktnetlist, isrcModSpec(), 'I02', {'vdd', 'g34'}, {}, {{'I',...
	{'DC', I0}}});
	% nmos1Elem
	cktnetlist = add_element(cktnetlist, SH_MOS_ModSpec_nolimiting(), 'M3', {'g34', 'g34', 'dummy3'}, ...
	{{'Type', 'N'}, {'Beta', k*270/180}, {'VT', 0.3}, {'Cgs',Cgs}, {'Cgd', Cgd}}, {});
	% nmos1Elem
	cktnetlist = add_element(cktnetlist, SH_MOS_ModSpec_nolimiting(), 'M4', {'s6', 'g34', 'dummy4'}, ...
	{{'Type', 'N'}, {'Beta', k*225/180}, {'VT', 0.3}, {'Cgs',Cgs}, {'Cgd', Cgd}}, {});


	% Inverter
	% pmos1Elem
	% Subject to change
	cktnetlist = add_element(cktnetlist, SH_MOS_ModSpec_nolimiting(), 'X1P', {'upbar', 'up', 'vdd'}, ...
	{{'Type', 'P'}, {'Beta', k*120/90}, {'VT', 0.3}, {'Cgs',Cgs}, {'Cgd', Cgd}}, {});
	% nmos1Elem
	cktnetlist = add_element(cktnetlist, SH_MOS_ModSpec_nolimiting(), 'X1N', {'upbar', 'up', 'gnd'}, ...
	{{'Type', 'N'}, {'Beta', k*90/90}, {'VT', 0.3}, {'Cgs',Cgs}, {'Cgd', Cgd}}, {});

	% Inverter
	% pmos1Elem
	% Subject to change
	cktnetlist = add_element(cktnetlist, SH_MOS_ModSpec_nolimiting(), 'X2P', {'downbar', 'down', 'vdd'}, ...
	{{'Type', 'P'}, {'Beta', k*120/90}, {'VT', 0.3}, {'Cgs',Cgs}, {'Cgd', Cgd}}, {});
	% nmos1Elem
	cktnetlist = add_element(cktnetlist, SH_MOS_ModSpec_nolimiting(), 'X2N', {'downbar', 'down', 'gnd'}, ...
	{{'Type', 'N'}, {'Beta', k*90/90}, {'VT', 0.3}, {'Cgs',Cgs}, {'Cgd', Cgd}}, {});

	% Inverter 
	% Subject to change
	% pmos1Elem
	cktnetlist = add_element(cktnetlist, SH_MOS_ModSpec_nolimiting(), 'X3P', {'downbarbar', 'downbar', 'vdd'}, ...
	{{'Type', 'P'}, {'Beta',k*120/90}, {'VT', 0.3}, {'Cgs',Cgs}, {'Cgd', Cgd}}, {});
	% nmos1Elem
	cktnetlist = add_element(cktnetlist, SH_MOS_ModSpec_nolimiting(), 'X3N', {'downbarbar', 'downbar', 'gnd'}, ...
	{{'Type', 'N'}, {'Beta',k* 90/90}, {'VT', 0.3}, {'Cgs',Cgs}, {'Cgd', Cgd}}, {});

	% pmos1Elem
	cktnetlist = add_element(cktnetlist, SH_MOS_ModSpec_nolimiting(), 'M5', {'cpout', 'upbar', 's5'}, ...
	{{'Type', 'P'}, {'Beta', k*270/180}, {'VT', 0.3}, {'Cgs',Cgs}, {'Cgd', Cgd}}, {});
	% nmos1Elem
	cktnetlist = add_element(cktnetlist, SH_MOS_ModSpec_nolimiting(), 'M6', {'cpout', 'downbarbar', 's6'}, ...
	{{'Type', 'N'}, {'Beta', k*225/180}, {'VT', 0.3}, {'Cgs',Cgs}, {'Cgd', Cgd}}, {});


	% c1Elem
	cktnetlist = add_element(cktnetlist, capModSpec(), 'C1', {'cpout', 'gnd'}, ...
	{{'C', CL}}, {});
	% RElem
	cktnetlist = add_element(cktnetlist, resModSpec(), 'R1', {'cpout', 'gnd'}, ...
	{{'R', RL}}, {});


end
