function outDAE = old_set_utransient(utfunc, utargs, DAE);
%author: J. Roychowdhury, 2011/05/31
	if (nargin < 3)
	   fprintf(2,'Usage: outDAE = set_utransient(utfunc, utargs, DAE)\n');
	   return;
	end
	% TODO: check size = ninputs
	DAE.utfunc = utfunc; 
	DAE.utargs = utargs;
	% should be callable as: feval(funchandle, t, utargs);
	outDAE = DAE;
% end old_set_utransient

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Type "help MAPPlicense" at the MATLAB/Octave prompt to see the license      %
%% for this software.                                                          %
%% Copyright (C) 2008-2013 Jaijeet Roychowdhury <jr@berkeley.edu>. All rights  %
%% reserved.                                                                   %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%





