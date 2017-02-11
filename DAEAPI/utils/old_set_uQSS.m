function outDAE = old_set_uQSS(qssvec, DAE);
%function outDAE = set_uQSS(qssvec, DAE);
	if (nargin < 2)
	   fprintf(2,'Usage: outDAE = set_uQSS(qssvec, DAE)\n');
	   return;
	end
	% TODO: check size = ninputs
	DAE.uQSSvec = qssvec; 
	outDAE = DAE;
% end old_set_uQSS

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Type "help MAPPlicense" at the MATLAB/Octave prompt to see the license      %
%% for this software.                                                          %
%% Copyright (C) 2008-2013 Jaijeet Roychowdhury <jr@berkeley.edu>. All rights  %
%% reserved.                                                                   %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%





