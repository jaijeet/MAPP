function cktnetlist = OpAmp741_ckt()
%function cktnetlist = OpAmp741_ckt()
%This function returns a cktnetlist structure for a classic 741 op-amp.
%
%The circuit
%
% TODO
%
%Examples
%--------
% TODO
%
%See also
%--------
% 
% add_element, supported_ModSpec_devices, DAEAPI, DAE

% Author: Bichen Wu 2014/04/06

BJT_model = EbersMoll_BJT_ModSpec();

	% setup 
	Vdd = 15;
	Vee = -Vdd;
	Amp = 6;
	freq = 1e3;

    IsF = 1e-12;
    IsR = IsF;
	% Rin = 2e4; Rout = 2e4; dot_op succeed
	Rin = 2e5; Rout = 4e5;

    vinoft = @(t, args) args.A*sin(2*pi*args.f*t + args.phi); % transient 
    vinargs.A = Amp; vinargs.f = freq; vinargs.phi = 0; 

	%===========================================================================
	% subcircuit: OpAmp
	%---------------------------------------------------------------------------
    % ckt name
    subcktnetlist.cktname = 'OpAmp741 with negative feedback';
    % nodes (names)
    % subcktnetlist.nodenames = {'dd', 'ee', 'in+', 'in-', 'nE0', 'nB0', 'nB0_1', 'nE0_1', 'nE1_1', 'nE2_1', 'in1+', 'in1-', 'nE1', 'nB2', 'nE2', 'nB3', 'out'}; % non-ground 
    subcktnetlist.nodenames = {'dd', 'ee', 'nBias0', 'nC1', 'in+', 'in-', 'nE1', 'nE2', 'nC3', 'nC4', 'nB5', 'offset+', 'offset-', 'nE16', ...
		'nE17', 'nBias1', 'nB20', 'nB18', 'nBias2', 'nE14', 'nE20', 'out', 'nE10', 'nB10', 'nB12', 'nB22'}; % non-ground 
    subcktnetlist.groundnodename = 'gnd';

	% Probe
    % subcktnetlist = add_element(subcktnetlist, vsrcModSpec(), 'Vprobe1', {'nBias1', 'nBias1_v'}, {}, {{'E' {'DC', 0}}});
    % subcktnetlist = add_element(subcktnetlist, vsrcModSpec(), 'Vprobe2', {'dd', 'dd_v'}, {}, {{'E' {'DC', 0}}});
    % subcktnetlist = add_element(subcktnetlist, vsrcModSpec(), 'Vprobe3', {'ee', 'ee_v'}, {}, {{'E' {'DC', 0}}});
    % subcktnetlist = add_element(subcktnetlist, vsrcModSpec(), 'Vprobe4', {'nB10_v', 'nB10'}, {}, {{'E' {'DC', 0}}});
	
	% Bias
  	subcktnetlist = add_element(subcktnetlist, BJT_model, 'Q11', ...
                  {'nB10', 'nB10', 'ee'}, {{'Rshunt', 1e8}, {'VtR', 0.026}, {'VtF', 0.026}});
  	subcktnetlist = add_element(subcktnetlist, BJT_model, 'Q10', ...
                  {'nBias0', 'nB10', 'nE10'}, {{'Rshunt', 1e8}, {'VtR', 0.026}, {'VtF', 0.026}});
    subcktnetlist = add_element(subcktnetlist, resModSpec(), 'R4', {'nE10', 'ee'}, {{'R', 5e3}}, {});
    subcktnetlist = add_element(subcktnetlist, resModSpec(), 'R5', {'nB10', 'nB12'}, {{'R', 39e3}}, {});

  	subcktnetlist = add_element(subcktnetlist, BJT_model, 'Q12', ...
                  {'nB12', 'nB12', 'dd'}, {{'Rshunt', 1e8}, {'VtR', 0.026}, {'VtF', 0.026}, {'tipe', 'PNP'}});
  	subcktnetlist = add_element(subcktnetlist, BJT_model, 'Q13B', ...
                  {'nBias1', 'nB12', 'dd'}, {{'Rshunt', 9.7125e4}, {'VtR', 0.026}, {'VtF', 0.026}, {'tipe', 'PNP'}, {'IsF', 3/4*IsF}, {'IsR', IsR/4}});
  	subcktnetlist = add_element(subcktnetlist, BJT_model, 'Q13A', ...
                  {'nBias2', 'nB12', 'dd'}, {{'Rshunt', 1e8}, {'VtR', 0.026}, {'VtF', 0.026}, {'tipe', 'PNP'}, {'IsF', 3/4*IsF}, {'IsR', IsR/4}});

    % subcktnetlist = add_element(subcktnetlist, isrcModSpec(), 'I1', {'nBias0', 'ee'}, {}, {{'I' {'DC', 19e-6}}});
    % subcktnetlist = add_element(subcktnetlist, resModSpec(), 'R02', {'dd', 'nBias1'}, {{'R', 2.78e4}}, {});
    % subcktnetlist = add_element(subcktnetlist, isrcModSpec(), 'I2', {'dd', 'nBias1'}, {}, {{'I' {'DC', 550e-6}}});
    % % subcktnetlist = add_element(subcktnetlist, resModSpec(), 'R03', {'dd', 'nBias2'}, {{'R', 1e5}}, {});
    % subcktnetlist = add_element(subcktnetlist, isrcModSpec(), 'I3', {'dd', 'nBias2'}, {}, {{'I' {'DC', 180e-6}}});

	% Input stage
		% current mirror
  	subcktnetlist = add_element(subcktnetlist, BJT_model, 'Q9', ...
                  {'nBias0', 'nC1', 'dd'}, {{'tipe', 'PNP'}, {'Rshunt', 1e8}, {'VtR', 0.026}, {'VtF', 0.026}});
  	subcktnetlist = add_element(subcktnetlist, BJT_model, 'Q8', ...
                  {'nC1', 'nC1', 'dd'}, {{'tipe', 'PNP'}, {'Rshunt', 1e8}, {'VtR', 0.026}, {'VtF', 0.026}});
		% diff pair
  	subcktnetlist = add_element(subcktnetlist, BJT_model, 'Q1', ...
                  {'nC1', 'in+', 'nE1'}, {{'Rshunt', 1e8}, {'VtR', 0.026}, {'VtF', 0.026}});
  	subcktnetlist = add_element(subcktnetlist, BJT_model, 'Q2', ...
                  {'nC1', 'in-', 'nE2'}, {{'Rshunt', 1e8}, {'VtR', 0.026}, {'VtF', 0.026}});
		% emitter follower
  	subcktnetlist = add_element(subcktnetlist, BJT_model, 'Q3', ...
                  {'nC3', 'nBias0', 'nE1'}, {{'tipe', 'PNP'}, {'Rshunt', 1e8}, {'VtR', 0.026}, {'VtF', 0.026}});
  	subcktnetlist = add_element(subcktnetlist, BJT_model, 'Q4', ...
                  {'nC4', 'nBias0', 'nE2'}, {{'tipe', 'PNP'}, {'Rshunt', 1e8}, {'VtR', 0.026}, {'VtF', 0.026}});
		% current mirror
  	subcktnetlist = add_element(subcktnetlist, BJT_model, 'Q5', ...
                  {'nC3', 'nB5', 'offset+'}, {{'Rshunt', 1e8}, {'VtR', 0.026}, {'VtF', 0.026}});
  	subcktnetlist = add_element(subcktnetlist, BJT_model, 'Q6', ...
                  {'nC4', 'nB5', 'offset-'}, {{'Rshunt', 1e8}, {'VtR', 0.026}, {'VtF', 0.026}});
  	subcktnetlist = add_element(subcktnetlist, BJT_model, 'Q7', ...
                  {'dd', 'nC3', 'nB5'}, {{'Rshunt', 1e8}, {'VtR', 0.026}, {'VtF', 0.026}});
    subcktnetlist = add_element(subcktnetlist, resModSpec(), 'R1', {'offset+', 'ee'}, {{'R', 1e3}}, {});
    subcktnetlist = add_element(subcktnetlist, resModSpec(), 'R2', {'offset-', 'ee'}, {{'R', 1e3}}, {});
    subcktnetlist = add_element(subcktnetlist, resModSpec(), 'R3', {'nB5', 'ee'}, {{'R', 50e3}}, {});

	% Gain stage
  	subcktnetlist = add_element(subcktnetlist, BJT_model, 'Q16', ...
                  {'dd', 'nC4', 'nE16'}, {{'Rshunt', 1e8}, {'VtR', 0.026}, {'VtF', 0.026}, {'alphaF', 0.996}});
  	subcktnetlist = add_element(subcktnetlist, BJT_model, 'Q17', ...
                  {'nBias1', 'nE16', 'nE17'}, {{'Rshunt', 1e8}, {'VtR', 0.026}, {'VtF', 0.026}, {'alphaF', 0.996}, ...
				  {'IsF', 1e-14}, {'IsR', 1e-14}});
    subcktnetlist = add_element(subcktnetlist, resModSpec(), 'R9', {'nE16', 'ee'}, {{'R', 50e3}}, {});
    subcktnetlist = add_element(subcktnetlist, resModSpec(), 'R8', {'nE17', 'ee'}, {{'R', 100}}, {});
    subcktnetlist = add_element(subcktnetlist, capModSpec(), 'Cc', {'nC4', 'nBias1'}, {{'C', 30e-12}}, {});

	% Output stage
  	subcktnetlist = add_element(subcktnetlist, BJT_model, 'Q23A', ...
                  {'ee', 'nBias1', 'nB20'}, {{'Rshunt', 1e8}, {'VtR', 0.026}, {'VtF', 0.026}, {'tipe', 'PNP'}});
		% bias
  	subcktnetlist = add_element(subcktnetlist, BJT_model, 'Q19', ...
                  {'nBias2', 'nBias2', 'nB18'}, {{'Rshunt', 1e8}, {'VtR', 0.026}, {'VtF', 0.026}});
  	subcktnetlist = add_element(subcktnetlist, BJT_model, 'Q18', ...
                  {'nBias2', 'nB18', 'nB20'}, {{'Rshunt', 1e8}, {'VtR', 0.026}, {'VtF', 0.026}});
    subcktnetlist = add_element(subcktnetlist, resModSpec(), 'R10', {'nB18', 'nB20'}, {{'R', 40e3}}, {});
		% output
  	subcktnetlist = add_element(subcktnetlist, BJT_model, 'Q14', ...
                  {'dd', 'nBias2', 'nE14'}, {{'IsF', 3*IsF},{'IsR', 3*IsR}, {'Rshunt', 1e8}, {'VtR', 0.026}, {'VtF', 0.026}});
    subcktnetlist = add_element(subcktnetlist, resModSpec(), 'R6', {'nE14', 'out'}, {{'R', 35}}, {});
	subcktnetlist = add_element(subcktnetlist, BJT_model, 'Q20', ...
                  {'ee', 'nB20', 'nE20'}, {{'IsF', 3*IsF}, {'IsR', 3*IsR}, {'tipe', 'PNP'}, {'Rshunt', 1e8}, {'VtR', 0.026}, {'VtF', 0.026}});
    subcktnetlist = add_element(subcktnetlist, resModSpec(), 'R7', {'nE20', 'out'}, {{'R', 22}}, {});
	
	% Short circuit protection
  	subcktnetlist = add_element(subcktnetlist, BJT_model, 'Q23B', ...
                  {'ee', 'nBias1', 'nC4'}, {{'Rshunt', 1e10}, {'VtR', 0.026}, {'VtF', 0.026}, {'tipe', 'PNP'}});
  	subcktnetlist = add_element(subcktnetlist, BJT_model, 'Q22', ...
                  {'nC4', 'nB22', 'ee'}, {{'Rshunt', 1e8}, {'VtR', 0.026}, {'VtF', 0.026}});
  	subcktnetlist = add_element(subcktnetlist, BJT_model, 'Q24', ...
                  {'nB22', 'nB22', 'ee'}, {{'Rshunt', 1e8}, {'VtR', 0.026}, {'VtF', 0.026}});
    subcktnetlist = add_element(subcktnetlist, resModSpec(), 'R11', {'nB22', 'ee'}, {{'R', 50e3}}, {});
	subcktnetlist = add_element(subcktnetlist, BJT_model, 'Q15', ...
                  {'nBias2', 'nE14', 'out'}, {{'Rshunt', 1e8}, {'VtR', 0.026}, {'VtF', 0.026}});
	subcktnetlist = add_element(subcktnetlist, BJT_model, 'Q21', ...
                  {'nB22', 'nE20', 'out'}, {{'tipe', 'PNP'}, {'Rshunt', 1e8}, {'VtR', 0.026}, {'VtF', 0.026}});


	OpAmp = subcktnetlist;
	OpAmp.terminalnames = {'in+', 'in-', 'offset+', 'offset-', 'dd',  'ee', 'out'};

	%===========================================================================

	% ckt name
	cktnetlist.cktname = 'OpAmp741';

	% nodes (names)
	cktnetlist.nodenames = {'dd', 'ee', 'in+', 'in-', 'in', 'offset+', 'offset-', 'out'};
	cktnetlist.groundnodename = 'gnd';

    cktnetlist = add_element(cktnetlist, vsrcModSpec(), 'Vdd', {'dd', 'gnd'}, {}, {{'E', {'DC', Vdd}}});
    cktnetlist = add_element(cktnetlist, vsrcModSpec(), 'Vee', {'ee', 'gnd'}, {}, {{'E', {'DC', Vee}}});

	cktnetlist = add_subcircuit(cktnetlist, OpAmp, 'X', {'in+', 'in-', 'offset+', 'offset-', 'dd', 'ee', 'out'}, {}, {});
    cktnetlist = add_element(cktnetlist, vsrcModSpec(), 'Voffset', {'offset+', 'offset-'}, {}, {{'E', {'DC', -0.00556}}});
    cktnetlist = add_element(cktnetlist, vsrcModSpec(), 'Vin+', {'in+', 'gnd'}, {}, {{'E', {'DC', 0}}});

    cktnetlist = add_element(cktnetlist, resModSpec(), 'Rout', {'in-', 'out'}, {{'R', Rout}}, {});
    cktnetlist = add_element(cktnetlist, resModSpec(), 'Rin', {'in-', 'in'}, {{'R', Rin}}, {});
    cktnetlist = add_element(cktnetlist, vsrcModSpec(), 'Vin', {'in', 'gnd'}, {}, {{'E', {'DC', 0}, {'tr', vinoft, vinargs}}});

