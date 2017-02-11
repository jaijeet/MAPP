function cktnetlist = OTA_ckt()

	% Author: Bichen Wu, 2013/10/22

	% ckt name
	cktnetlist.cktname = 'OTA';

	% nodes (names)
	cktnetlist.nodenames = {'inp','inn','nvb0','nvb1','nvb2','nvb3','nvb4', 'nvb5', 'vdd','n10','n11','outp','n5','outn','n6','n1','n2','n8','n9'};
	cktnetlist.groundnodename = 'gnd';

	%%%%%%%%%%%%%% Parm %%%%%%%%%%%%%%%%%
	VddDC = 1.6;
	k = 5e-2;

	Cgs = 1e-14;
	Cgd = 1e-14;
	vt = 0.3;
	gmin = 1e-8;

	%%%%%%%%%%%%%% Input %%%%%%%%%%%%%%%%%
	cktnetlist = add_element(cktnetlist, vsrcModSpec(), 'Vinp', {'inp', 'inn'}, {}, {{'E', {'DC', 0}}});
	cktnetlist = add_element(cktnetlist, vsrcModSpec(), 'Vinn', {'inn', 'gnd'}, {}, {{'E', {'DC', 0.3}}});

	%%%%%%%%%% Power Supply %%%%%%%%%%%%%
	cktnetlist = add_element(cktnetlist, vsrcModSpec(), 'VDD', {'vdd', 'gnd'}, {}, {{'E', {'DC',VddDC}}});

	%%%%%%%%%%%%%% Bias %%%%%%%%%%%%%%%%%
	cktnetlist = add_element(cktnetlist, vsrcModSpec(), 'VB0', {'nvb0', 'gnd'}, {}, {{'E', {'DC', 1.1}}});
	cktnetlist = add_element(cktnetlist, vsrcModSpec(), 'VB1', {'nvb1', 'gnd'}, {}, {{'E', {'DC', 1.1}}});
	cktnetlist = add_element(cktnetlist, vsrcModSpec(), 'VB2', {'nvb2', 'gnd'}, {}, {{'E', {'DC', 0.7}}});
	cktnetlist = add_element(cktnetlist, vsrcModSpec(), 'VB5', {'nvb5', 'gnd'}, {}, {{'E', {'DC', 0.7}}});
	cktnetlist = add_element(cktnetlist, vsrcModSpec(), 'VB3', {'nvb3', 'gnd'}, {}, {{'E', {'DC', 0.9}}});
	cktnetlist = add_element(cktnetlist, vsrcModSpec(), 'VB4', {'nvb4', 'gnd'}, {}, {{'E', {'DC', 0.5}}});

	%%%%%%%%%%%%%% sensor %%%%%%%%%%%%%%%%%
	cktnetlist = add_element(cktnetlist, vsrcModSpec(), 'V0', {'vdd', 'n10'}, {}, {{'E', {'DC', 0.0}}});
	cktnetlist = add_element(cktnetlist, vsrcModSpec(), 'V1', {'vdd', 'n11'}, {}, {{'E', {'DC', 0.0}}});

	%%%%%%%%%%%%%% OTA %%%%%%%%%%%%%%%%%
	cktnetlist = add_element(cktnetlist, SH_MOS_ModSpec_nolimiting(), 'MP8', {'n2', 'nvb1', 'vdd'}, ...
	{{'Type', 'P'}, {'Beta', k*10/6}, {'VT', vt}, {'Cgs',Cgs}, {'Cgd', Cgd}, {'DSgmin', gmin}}, {});

	cktnetlist = add_element(cktnetlist, SH_MOS_ModSpec_nolimiting(), 'MP6', {'n1', 'nvb1', 'n11'}, ...
	{{'Type', 'P'}, {'Beta', k*10/6}, {'VT', vt}, {'Cgs',Cgs}, {'Cgd', Cgd}, {'DSgmin', gmin}}, {});

	cktnetlist = add_element(cktnetlist, SH_MOS_ModSpec_nolimiting(), 'MP7', {'outn', 'nvb2', 'n2'}, ...
	{{'Type', 'P'}, {'Beta', k*10/6}, {'VT', vt}, {'Cgs',Cgs}, {'Cgd', Cgd}, {'DSgmin', gmin}}, {});

	cktnetlist = add_element(cktnetlist, SH_MOS_ModSpec_nolimiting(), 'MP5', {'outp', 'nvb2', 'n1'}, ...
	{{'Type', 'P'}, {'Beta', k*10/6}, {'VT', vt}, {'Cgs',Cgs}, {'Cgd', Cgd}, {'DSgmin', gmin}}, {});


	cktnetlist = add_element(cktnetlist, SH_MOS_ModSpec_nolimiting(), 'MN7', {'outn', 'nvb3', 'n6'}, ...
	{{'Type', 'N'}, {'Beta', k*10/6}, {'VT', vt}, {'Cgs',Cgs}, {'Cgd', Cgd}, {'DSgmin', gmin}}, {});

	cktnetlist = add_element(cktnetlist, SH_MOS_ModSpec_nolimiting(), 'MN5', {'outp', 'nvb3', 'n5'}, ...
	{{'Type', 'N'}, {'Beta', k*10/6}, {'VT', vt}, {'Cgs',Cgs}, {'Cgd', Cgd}, {'DSgmin', gmin}}, {});

	cktnetlist = add_element(cktnetlist, SH_MOS_ModSpec_nolimiting(), 'MN8', {'n6', 'nvb4', 'gnd'}, ...
	{{'Type', 'N'}, {'Beta', k*10*2/6}, {'VT', vt}, {'Cgs',Cgs}, {'Cgd', Cgd}, {'DSgmin', gmin}}, {});

	cktnetlist = add_element(cktnetlist, SH_MOS_ModSpec_nolimiting(), 'MN6', {'n5', 'nvb4', 'gnd'}, ...
	{{'Type', 'N'}, {'Beta', k*10*2/6}, {'VT', vt}, {'Cgs',Cgs}, {'Cgd', Cgd}, {'DSgmin', gmin}}, {});


	cktnetlist = add_element(cktnetlist, SH_MOS_ModSpec_nolimiting(), 'MP1', {'n5', 'inp', 'n8'}, ...
	{{'Type', 'P'}, {'Beta', k*10/6}, {'VT', vt}, {'Cgs',Cgs}, {'Cgd', Cgd}, {'DSgmin', gmin}}, {});

	cktnetlist = add_element(cktnetlist, SH_MOS_ModSpec_nolimiting(), 'MP2', {'n6', 'inn', 'n8'}, ...
	{{'Type', 'P'}, {'Beta', k*10/6}, {'VT', vt}, {'Cgs',Cgs}, {'Cgd', Cgd}, {'DSgmin', gmin}}, {});

	cktnetlist = add_element(cktnetlist, SH_MOS_ModSpec_nolimiting(), 'MP3', {'n8', 'nvb5', 'n9'}, ...
	{{'Type', 'P'}, {'Beta', k*10*2/6}, {'VT', vt}, {'Cgs',Cgs}, {'Cgd', Cgd}, {'DSgmin', gmin}}, {});

	cktnetlist = add_element(cktnetlist, SH_MOS_ModSpec_nolimiting(), 'MP4', {'n9', 'nvb0', 'n10'}, ...
	{{'Type', 'P'}, {'Beta', k*10*2/6}, {'VT', vt}, {'Cgs',Cgs}, {'Cgd', Cgd}, {'DSgmin', gmin}}, {});

end


