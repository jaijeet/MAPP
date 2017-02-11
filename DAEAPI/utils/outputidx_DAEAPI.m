function out = outputidx_DAEAPI(outputname, DAE)
%function out = outputidx_DAEAPI(outputname, DAE)
%This function returns the index of an output name in a DAE.outputnames cell
%array.
%INPUT args:
%   outputname      - string value
%   DAE             - a DAE object
%
%OUTPUT:
%   out             - index of 'outputname' in DAE.outputnames cell array


%author: J. Roychowdhury, 2012/12/21
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Type "help MAPPlicense" at the MATLAB/Octave prompt to see the license      %
%% for this software.                                                          %
%% Copyright (C) 2008-2013 Jaijeet Roychowdhury <jr@berkeley.edu>. All rights  %
%% reserved.                                                                   %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%





	outputnames = feval(DAE.outputnames, DAE);
	out = strmatch(outputname, outputnames, 'exact');
	if length(out) ~= 1
		fprintf(2, 'outputidx: warning: outputname %s not found exactly once', outputname);
	end
end
% end of outputidx
