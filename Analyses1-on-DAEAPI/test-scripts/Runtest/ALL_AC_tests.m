function out = ALL_AC_tests(first,last)
% Test script to run all AC tests
%Author: Jaijeet Roychowdhury <jr@berkeley.edu> 2011/sometime
% 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Type "help MAPPlicense" at the MATLAB/Octave prompt to see the license      %
%% for this software.                                                          %
%% Copyright (C) 2008-2013 Jaijeet Roychowdhury <jr@berkeley.edu>. All rights  %
%% reserved.                                                                   %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%






	i = 0;
        isOctave = exist('OCTAVE_VERSION') ~= 0;

	%%%%%%%%%%%%%%%%%%%%%%
	% AC
	%%%%%%%%%%%%%%%%%%%%%%
	i = i+1; scriptnames{i} = 'run_RCline_AC';
	i = i+1; scriptnames{i} = 'run_BJTdiffpair_AC';

	% i = i+1; scriptnames{i} = 'run_BJTdiffpair_AC';
	if 1 == isOctave
		fprintf(2,'skipping run_fullWaveRectifier_AC: octave runs out of memory trying to plot\n');
	else
		% i = i+1; scriptnames{i} = 'run_fullWaveRectifier_AC';
	end
	% i = i+1; scriptnames{i} = 'test_MNAEqnEngine_DAAV6_P_N_AC';

	%%%%%%%%%%%%%%%%%%%%%%
	% DCsens
	%%%%%%%%%%%%%%%%%%%%%%
	%{
	i = i+1; scriptnames{i} = 'run_inverterchain_QSSsens';
	%}


	%%%%%%%%%%%%%%%%%%%%%%
	% LTInoise
	%%%%%%%%%%%%%%%%%%%%%%
	%{
	i = i+1; scriptnames{i} = 'run_RCline_LTInoise';
	%}

	%%%%%%%%%%%%%%%%%%%%%%
	% misc
	%%%%%%%%%%%%%%%%%%%%%%
	%{
	% i = i+1; scriptnames{i} = 'run_connectCktsAtNodes_w_RLCseries';
	i = i+1; scriptnames{i} = 'test_connectCktsAtNodes_w_RLCseries';
	i = i+1; scriptnames{i} = 'test_NR_gJsinglefunc(3)';
	%}


	if 0 == nargin
		last = length(scriptnames);
		first = 1;
	elseif 1 == nargin
		last = length(scriptnames);
	end

	out = {scriptnames{first:last}};

end
%end of doit
