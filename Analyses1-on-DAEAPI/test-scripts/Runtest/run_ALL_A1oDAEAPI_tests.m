function run_ALL_A1oDAEAPI_tests(scriptnames, first, last)
%function run_ALL_A1oDAEAPI_tests(testscripts, first,last)
% OR
%function run_ALL_A1oDAEAPI_tests('showtests')
%
%Run A1oDAEAPI tests (or list the tests, if the single argument is 'showtests').
%
%Arguments:
%
%- scriptnames: (optional) a cell array of test script names. 
%               Eg: scriptnames = ALL_DC_tests(). If absent or specified as
%               [], is set to ALL_DC_tests(), ALL_AC_tests(),
%               ALL_LTInoise_tests(), ALL_QSSsens_tests(), ALL_misc_tests()
%               and ALL_transient_tests().
%- first:       (optional) start from this test. Defaults to 1.
%- last:        (optional) end at this tests. Defaults to length(scriptnames).
% 
%
%
%Examples
%--------
% run_ALL_A1oDAEAPI_tests(); % simplest incarnation, runs all tests
% run_ALL_A1oDAEAPI_tests('showtests'); % list all tests (do not run them)
%
% % run only a few tests
% pretty_print_cell(ALL_transient_tests()); % names of the transient tests
% run_ALL_A1oDAEAPI_tests(ALL_transient_tests(), 2, 3); 
%
%
%See also
%--------
%
% pretty_print_cell, run_AoDAEAPI_tests, ALL_DC_tests, ALL_transient_tests, 
% ALL_AC_tests, run_ALL_ModSpec_tests, run_ALL_vecvalder_tests,
% run_ALL_DAEAPI_tests
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Type "help MAPPlicense" at the MATLAB/Octave prompt to see the license      %
%% for this software.                                                          %
%% Copyright (C) 2008-2013 Jaijeet Roychowdhury <jr@berkeley.edu>. All rights  %
%% reserved.                                                                   %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%



	showtests = 0;
	if 1 == nargin && ischar(scriptnames) && ...
					strcmp('showtests', scriptnames)
		showtests = 1;
	end

	if 0 == nargin || isempty(scriptnames) || 1 == showtests
		scriptnames = {};
		oof = ALL_DC_tests();
		scriptnames = {scriptnames{:}, oof{:}};
		oof = ALL_AC_tests();
		scriptnames = {scriptnames{:}, oof{:}};
		% oof = ALL_LTInoise_tests();
		% scriptnames = {scriptnames{:}, oof{:}};
		% oof = ALL_QSSsens_tests();
		% scriptnames = {scriptnames{:}, oof{:}};
		% oof = ALL_misc_tests();
		% scriptnames = {scriptnames{:}, oof{:}};
		oof = ALL_transient_tests();
		scriptnames = {scriptnames{:}, oof{:}};
		oof = ALL_ArcCont_tests();
		scriptnames = {scriptnames{:}, oof{:}};
	end

	if 1 == showtests
		pretty_print_cell(scriptnames);
		return;
	end


	if 0 == nargin || 1 == nargin
		first = 1;
		last = length(scriptnames);
	elseif 2 == nargin
		last = length(scriptnames);
	end
	run_AoDAEAPI_tests(scriptnames, first, last);
end
