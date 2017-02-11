function update_ALL_DAEAPI_tests
% function run_ALL_DAEAPI_tests
% Author: Tianshi Wang 2012-11-20
% 
	more off;
        isOctave = exist('OCTAVE_VERSION') ~= 0;
        if 1 == isOctave
                warning ('off','Octave:deprecated-function');
                warning('off','Octave:function-name-clash');
                warning('off','Octave:matlab-incompatible');
		warning('off','Octave:possible-matlab-short-circuit-operator');
		do_braindead_shortcircuit_evaluation(1);
        end

	i = 0;
	i = i+1; testnames{i} = 'test_BJTdiffpair_DAEAPIv6(''update'')';
	i = i+1; testnames{i} = 'test_BJTdiffpairRelaxationOsc(''update'')';
	i = i+1; testnames{i} = 'test_BJTdiffpairSchmittTrigger(''update'')';
	i = i+1; testnames{i} = 'test_circadianOsc_Drosophila(''update'')';
	i = i+1; testnames{i} = 'test_diodeCapIsrc_daeAPIv6(''update'')';
	i = i+1; testnames{i} = 'test_fullWaveRectifier_DAEAPIv6(''update'')';
	i = i+1; testnames{i} = 'test_parallelLC(''update'')';
	i = i+1; testnames{i} = 'test_MNAEqnEngine_cap(''update'')';
	i = i+1; testnames{i} = 'test_MNAEqnEngine_ind(''update'')';;
	i = i+1; testnames{i} = 'test_MNAEqnEngine_isrc(''update'')';
	i = i+1; testnames{i} = 'test_MNAEqnEngine_res(''update'')';
	i = i+1; testnames{i} = 'test_MNAEqnEngine_series_diodes(''update'')';
	i = i+1; testnames{i} = 'test_MNAEqnEngine_vsrc(''update'')';
	i = i+1; testnames{i} = 'test_BSIM3_ringosc(''update'')';

	runthem(testnames, 1, length(testnames));

end % run_ALL_DAEAPI_tests

function runthem(testnames, first, last)
	T = 2;
	runthemtimer = tic;
	%matlabpool; % set up parallel matlab jobs on multiple CPUs
	%poolsize = matlabpool('size');
	for scriptnum = last:-1:first;
	%parfor scriptnum = first:last;
		i = last-(scriptnum-first);
		scriptname = testnames{i};
		fprintf(2,'running script %d: %s...\n', i, scriptname);
		pause off;
		run_eval(scriptname); 
		pause on;
		fprintf(2,'\n%s (script %d) done\n', scriptname, i);
		%if scriptnum < length(testnames)
			fprintf(2,'Pausing for %g seconds...\n', T);
			fprintf(2,'--------------------------------------------------------------------------\n\n', T);
			pause(T);
			close all; drawnow;
		%end
	end
	%matlabpool close;
	elapsedtime = toc(runthemtimer);
	%fprintf(2,'\ntime taken for run_ALL (using %d processors): %g\n', ...
	%	poolsize, elapsedtime);
	fprintf(2,'\ntime taken for run_ALL: %g\n', elapsedtime);
        isOctave = exist('OCTAVE_VERSION') ~= 0;
        if 1 == isOctave
                %clear -f; % clears functions. If we don't do this,
                        % running this script again results in a strange
                        % error in vecvalder.times
        end
	clear;
end
%end of runit

function run_eval(the_command)
% so that parfor works in runthem, above
	eval(the_command);
end


