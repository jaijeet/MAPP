function out = old_utransient(t, DAE)
%author: J. Roychowdhury, 2011/05/31
	if ischar(DAE.utfunc)
		daename = feval(DAE.daename,DAE);
		fprintf('utransient (%s): need to set_utransient first!\n',...
			daename);
		out = 'undefined';
	else
		out = feval(DAE.utfunc, t, DAE.utargs);
	end
% end old_utransient
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Type "help MAPPlicense" at the MATLAB/Octave prompt to see the license      %
%% for this software.                                                          %
%% Copyright (C) 2008-2013 Jaijeet Roychowdhury <jr@berkeley.edu>. All rights  %
%% reserved.                                                                   %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%





