function success = run_ALL_ModSpec_tests
%function success = run_ALL_ModSpec_tests
% Script to run all ModSpec tests
% Author: Tianshi Wang 2012-11-19
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
	i = i+1; testnames{i} = 'test_resModSpec';
	i = i+1; testnames{i} = 'test_capModSpec';
	i = i+1; testnames{i} = 'test_indModSpec';
	i = i+1; testnames{i} = 'test_vsrcModSpec';
	i = i+1; testnames{i} = 'test_vcvsModSpec';
	i = i+1; testnames{i} = 'test_vccsModSpec';
	i = i+1; testnames{i} = 'test_ccvsModSpec';
	i = i+1; testnames{i} = 'test_cccsModSpec';
	i = i+1; testnames{i} = 'test_diodeModSpec';
	i = i+1; testnames{i} = 'test_isrcModSpec';
	i = i+1; testnames{i} = 'test_EbersMoll_BJT_ModSpec';
	i = i+1; testnames{i} = 'test_SH_MOS_ModSpec';
	i = i+1; testnames{i} = 'test_MVS_1_0_1_ModSpec_wrapper';
	i = i+1; testnames{i} = 'test_MVS_1_0_1_ModSpec_wrapper_no_v2struct';

	success = runthem(testnames, 1, length(testnames));

end % run_ALL_ModSpec_tests

function success = runthem(testnames, first, last)
    success = 1;
	T = 2;
	global isOctave;
	if 0 == isOctave
		runthemtimer = tic;
	else
		tic;
	end
	%matlabpool; % set up parallel matlab jobs on multiple CPUs
	%poolsize = matlabpool('size');
	for scriptnum = last:-1:first;
	%parfor scriptnum = first:last;
		i = last-(scriptnum-first);
		scriptname = testnames{i};
		fprintf(2,'running script %d: %s...\n', i, scriptname);
		global isOctave;
		if 0 == isOctave
			pause off;
		end
		ok = run_eval(scriptname); 
		if 0 == ok
			success = 0;
		end
		if 0 == isOctave
			pause on;
		end
		fprintf(2,'\n%s (script %d) done\n', scriptname, i);
		%if scriptnum < length(testnames)
			fprintf(2,'Pausing for %g seconds...\n', T);
			fprintf(2,'--------------------------------------------------------------------------\n\n', T);
			pause(T);
			close all; drawnow;
		%end
	end
	%matlabpool close;
	if 0 == isOctave
		elapsedtime = toc(runthemtimer);
	else
		elapsedtime = toc;
	end
	%fprintf(2,'\ntime taken for run_ALL (using %d processors): %g\n', ...
	%	poolsize, elapsedtime);
	fprintf(2,'\ntime taken for run_ALL_ModSpec_tests: %g\n', elapsedtime);
        isOctave = exist('OCTAVE_VERSION') ~= 0;
        if 1 == isOctave
                %clear -f; % clears functions. If we don't do this,
                        % running this script again results in a strange
                        % error in vecvalder.times
        end
end
%end of runit

function out = run_eval(the_command)
% so that parfor works in runthem, above
	out = eval(the_command);
end
