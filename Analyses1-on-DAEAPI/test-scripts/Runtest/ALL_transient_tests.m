function out = ALL_transient_tests(first,last)
%Test script to run all transient tests on various DAEs
%Author: Jaijeet Roychowdhury <jr@berkeley.edu> 2011/sometime
% 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Type "help MAPPlicense" at the MATLAB/Octave prompt to see the license      %
%% for this software.                                                          %
%% Copyright (C) 2008-2013 Jaijeet Roychowdhury <jr@berkeley.edu>. All rights  %
%% reserved.                                                                   %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%






	i = 0;
        
        % Access to default LMS parms
        LMStranparms = defaultTranParms();
	%%%%%%%%%%%%%%%%%%%%%%
	% transient
	%%%%%%%%%%%%%%%%%%%%%%
	i = i+1; scriptnames{i} = 'run_parallelRLCdiode_transient';
	i = i+1; scriptnames{i} = 'run_BJTdiffpair_transient';
	% i = i+1; scriptnames{i} = 'run_BJTdiffpair_newnetlistformat_DCop_AC_transient';
	% i = i+1; scriptnames{i} = 'run_fullWaveRectifier_transient';
	% i = i+1; scriptnames{i} = 'run_inverterchain_transient';
	i = i+1; scriptnames{i} = 'run_inverter_transient';
	i = i+1; scriptnames{i} = 'run_RCline_transient';
	i = i+1; scriptnames{i} = 'run_UltraSimplePLL_transient';
	% i = i+1; scriptnames{i} = 'run_tworeactionchain_transient';
	% i = i+1; scriptnames{i} = 'run_threeStageRingOsc_QSS_transient';
	% i = i+1; scriptnames{i} = 'run_BJTschmittTrigger_transient';
	% i = i+1; scriptnames{i} = 'run_BJTdiffpairSchmittTrigger_transient';
	% i = i+1; scriptnames{i} = 'run_BJTdiffpairRelaxationOsc_transient';
	i = i+1; scriptnames{i} = 'test_MNAEqnEngine_resistive_divider_DC_tran';
	i = i+1; scriptnames{i} = 'test_MNAEqnEngine_vsrcRC_DC_AC_tran';
	i = i+1; scriptnames{i} = 'test_MNAEqnEngine_vsrcRCL_DC_AC_tran';
	i = i+1; scriptnames{i} = 'test_MNAEqnEngine_vsrc_diode_DC_AC_tran';
	% i = i+1; scriptnames{i} = 'test_SoloveichikABCosc_RRE_transient';
	% i = i+1; scriptnames{i} = 'test_SoloveichikABCoscStabilized_RRE_transient';
	% i = i+1; scriptnames{i} = 'test_AtoB_RRE_transient';
	% i = i+1; scriptnames{i} = 'test_connectCktsAtNodes_w_RLCseries_transient';
	% i = i+1; scriptnames{i} = 'test_MNAEqnEngine_SH_MOSdiffpair_DC_AC_tran';
	i = i+1; scriptnames{i} = 'test_BSIM3_ringosc_transient'; % uses vecvalder, takes rather long
%
	%%%%%%%%%%%%%%%%%%%%%%
	% AC
	%%%%%%%%%%%%%%%%%%%%%%
	%{
	i = i+1; scriptnames{i} = 'run_BJTdiffpair_AC';
	if 1 == isOctave
		fprintf(2,'skipping run_fullWaveRectifier_AC: octave runs out of memory trying to plot\n');
	else
		i = i+1; scriptnames{i} = 'run_fullWaveRectifier_AC';
	end
	i = i+1; scriptnames{i} = 'run_RCline_AC';
	%}

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
