function out = eqnnames(DAE)
%function out = eqnnames(DAE)
%This function returns the equation names in a DAE.
%INPUT args:
%   DAE             - a DAE object
%
%OUTPUT:
%   out             - names of equations in the DAE (cell array)

%author: J. Roychowdhury, 2011/05/31
	out = DAE.eqnnameList;
end
% end eqnnames
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Type "help MAPPlicense" at the MATLAB/Octave prompt to see the license      %
%% for this software.                                                          %
%% Copyright (C) 2008-2013 Jaijeet Roychowdhury <jr@berkeley.edu>. All rights  %
%% reserved.                                                                   %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%





