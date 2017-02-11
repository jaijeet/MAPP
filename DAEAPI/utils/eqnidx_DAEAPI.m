function out = eqnidx_DAEAPI(eqnname, DAE)
%function out = eqnidx_DAEAPI(eqnname, DAE)
%This function returns the index of an equation name in a DAE.equnames cell
%array.
%INPUT args:
%   eqnname         - string value
%   DAE             - a DAE object
%
%OUTPUT:
%   out             - index of 'eqnname' in DAE.eqnnames cell array

%author: J. Roychowdhury, 2012/12/21
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Type "help MAPPlicense" at the MATLAB/Octave prompt to see the license      %
%% for this software.                                                          %
%% Copyright (C) 2008-2013 Jaijeet Roychowdhury <jr@berkeley.edu>. All rights  %
%% reserved.                                                                   %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%





	eqnnames = feval(DAE.eqnnames, DAE);
	out = strmatch(eqnname, eqnnames, 'exact');
	if length(out) ~= 1
		fprintf(2, 'eqnidx: warning: eqnname %s not found exactly once', eqnname);
	end
end
% end of eqnidx
