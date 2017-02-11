function cktnetlist = SH_PMOS_char_curves_ckt()
%function cktnetlist = SH_PMOS_char_curves_ckt()
%This function returns a cktnetlist structure for PMOS characteristic curves
%circuit
%
%The circuit
%   An P-type MOS (Schichman Hodges model) driven by VGG and VDD voltages
%   sources to generate characteristic curves
%
%To see the schematic of this circuit, run:
%
% showimage('SH_PMOS_char_curves.jpg'); [TODO]
%
%Examples
%--------
%
% run_SH_PMOS_char_curves_ckt_DCsweep
%
%See also
%--------
% 
% add_element, supported_ModSpec_devices[TODO], DAEAPI[TODO], DAE[TODO]
% run_SH_char_curves_ckt_DCsweep.m
%

%
% Author: Tianshi Wang, 2013/11/08
%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Type "help MAPPlicense" at the MATLAB/Octave prompt to see the license      %
%% for this software.                                                          %
%% Copyright (C) 2008-2013 Jaijeet Roychowdhury <jr@berkeley.edu>. All rights  %
%% reserved.                                                                   %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


	% ckt name
	cktnetlist.cktname = 'Shichman-Hodges PMOS: characteristic-curves';

	% nodes (names)
	cktnetlist.nodenames = {'drain', 'gate'};
	cktnetlist.groundnodename = 'gnd';

	VddDC = 0;
	VggDC = 0;

	% vddElem
	cktnetlist = add_element(cktnetlist, vsrcModSpec(), 'Vdd', {'drain', 'gnd'}, {}, {{'E',...
	{'DC', VddDC}}});

	% vggElem
	cktnetlist = add_element(cktnetlist, vsrcModSpec(), 'Vgg', {'gate', 'gnd'}, {}, {{'E',...
	{'DC', VggDC}}});

	% mosElem
	cktnetlist = add_element(cktnetlist, SH_MOS_ModSpec(), 'PMOS', {'drain', 'gate', 'gnd'}, ...
	{{'Type', 'P'}, {'Beta', 1.8}, {'VT', 0.1}}, {});

end
