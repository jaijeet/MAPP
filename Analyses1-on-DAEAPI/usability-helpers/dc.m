function  QSSobj = dc(varargin)
%dc is a synonym for op. See op. 
%If you want to run a DC sweep analysis, use dcsweep or dcsweep2.
%
%See also
%--------
%
% op, dcsweep, dcsweep2, transient, ac, NR




%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Type "help MAPPlicense" at the MATLAB/Octave prompt to see the license      %
%% for this software.                                                          %
%% Copyright (C) 2008-2013 Jaijeet Roychowdhury <jr@berkeley.edu>. All rights  %
%% reserved.                                                                   %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%





	QSSobj = op(varargin{:});
end
