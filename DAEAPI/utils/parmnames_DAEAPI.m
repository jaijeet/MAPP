function out = parmnames_DAEPAI(DAE)
%function out = parmnames_DAEPAI(DAE)
%This function returns the parameter names in a DAE.
%INPUT args:
%   DAE             - a DAE object
%
%OUTPUT:
%   out             - names of parameters in the DAE (cell array)

%author: J. Roychowdhury, 2011/05/31
	out = DAE.parmnameList;
% end parmnames_DAEAPI
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Type "help MAPPlicense" at the MATLAB/Octave prompt to see the license      %
%% for this software.                                                          %
%% Copyright (C) 2008-2013 Jaijeet Roychowdhury <jr@berkeley.edu>. All rights  %
%% reserved.                                                                   %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%





