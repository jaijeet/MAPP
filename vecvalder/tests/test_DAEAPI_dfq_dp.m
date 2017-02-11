function [ok, funcname, vv_df_dp, vv_dq_dp] = test_DAEAPI_dfq_dp(DAEnamestr, tol, x, u, parmObj)
%function [ok, funcname, df_dp, dq_dp] = test_DAEAPI_dfq_dp(DAEnamestr, tol=1e-13, x=rand(1), u=rand(1), parmObj=[])
% updated to DAEAPI_v6.2
	if nargin < 1
		help('test_DAEAPI_dfq_dp');
		ok=0; funcname='';
		return;
	end

%try
	funcname = sprintf('d(f/q)/dparms (NO CHECKS) of %s ', DAEnamestr);
	DAE = eval(DAEnamestr);
	nunks = feval(DAE.nunks, DAE);
	neqns = feval(DAE.neqns, DAE);

	if nargin < 5 || 0 == length(parmObj)
		nparms = feval(DAE.nparms, DAE);
		parmIndices = 1:nparms;
		parmnames = feval(DAE.parmnames, DAE);
	else
		parmIndices = feval(parmObj.ParmIndices, parmObj);
		nparms = length(parmIndices);
		parmnames = feval(parmObj.ParmNames, parmObj);
	end
	ninputs = feval(DAE.ninputs, DAE);

	if 0 == nparms % no parameters to do derivatives wrt
		fprintf(2,'\t%s: nparms = 0, not evaluating parm derivatives\n',  funcname);
		ok = 1;
		vv_df_dp = [];
		vv_dq_dp = [];
		return;
	end

	if nargin < 2 || length(tol) < 1
		tol = 1e-13;
	end

	if nargin < 3 || 0 == length(x) % x can be []
		A = 1;
		x = A*(-1 + 2*rand(nunks,1)); % [-A , +A], random
		%fprintf(2,'setting x to rand()\n');
	end

	if nargin >= 3 && length(x) == 1 && 1 ~= nunks % scalar x, just use as A
		A = x;
		x = A*(-1 + 2*rand(nunks,1)); % [-A , +A], random
		%fprintf(2,'setting x to rand()\n');
	end

	if (nargin < 4 && ninputs > 0) || 0 == length(u)
		A = 1;
		u = A*(-1 + 2*rand(ninputs,1)); % [-A , +A], random
		%fprintf(2,'setting u to rand()\n');
	end

	if nargin >= 4 && length(u) == 1 && 1 ~= ninputs % scalar u, just use as A
		A = u;
		u = A*(-1 + 2*rand(nunks,1)); % [-A , +A], random
		%fprintf(2,'setting u to rand()\n');
	end

	cparms = feval(DAE.getparms, DAE);
	cparms = {cparms{parmIndices}}; % thin down to parameters of interest
	dparms = cell2mat(cparms);
	if nparms ~= size(dparms,2)
		error('test_DAEAPI_parm_derivatives: nparms ~= length of parms vector.'); 
	end
	parms = vecvalder(dparms.', speye(nparms)); % single vecvalder
	vvcparms = parms{1:nparms}; % cell array of parms as vecvalders

	DAE = feval(DAE.setparms, parmnames, vvcparms, DAE); % selected parms now set to vecvalders

	if 0 == DAE.f_takes_inputs
		vvf_of_x = feval(DAE.f, x, DAE); % vv because parms are vvs
	else
		vvf_of_x = feval(DAE.f, x, u, DAE);
	end

	vv_f = val2mat(vvf_of_x);
	vv_df_dp = der2mat(vvf_of_x);
	if size(vv_df_dp,1) < neqns || size(vv_df_dp,2) < nparms
		vv_df_dp(neqns,nparms) = 0;
	end

	ok = 1;

	vvq_of_x = feval(DAE.q, x, DAE);
	vv_q = val2mat(vvq_of_x);
	vv_dq_dp = der2mat(vvq_of_x);

	if size(vv_dq_dp,1) < neqns || size(vv_dq_dp,2) < nparms
		vv_dq_dp(neqns,nparms) = 0;
	end

	ok = 1; % no reference to check against, yet
%catch
%	ok = 0; % some kind of failure
%end% of try/catch

end% of function

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Type "help MAPPlicense" at the MATLAB/Octave prompt to see the license      %
%% for this software.                                                          %
%% Copyright (C) 2008-2013 Jaijeet Roychowdhury <jr@berkeley.edu>. All rights  %
%% reserved.                                                                   %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
