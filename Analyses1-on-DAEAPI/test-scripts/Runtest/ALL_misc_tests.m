function out = ALL_misc_tests(first,last)
%Test script to run all miscellaneous tests
%Author: Jaijeet Roychowdhury <jr@berkeley.edu> 2011/sometime
% 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Type "help MAPPlicense" at the MATLAB/Octave prompt to see the license      %
%% for this software.                                                          %
%% Copyright (C) 2008-2013 Jaijeet Roychowdhury <jr@berkeley.edu>. All rights  %
%% reserved.                                                                   %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%






	i = 0;

	%%%%%%%%%%%%%%%%%%%%%%
	% misc
	%%%%%%%%%%%%%%%%%%%%%%
	% i = i+1; scriptnames{i} = 'run_connectCktsAtNodes_w_RLCseries';
	%i = i+1; scriptnames{i} = 'test_connectCktsAtNodes_w_RLCseries';
	i = i+1; scriptnames{i} = 'test_NR_gJsinglefunc(3)';

	if 0 == nargin
		last = length(scriptnames);
		first = 1;
	elseif 1 == nargin
		last = length(scriptnames);
	end

	out = {scriptnames{first:last}};

end
%end of doit
