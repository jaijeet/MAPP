function outDAE = old_set_uHB(uHBfunc, uHBargs, DAE);
	if (nargin < 3)
	   fprintf(2,'Usage: outDAE = set_uHB(uHBfunc, uHBargs, DAE)\n');
	   return;
	end
	% TODO: check size = ninputs
	DAE.uHBfunc = uHBfunc; 
	DAE.uHBargs = uHBargs; 
	outDAE = DAE;
% end old_set_uHB

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Type "help MAPPlicense" at the MATLAB/Octave prompt to see the license      %
%% for this software.                                                          %
%% Copyright (C) 2008-2013 Jaijeet Roychowdhury <jr@berkeley.edu>. All rights  %
%% reserved.                                                                   %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%





