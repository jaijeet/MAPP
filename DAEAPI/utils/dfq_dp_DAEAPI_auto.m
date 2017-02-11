function [dfdp, dqdp] = dfq_dp_DAEAPI_auto(x, u, parmObj, f_q_or_fq, DAE)
%function [dfdp, dqdp] = dfq_dp_DAEAPI_auto(x, u, parmObj, f_q_or_fq, DAE)
%This function computes the derivatives of f and/or q with respect to
%parameters using vecvalder.
%INPUT args:
%   x           - vector of size DAE.nunks 
%   u           - vector of size DAE.ninputs (or [] if DAE.f_takes_inputs == 0)
%	parmObj     - an object produced by Parameters(DAE). Or [] to differentiate wrt all parms.
%	f_q_or_fq   - a string: 'f', 'q' or 'fq'
%	DAE         - a DAE object
%
%OUTPUTs:
%   dfdp        - df_dp(x,u)
%   dqdp        - dq_dp(x,u)
%

	% run some basic checks
	if nargin < 5
		error('dfq_dp_auto: needs 5 arguments');
		return;
	end

	if ~isa(DAE, 'struct')
		error('dfq_dp_auto: 5th argument DAE is not a structure');
		return;
	end

	if ~isa(f_q_or_fq, 'char')
		error('dfq_dp_auto: 4th argument f_q_or_fq is not a string');
		return;
	elseif ~(strcmp(f_q_or_fq, 'f') || strcmp(f_q_or_fq, 'q') || strcmp(f_q_or_fq, 'fq'))
		error('dfq_dp_auto: 4th argument f_q_or_fq is ''f'', ''q'' or ''fq''');
		return;
	end

	if (~isa(parmObj, 'struct')) && (~isempty(parmObj))
		error('dfq_dp_auto: 3rd argument parmObj is neither empty nor a structure');
		return;
	end

    %{
    for Octave not to complain
	if 2 ~= exist('vecvalder', 'file') && 6 ~= exist('vecvalder', 'file')
		fprintf(2,'df_dp: vecvalder (needed for computing df/dp) not found - aborting');
		dfdp = [];
		dqdp = [];
		return;
	end
    %}

	if isempty(parmObj)
		nparms = feval(DAE.nparms, DAE);
		parmIndices = 1:nparms;
		parmnames = feval(DAE.parmnames, DAE);
		%parmObj = Parameters(DAE);
	else
		parmIndices = feval(parmObj.ParmIndices, parmObj);
		nparms = length(parmIndices);
		parmnames = feval(parmObj.ParmNames, parmObj);
	end

	cparms = feval(DAE.getparms, DAE); % parms in cell array
	cparms = {cparms{parmIndices}}; % thin down to parameters of interest
	dparms = cell2mat(cparms); % parms as doubles
	if nparms ~= size(dparms,2)
		error('dfq_dp_auto: weird internal error: nparms ~= length of parms vector.'); 
	end
	parms = vecvalder(dparms.', speye(nparms)); % single vecvalder
	vvcparms = parms{1:nparms}; % cell array of parms as vecvalders
	DAE = feval(DAE.setparms, parmnames, vvcparms, DAE); % selected parms now set to vecvalders

	neqns = feval(DAE.neqns, DAE);
	if strfind(f_q_or_fq, 'f')
		if 0 == DAE.f_takes_inputs
			vvf_of_x = feval(DAE.f, x, DAE); % vv because parms are vvs
		else
			ninps = feval(DAE.ninputs, DAE);
			if length(u) ~= ninps
				error('dfq_dp_auto: argument u is not of the right size for f(x, u, DAE)');
				return;
			end
			vvf_of_x = feval(DAE.f, x, u, DAE);
		end

		dfdp = der2mat(vvf_of_x);

		if size(dfdp,1) < neqns || size(dfdp,2) < nparms
			dfdp(neqns,nparms) = 0;
		end
	else
		dfdp = [];
	end

	if strfind(f_q_or_fq, 'q')
		vvq_of_x = feval(DAE.q, x, DAE);

		dqdp = der2mat(vvq_of_x);

		if size(dqdp,1) < neqns || size(dqdp,2) < nparms
			dqdp(neqns,nparms) = 0;
		end
	else
		dqdp = [];
	end 
end
