function cktnetlist = SH_char_curves_ckt()
%function cktnetlist = SH_char_curves_ckt()
%This function returns a cktnetlist structure for MOSFET characteristic curves
%circuit.
%
%The circuit
%   An N-type MOS (Schichman Hodges model) driven by Vgg and Vdd voltage
%   sources to generate characteristic curves.
%
%To see the schematic of this circuit, run:
%
% showimage('SH_char_curves.jpg');
%
%To see the script that runs DC sweep on this circuit and generates the
%characteristic curves, you can run:
%
% edit run_SH_char_curves_ckt_DCsweep.m;
%     or
% type run_SH_char_curves_ckt_DCsweep.m;
%
%Examples
%--------
%
% run_SH_char_curves_ckt_DCsweep;
%
%See also
%--------
% 
% add_element, supported_ModSpec_devices[TODO], DAEAPI, DAE_concepts,
% run_SH_char_curves_ckt_DCsweep
%

%
% Author: Tianshi Wang, 2013/09/28
%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Type "help MAPPlicense" at the MATLAB/Octave prompt to see the license      %
%% for this software.                                                          %
%% Copyright (C) 2008-2013 Jaijeet Roychowdhury <jr@berkeley.edu>. All rights  %
%% reserved.                                                                   %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


	% ckt name
	cktnetlist.cktname = 'Shichman Hodges MOS model: characteristic-curves';

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
	cktnetlist = add_element(cktnetlist, SH_MOS_ModSpec(), 'NMOS', {'drain', 'gate', 'gnd'}, ...
	{{'Beta', 1.8}, {'VT', 0.1}}, {});

end
