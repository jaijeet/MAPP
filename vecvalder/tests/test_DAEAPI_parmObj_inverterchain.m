function [ok, funcname, df_dp, dq_dp] = test_DAEAPI_parmObj_inverterchain()
%function [ok, funcname, df_dp, dq_dp] = test_DAEAPI_parmObj_inverterchain()
% updated to DAEAPI_v6.2

	isOctave = exist('OCTAVE_VERSION') ~= 0;
	if 1 == isOctave
		warning ('off','Octave:deprecated-function'); 
		warning('off','Octave:function-name-clash');
		warning('off','Octave:matlab-incompatible');
	end

	DAE = inverterchain_DAEAPIv6_old('a',5);
	pobj = Parameters(DAE);
	pobj = feval(pobj.Delete, {'VDD1', 'CL2', 'VDD4', 'RdsN5', 'RdsP1'},...
			pobj);

	ok = test_DAEAPI_dfq_dp('inverterchain_DAEAPIv6_old(''a'',5)', [], [], [], pobj);

	funcname = 'd(f/q)/dparms (NO CHECKS) with selected parm subset (for inverterchain_DAEAPIv6_old(''a'',5))';

	if 1 == isOctave
		clear -f; % clears functions. If we don't do this,
			% running this script again results in a strange
			% error in vecvalder.times
	end
end% of function

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Type "help MAPPlicense" at the MATLAB/Octave prompt to see the license      %
%% for this software.                                                          %
%% Copyright (C) 2008-2013 Jaijeet Roychowdhury <jr@berkeley.edu>. All rights  %
%% reserved.                                                                   %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%





