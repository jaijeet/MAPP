function success = run_ALL_DAEAPI_tests(quiet)
%function success = run_ALL_DAEAPI_tests(quiet)
% Author: Tianshi Wang 2012-11-20
% 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Type "help MAPPlicense" at the MATLAB/Octave prompt to see the license      %
%% for this software.                                                          %
%% Copyright (C) 2008-2013 Jaijeet Roychowdhury <jr@berkeley.edu>. All rights  %
%% reserved.                                                                   %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    if nargin < 1 || isempty(quiet)
        quiet = 0;
    end

	more off;

	i = 0;
	i = i+1; testnames{i} = 'test_BJTdiffpair_DAEAPIv6';
	i = i+1; testnames{i} = 'test_BJTdiffpairRelaxationOsc';
	% i = i+1; testnames{i} = 'test_BJTdiffpairSchmittTrigger';
	i = i+1; testnames{i} = 'test_circadianOsc_Drosophila';
	i = i+1; testnames{i} = 'test_diodeCapIsrc_daeAPIv6';
	i = i+1; testnames{i} = 'test_fullWaveRectifier_DAEAPIv6';
	i = i+1; testnames{i} = 'test_parallelLC';
	i = i+1; testnames{i} = 'test_MNAEqnEngine_cap';
	i = i+1; testnames{i} = 'test_MNAEqnEngine_ind';
	i = i+1; testnames{i} = 'test_MNAEqnEngine_isrc';
	i = i+1; testnames{i} = 'test_MNAEqnEngine_res';
	i = i+1; testnames{i} = 'test_MNAEqnEngine_series_diodes';
	i = i+1; testnames{i} = 'test_MNAEqnEngine_vsrc';
	i = i+1; testnames{i} = 'test_BSIM3_ringosc';

	success = runthem(testnames, 1, length(testnames), quiet);

end % run_ALL_DAEAPI_tests

function success = runthem(testnames, first, last, quiet)
    if nargin < 4 || isempty(quiet)
        quiet = 0;
    end
    success = 1;
	T = 2;
	runthemtimer = tic;
	%matlabpool; % set up parallel matlab jobs on multiple CPUs
	%poolsize = matlabpool('size');
	for scriptnum = last:-1:first;
	%parfor scriptnum = first:last;
		i = last-(scriptnum-first);
		scriptname = testnames{i};
		if 0==quiet fprintf(2,'running script %d: %s...\n', i, scriptname); end
        global isOctave;
		if ~isOctave
            pause off;
        end
		ok = run_eval(scriptname); 
		if 0 == ok
			success = 0;
		end
		if ~isOctave
		    pause on;
        end
		if 0==quiet fprintf(2,'\n%s (script %d) done\n', scriptname, i); end
		%if scriptnum < length(testnames)
			if 0==quiet fprintf(2,'Pausing for %g seconds...\n', T); end
			if 0==quiet fprintf(2,'--------------------------------------------------------------------------\n\n', T); end
			pause(T);
			close all; drawnow;
		%end
	end
	%matlabpool close;
	elapsedtime = toc(runthemtimer);
	%fprintf(2,'\ntime taken for run_ALL (using %d processors): %g\n', ...
	%	poolsize, elapsedtime);
	if 0==quiet fprintf(2,'\ntime taken for run_ALL: %g\n', elapsedtime); end
end
%end of runthem

function out = run_eval(the_command)
% so that parfor works in runthem, above
	out = eval(the_command);
end
