function run_ALL_A1oDAEAPI_tests(first,last)
% Test script to run all tests (old)
%Author: Jaijeet Roychowdhury <jr@berkeley.edu> 2011/sometime
% 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Type "help MAPPlicense" at the MATLAB/Octave prompt to see the license      %
%% for this software.                                                          %
%% Copyright (C) 2008-2013 Jaijeet Roychowdhury <jr@berkeley.edu>. All rights  %
%% reserved.                                                                   %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%






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
	i = i+1; scriptnames{i} = 'run_parallelRLCdiode_transient';
	i = i+1; scriptnames{i} = 'run_BJTdiffpair_DCsweep';
	i = i+1; scriptnames{i} = 'run_BJTdiffpair_AC';
	i = i+1; scriptnames{i} = 'run_BJTdiffpair_transient';
	i = i+1; scriptnames{i} = 'run_fullWaveRectifier_DCsweep';
	if 1 == isOctave
		fprintf(2,'skipping run_fullWaveRectifier_AC: octave runs out of memory trying to plot\n');
	else
		i = i+1; scriptnames{i} = 'run_fullWaveRectifier_AC';
	end
	i = i+1; scriptnames{i} = 'run_fullWaveRectifier_transient';
	i = i+1; scriptnames{i} = 'run_inverterchain_DCsweep';
	i = i+1; scriptnames{i} = 'run_inverterchain_transient';
	i = i+1; scriptnames{i} = 'run_inverterchain_QSSsens';
	i = i+1; scriptnames{i} = 'run_inverter_DCsweep';
	i = i+1; scriptnames{i} = 'run_inverter_transient';
	i = i+1; scriptnames{i} = 'run_RCline_AC';
	i = i+1; scriptnames{i} = 'run_RCline_LTInoise';
	i = i+1; scriptnames{i} = 'run_RCline_transient';
	i = i+1; scriptnames{i} = 'run_UltraSimplePLL_transient';
	i = i+1; scriptnames{i} = 'run_reducedRRE_DC';
	i = i+1; scriptnames{i} = 'run_reducedRRE_QSS';
	i = i+1; scriptnames{i} = 'run_tworeactionchain_transient';
	i = i+1; scriptnames{i} = 'run_threeStageRingOsc_QSS_transient';
	% i = i+1; scriptnames{i} = 'run_connectCktsAtNodes_w_RLCseries';
	i = i+1; scriptnames{i} = 'test_connectCktsAtNodes_w_RLCseries';
	i = i+1; scriptnames{i} = 'run_vsrc_xgate_res_QSS';
	i = i+1; scriptnames{i} = 'run_BJTschmittTrigger_DCsweep';
	i = i+1; scriptnames{i} = 'run_BJTschmittTrigger_transient';
	i = i+1; scriptnames{i} = 'run_BJTdiffpairSchmittTrigger_DCsweep';
	i = i+1; scriptnames{i} = 'run_BJTdiffpairSchmittTrigger_transient';
	i = i+1; scriptnames{i} = 'run_BJTdiffpairRelaxationOsc_transient';
	i = i+1; scriptnames{i} = 'test_MNAEqnEngine_resistive_divider_DC_tran';
	i = i+1; scriptnames{i} = 'test_MNAEqnEngine_vsrcRC_DC_tran';
	i = i+1; scriptnames{i} = 'test_MNAEqnEngine_vsrcRCL_DC_tran';
	i = i+1; scriptnames{i} = 'test_MNAEqnEngine_vsrc_diode_DC_tran';
	i = i+1; scriptnames{i} = 'test_MNAEqnEngine_DAAV6_char_curves';
	i = i+1; scriptnames{i} = 'test_MNAEqnEngine_DAAV6_ringosc_tran';
	i = i+1; scriptnames{i} = 'test_AtoB_RRE';
	i = i+1; scriptnames{i} = 'test_SoloveichikABCosc_RRE_transient';
	i = i+1; scriptnames{i} = 'test_SoloveichikABCoscStabilized_RRE_transient';
	i = i+1; scriptnames{i} = 'test_NR_gJsinglefunc(3)';
	i = i+1; scriptnames{i} = 'test_BSIM3_ringosc_transient'; % uses vecvalder, takes rather long


	if 0 == nargin
		last = length(scriptnames);
		first = 1;
	elseif 1 == nargin
		last = length(scriptnames);
	end
	runthem(scriptnames, first, last);

end
%end of doit

function runthem(scriptnames, first, last)
	T = 5;
	PARALLEL=0;
	runthemtimer = tic;
	if 1 == PARALLEL
		matlabpool; % set up parallel matlab jobs on multiple CPUs
		poolsize = matlabpool('size');
	end
	%for scriptnum = last:-1:first
	parfor scriptnum = first:last % parfor downgrades to regular for if no matlabpool
		i = last-(scriptnum-first);
		scriptname = scriptnames{i};
		fprintf(2,'running script %d: %s...\n', i, scriptname);
		pause off;
		run_eval(scriptname); 
		pause on;
		fprintf(2,'\n%s (script %d) done\n', scriptname, i);
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
	elapsedtime = toc(runthemtimer);
	if 1 == PARALLEL
		fprintf(2,'\ntime taken for run_ALL (using %d processors): %g\n', poolsize, elapsedtime);
	else
		fprintf(2,'\ntime taken for run_ALL: %g\n', elapsedtime);
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
