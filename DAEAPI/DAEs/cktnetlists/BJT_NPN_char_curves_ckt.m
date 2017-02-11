function cktnetlist = BJT_NPN_char_curves_ckt()
%function cktnetlist = BJT_NPN_char_curves_ckt()
%This function returns a cktnetlist structure for a circuit that generates
%characteristic curves of Ebers Moll NPN BJTs.
%
%The circuit
%   An NPN-type BJT (Ebers Moll model) driven by VBE and VCE voltages sources
%   to generate characteristic curves
%
%To see the schematic of this circuit, run:
%
% showimage('BJT_NPN_char_curves.jpg'); %TODO
%
%Examples
%--------
%
% DAE =  MNA_EqnEngine(BJT_NPN_char_curves_ckt());
% 
% VBEs = [0:0.1:0.4, 0.41:0.01:0.5]; nVBEs = length(VBEs);
% VCEs = 0:0.05:0.5; nVCEs = length(VCEs);
% 
% ICs = zeros(nVBEs, nVCEs);
% 
% oidx = unkidx_DAEAPI('Vce:::ipn', DAE);
% 
% figure;
% hold on;
% xlabel 'VCE';
% ylabel 'IC';
% title 'Ebers Moll BJT (NPN) characteristic curves';
% hold on;
%
% for c = 1:nVBEs
% 	DAE = feval(DAE.set_uQSS, 'Vbe:::E', VBEs(c), DAE);
% 	swp = dcsweep(DAE, [], 'Vce:::E', VCEs);
% 	[oof, sol] = feval(swp.getsolution, swp);
% 	ICs(c, :) = sol(oidx, :);
% 	col = getcolorfromindex(gca(), c);
% 	marker = getmarkerfromindex(c);
% 	plot(VCEs, -ICs(c, :), sprintf('%s-', marker), 'Color', col);
%   drawnow;
% 	legends{c} = sprintf('VBE=%0.2g', VBEs(c));
% end
% 
% legend(legends, 'Location', 'SouthEast');
% 
% grid on; axis tight; box on;
%
%See also
%--------
% 
% add_element, supported_ModSpec_devices[TODO], DAEAPI, DAE_concepts
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


    BJT_model = EbersMoll_BJT_ModSpec;

	% ckt name
	cktnetlist.cktname = 'Ebers Moll BJT model: characteristic-curves';

	% nodes (names)
	cktnetlist.nodenames = {'c', 'b'};
	cktnetlist.groundnodename = 'e';

	VceDC = 0;
	VbeDC = 0;

	cktnetlist = add_element(cktnetlist, vsrcModSpec(), 'Vce', {'c', 'e'}, ...
	                         {}, {{'E', {'DC', VceDC}}});

	cktnetlist = add_element(cktnetlist, vsrcModSpec(), 'Vbe', {'b', 'e'}, ...
	                         {}, {{'E', {'DC', VbeDC}}});

	cktnetlist = add_element(cktnetlist, BJT_model, 'Q1', {'c', 'b', 'e'});
end
