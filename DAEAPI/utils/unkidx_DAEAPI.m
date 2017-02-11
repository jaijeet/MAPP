function out = unkidx_DAEAPI(unkname, DAE)
%function out = unkidx_DAEAPI(unkname, DAE)
%This function returns the index of an unk name in a DAE.unknames cell
%array.
%INPUT args:
%   unkname         - string value
%   DAE             - a DAE object
%
%OUTPUT:
%   out             - index of 'unkname' in DAE.unknames cell array

%author: J. Roychowdhury, 2011/05/31
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Type "help MAPPlicense" at the MATLAB/Octave prompt to see the license      %
%% for this software.                                                          %
%% Copyright (C) 2008-2013 Jaijeet Roychowdhury <jr@berkeley.edu>. All rights  %
%% reserved.                                                                   %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%





	unknames = feval(DAE.unknames, DAE);
	out = strmatch(unkname, unknames, 'exact');
	if length(out) ~= 1
		fprintf(2, 'unkidx_DAEAPI: warning: unkname %s not found exactly once', unkname);
	end
end
% end of unkidx
