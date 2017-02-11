%Author: Jaijeet Roychowdhury <jr@berkeley.edu> 2011/sometime
% Test script for running DC analysis on a reduced RRE
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Type "help MAPPlicense" at the MATLAB/Octave prompt to see the license      %
%% for this software.                                                          %
%% Copyright (C) 2008-2013 Jaijeet Roychowdhury <jr@berkeley.edu>. All rights  %
%% reserved.                                                                   %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%






function run_reducedRRE_DC

	baseDAE = TwoReactionChainDAEAPIv6_2('somename');
	fprintf(1,'Supplied initial concentrations (do not change) are:\n');
	initconcs = [0.9; 0.8; 0.7; 0.6; 0.5]

	fprintf(1,'Applying conservation and setting up reduced DAE...\n');
	DAE = ReduceRREapplyingConservationv6_2('somename2', baseDAE, initconcs);
	daename = feval(DAE.daename, DAE);
	fprintf(1,'...done.\n', daename);

	n = feval(DAE.nunks, DAE);

	%initguess = ones(n,1); % leads to a solution with -ve concentrations.
	initguess = -ones(n,1);

	fprintf(1,'Running DC on the reduced DAE...\n');
	yR_DC = NR(@g, @dgdx, initguess, DAE);
	fprintf(1,'\n...done.\n');

	fprintf(1,'\n\nDC solution successfully found for:\n%s\n', daename);
	fprintf(1,'\nthe solution in conservation-reduced variables is:\n');
	yR_DC

	fprintf(1,'\nthe solution in original variables is:\n');
	ifs = feval(DAE.internalfuncs, DAE);
	x_DC = feval(ifs.map_yR_to_x, yR_DC, DAE)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function out = g(x, DAE6_2)
	out = feval(DAE6_2.f, x, [], DAE6_2);
% end of g(x, DAE6_2)

function out = dgdx(x, DAE6_2)
	out = feval(DAE6_2.df_dx, x, [], DAE6_2);
% end of g(x, DAE6_2)
