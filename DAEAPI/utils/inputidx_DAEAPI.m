function out = inputidx_DAEAPI(inputname, DAE)
%function out = inputidx_DAEAPI(inputname, DAE)
%This function returns the index of an input name in a DAE.inputnames cell
%array.
%INPUT args:
%   inputname       - string value
%   DAE             - a DAE object
%
%OUTPUT:
%   out             - index of 'inputname' in DAE.inputnames cell array

%author: J. Roychowdhury, 2012/12/21
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Type "help MAPPlicense" at the MATLAB/Octave prompt to see the license      %
%% for this software.                                                          %
%% Copyright (C) 2008-2013 Jaijeet Roychowdhury <jr@berkeley.edu>. All rights  %
%% reserved.                                                                   %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%





	inputnames = feval(DAE.inputnames, DAE);
	out = strmatch(inputname, inputnames, 'exact');
	if length(out) ~= 1
		fprintf(2, 'inputidx: warning: inputname %s not found exactly once', inputname);
	end
end
% end of inputidx
