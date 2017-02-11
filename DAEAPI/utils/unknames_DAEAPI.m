function out = unknames(DAE)
%function out = unknames(DAE)
%This function returns the unk names in a DAE.
%INPUT args:
%   DAE             - a DAE object
%
%OUTPUT:
%   out             - names of unks in the DAE (cell array)


%author: J. Roychowdhury, 2011/05/31
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Type "help MAPPlicense" at the MATLAB/Octave prompt to see the license      %
%% for this software.                                                          %
%% Copyright (C) 2008-2013 Jaijeet Roychowdhury <jr@berkeley.edu>. All rights  %
%% reserved.                                                                   %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%





	out = DAE.unknameList;
end
% end unknames
