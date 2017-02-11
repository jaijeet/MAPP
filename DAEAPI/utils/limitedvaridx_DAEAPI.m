function out = limitedvaridx_DAEAPI(limitedvarname, DAE)
%function out = limitedvaridx_DAEAPI(limitedvarname, DAE)
%This function returns the index of an limited variable name in a
% DAE.limitedvarnames cell array.
%INPUT args:
%   limitedvarname         - string value
%   DAE             - a DAE object
%
%OUTPUT:
%   out             - index of 'limitedvar' in DAE.limitedvars cell array

%author: J. Roychowdhury, 2011/05/31
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Type "help MAPPlicense" at the MATLAB/Octave prompt to see the license      %
%% for this software.                                                          %
%% Copyright (C) 2008-2013 Jaijeet Roychowdhury <jr@berkeley.edu>. All rights  %
%% reserved.                                                                   %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%





	limitedvars = feval(DAE.limitedvarnames, DAE);
	out = strmatch(limitedvar, limitedvars, 'exact');
	if length(out) ~= 1
		fprintf(2, 'limitedvaridx_DAEAPI: warning: limitedvar %s not found exactly once', limitedvar);
	end
end
% end of limitedvaridx

