function run_ALL_ArcCont_tests(first,last)
%function run_ALL_ArcCont_tests(first,last)
%
%runs all arc-length continuation tests (as defined in ALL_ArcCont_tests.m).
%
%first and last are optional indices (if you just want to run a subset of
%the tests).
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Type "help MAPPlicense" at the MATLAB/Octave prompt to see the license      %
%% for this software.                                                          %
%% Author: J. Roychowdhury, 2015/05/29                                         %
%% Copyright (C) 2008-2020 Jaijeet Roychowdhury <jr@berkeley.edu>. All rights  %
%%               reserved.                                                     %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

	scriptnames = {};
	    extrascriptnames = ALL_ArcCont_tests; % moved to A1oDAEAPI
	scriptnames = {scriptnames{:}, extrascriptnames{:}};
	if 0 == nargin
		last = length(scriptnames);
		first = 1;
	elseif 1 == nargin
		last = length(scriptnames);
	end
	run_AoDAEAPI_tests(scriptnames, first, last);

end
%end of doit
