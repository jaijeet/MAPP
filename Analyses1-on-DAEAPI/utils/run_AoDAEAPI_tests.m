function run_AoDAEAPI_tests(scriptnames, first, last)
%function run_AoDAEAPI_tests(scriptnames, first, last)
% runs A1o and A2o DAEAPI tests
	if 1 == nargin
		last = length(scriptnames);
		first = 1;
	elseif 2 == nargin
		last = length(scriptnames);
	end

	global isOctave;
	ntests = length(scriptnames);

	T = 5;
	PARALLEL=0;
	more off;
	if 0 == isOctave
		runthemtimer = tic;
	else
		tic;
	end
	if 1 == PARALLEL
		feature('NumCores')
		matlabpool; % set up parallel matlab jobs on multiple CPUs
		poolsize = matlabpool('size');
	end
	%for scriptnum = last:-1:first
	%parfor scriptnum = first:last % parfor downgrades to regular for 
	%                   if no matlabpool? not in MATLAB r2013b
	for scriptnum = first:last % parfor downgrades to regular for if no matlabpool
		i = scriptnum; 
		% i = last-(scriptnum-first); % run in reverse order
		scriptname = scriptnames{i};
		fprintf(2,'running script %d/%d: %s...\n', i, ntests, scriptname);
		if 0 == isOctave
			pause off;
		end
		run_eval(scriptname); 
		if 0 == isOctave
			pause on;
		end
		fprintf(2,'\n%s (script %d/%d) done\n', scriptname, i, ntests);
		%if scriptnum < length(scriptnames)
			fprintf(2,'Pausing for %g seconds...\n', T);
			fprintf(2,'-------------------------------------------------------------------------\n\n');
			pause(T);
			close all; drawnow;
		%end
	end
	if 1 == PARALLEL
		matlabpool close;
	end
	if 0 == isOctave
		elapsedtime = toc(runthemtimer);
	else
		elapsedtime = toc;
	end
	if 1 == PARALLEL
		fprintf(2,'\ntime taken (using %d processors): %g\n', poolsize, elapsedtime);
	else
		fprintf(2,'\ntime taken: %g\n', elapsedtime);
	end
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
