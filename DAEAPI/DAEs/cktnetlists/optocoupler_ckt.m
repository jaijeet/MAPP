function cktnetlist = optocoupler_ckt()
%function cktnetlist = optocoupler_ckt()
%This function returns a cktnetlist structure for an optocoupler.
% 
%The circuit
%   [TODO]
%
%To see the schematic of this circuit, run:
%
% showimage('optocoupler.jpg'); [TODO]
%
%Examples
%--------
%
%   [TODO]
%
%See also
%--------
% 
% add_element, supported_ModSpec_devices[TODO], DAEAPI[TODO], DAE[TODO]
% dot_op, dot_transient
%

%
% Author: Bichen Wu, sometime in 2013

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Type "help MAPPlicense" at the MATLAB/Octave prompt to see the license      %
%% for this software.                                                          %
%% Copyright (C) 2008-2013 Jaijeet Roychowdhury <jr@berkeley.edu>. All rights  %
%% reserved.                                                                   %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

	%===========================================================================
	% subcircuit: phototransistor
	%---------------------------------------------------------------------------
    % ckt name
    subcktnetlist.cktname = 'phototransistor';

    % nodes (names)
    subcktnetlist.nodenames = {'A', 'D', 'K', 'R', 'T', 'C', 'B', 'B1', 'E'};
    subcktnetlist.groundnodename = 'gnd';

    subcktnetlist = add_element(subcktnetlist, diodeModSpec(), 'LED', {'A', 'D'}, {}, {});

    subcktnetlist = add_element(subcktnetlist, ccvsModSpec(), 'Vsense', {'R', 'gnd','D', 'K'}, {}, {});

    subcktnetlist = add_element(subcktnetlist, resModSpec(), 'Rd', {'R', 'T'}, {{'R', 100e3}}, {}); 

    subcktnetlist = add_element(subcktnetlist, capModSpec(), 'Cd', {'T', 'gnd'}, {{'C', 20e-12}}, {}); 

    %subcktnetlist = add_element(subcktnetlist, vccs_for_optocoupler_ModSpec(), 'Gctrl', {'C', 'B','T', 'gnd'}, {}, {});
    subcktnetlist = add_element(subcktnetlist, vccsModSpec(), 'Gctrl', {'C', 'B1','T', 'gnd'}, {}, {});
    
    subcktnetlist = add_element(subcktnetlist, vsrcModSpec(), 'Vprobe', {'B', 'B1'}, {}, {{'E', {'DC',0} }});

    subcktnetlist = add_element(subcktnetlist, EbersMoll_BJT_ModSpec(), 'Q1', {'C', 'B', 'E'}, {}, {});

	%===========================================================================

	%Vin = @(t, args) args.offset + args.ampl*pulse(t*args.freq, 0, 0.01, 0.1, 0.11);
	Vin = @(t, args) 0.3;
	vinargs.offset = 0.6;
	vinargs.freq = 1e4;
	vinargs.ampl = 0.6;


	% ckt name
	cktnetlist.cktname = 'optocoupler_test_ckt';

	% nodes (names)
	cktnetlist.nodenames = {'vcc', 'out', 'P', 'N'};
	cktnetlist.groundnodename = 'gnd';

	VccDC = 5;
	R1 = 50;
	RL = 100;

	cktnetlist = add_element(cktnetlist, vsrcModSpec(), 'Vcc', {'vcc', 'gnd'}, {}, {{'E',...
	{'DC', VccDC}}});

	optocoupler = subcktnetlist;
	optocoupler.terminalnames = {'A', 'K', 'C', 'E'};

	cktnetlist = add_subcircuit(cktnetlist, optocoupler, 'X', {'P', 'N','vcc','out'}, {}, {});

	cktnetlist = add_element(cktnetlist, resModSpec(), 'R1', {'N', 'gnd'}, {{'R', R1}}, {});

	cktnetlist = add_element(cktnetlist, resModSpec(), 'RL', {'out', 'gnd'}, {{'R', RL}}, {});

	cktnetlist = add_element(cktnetlist, vsrcModSpec(), 'Vin', {'P', 'gnd'}, {}, {{'E', {'transient', Vin, vinargs} }});


end
