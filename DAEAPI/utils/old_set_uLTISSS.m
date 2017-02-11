function outDAE = old_set_uLTISSS(Uffunc, Ufargs, DAE);
	if (nargin < 3)
	   fprintf(2,'Usage: outDAE = set_uLTISSS(Uffunc, Ufargs, DAE)\n');
	   return;
	end
	% TODO: check size = ninputs
	DAE.Uffunc = Uffunc; 
	DAE.Ufargs = Ufargs; 
	outDAE = DAE;
% end old_set_uLTISSS

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Type "help MAPPlicense" at the MATLAB/Octave prompt to see the license      %
%% for this software.                                                          %
%% Copyright (C) 2008-2013 Jaijeet Roychowdhury <jr@berkeley.edu>. All rights  %
%% reserved.                                                                   %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%





