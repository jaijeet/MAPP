function [ok, funcname] = test_DAEAPI_dfq_dx(DAEnamestr, tol, x)
%function [ok, funcname] = test_DAEAPI_dfq_dx(DAEnamestr, tol, x)
% updated to DAEAPI_v6.2

	if nargin < 1
		help('test_DAEAPI_fq_derivatives');
		ok=0; funcname='';
		return;
	end

	funcname = sprintf('d(f/q)/dx of %s', DAEnamestr);
	DAE = eval(DAEnamestr);
	nunks = feval(DAE.nunks, DAE);
	neqns = feval(DAE.neqns, DAE);

	if nargin < 2 || length(tol) < 1
		tol = 1e-13;
	end

	if 3 == nargin && length(x) == 1 && 1 ~= nunks
		A = x;
		x = A*(-1 + 2*rand(nunks,1)); % [-A , +A], random
		%fprintf(2,'setting x to rand()\n');
	end

	if nargin < 3
		A = 1;
		x = A*(-1 + 2*rand(nunks,1)); % [-A , +A], random
		%fprintf(2,'setting x to rand()\n');
	end


	vvx = vecvalder(x, speye(nunks,nunks));

	if 0 == DAE.f_takes_inputs
		f_of_x = feval(DAE.f, x, DAE);
		df_dx = feval(DAE.df_dx, x, DAE);
		vvf_of_x = feval(DAE.f, vvx, DAE);
	else
		ninputs = feval(DAE.ninputs,DAE);
		if 1 == isa(DAE.uQSSvec, 'numeric')
			u = feval(DAE.uQSS, DAE);
		elseif 1 == isa(DAE.utfunc, 'function_handle')
			t = 0;
			u = feval(DAE.utransient, t, DAE);
		else
			u = zeros(ninputs,1);
		end
		f_of_x = feval(DAE.f, x, u, DAE);
		df_dx = feval(DAE.df_dx, x, u, DAE);
		vvf_of_x = feval(DAE.f, vvx, u, DAE);
		if ninputs > 0
			df_du = feval(DAE.df_du, x, u, DAE);
			vvu = vecvalder(u, speye(ninputs,ninputs));
			vvf_of_x_u = feval(DAE.f, x, vvu, DAE);
		end
	end

	vv_f = val2mat(vvf_of_x);
	vv_df_dx = der2mat(vvf_of_x);
	if size(vv_df_dx,1) < neqns || size(vv_df_dx,2) < nunks
		vv_df_dx(neqns,nunks) = 0;
	end

	ok = 1;

	f_err = norm(full(f_of_x - vv_f));
	df_dx_err = norm(full(df_dx - vv_df_dx));
	%full(df_dx)
	%full(vv_df_dx)

	ok = ok && (f_err < tol);
	ok = ok && (df_dx_err < tol);

	q_of_x = feval(DAE.q, x, DAE);
	dq_dx = feval(DAE.dq_dx, x, DAE);
	vvq_of_x = feval(DAE.q, vvx, DAE);

	vv_q = val2mat(vvq_of_x);
	vv_dq_dx = der2mat(vvq_of_x);
	if size(vv_dq_dx,1) < neqns || size(vv_dq_dx,2) < nunks
		vv_dq_dx(neqns,nunks) = 0;
	end


	q_err = norm(full(q_of_x - vv_q));
	dq_dx_err = norm(full(dq_dx - vv_dq_dx));


	ok = ok && (q_err < tol);
	ok = ok && (dq_dx_err < tol);

	if 1 == DAE.f_takes_inputs && ninputs > 0
		vv_df_du = der2mat(vvf_of_x_u);
			if size(vv_df_du,1) < neqns || size(vv_df_du,2) < ninputs
		vv_df_du(neqns,ninputs) = 0;
		end
		df_du_err = norm(full(df_du - vv_df_du));
		ok = ok && (df_du_err < tol);
	end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Type "help MAPPlicense" at the MATLAB/Octave prompt to see the license      %
%% for this software.                                                          %
%% Copyright (C) 2008-2013 Jaijeet Roychowdhury <jr@berkeley.edu>. All rights  %
%% reserved.                                                                   %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%





