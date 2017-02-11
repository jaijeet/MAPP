function compare_MNAEqnEngine_w_older(DAE)
%function compare_MNAEqnEngine_w_older(DAE_from_MNAEqnEngine)
%use this to test MNA_EqnEngine's core and derivative functions against MNA_EqnEngine_older's.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Type "help MAPPlicense" at the MATLAB/Octave prompt to see the license      %
%% for this software.                                                          %
%% Copyright (C) 2008-2013 Jaijeet Roychowdhury <jr@berkeley.edu>. All rights  %
%% reserved.                                                                   %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%





circuitdata = DAE.circuitdata;
DAE_older = MNA_EqnEngine_older(circuitdata);

N = 10; % number of trials
format long e;
for i=1:N
	fprintf(2, '------ start trial %d ------\n', i);
	x = randn(DAE.n_unks, 1);
	u = randn(DAE.n_inputs, 1);

	f = feval(DAE.f, x, u, DAE);
	f_older = feval(DAE_older.f, x, u, DAE_older);

	dfdx = feval(DAE.df_dx, x, u, DAE);
	dfdx_older = feval(DAE_older.df_dx, x, u, DAE_older);

	[dfdx_is, dfdx_js] = find(dfdx);
	[dfdx_older_is, dfdx_older_js] = find(dfdx_older);

	dfdu = feval(DAE.df_du, x, u, DAE);
	dfdu_older = feval(DAE_older.df_du, x, u, DAE_older);

	[dfdu_is, dfdu_js] = find(dfdu);
	[dfdu_older_is, dfdu_older_js] = find(dfdu_older);


	q = feval(DAE.q, x, DAE);
	q_older = feval(DAE_older.q, x, DAE_older);

	dqdx = feval(DAE.dq_dx, x, DAE);
	dqdx_older = feval(DAE_older.dq_dx, x, DAE_older);

	[dqdx_is, dqdx_js] = find(dqdx);
	[dqdx_older_is, dqdx_older_js] = find(dqdx_older);

	if 0 == max(abs(f-f_older))
		fprintf(2, 'f-f_older == 0\n');
	else
		
		fprintf(2, 'abs(f-f_older):');
		abs(f-f_older)
	end


	if 0 == max(max(abs(dfdx-dfdx_older)))
		fprintf(2, 'Jfx-Jfx_older == 0\n');
	else
		
		fprintf(2, 'abs(Jfx-Jfx_older):');
		abs(dfdx-dfdx_older)
	end

	if length(dfdx_is) == length(dfdx_older_is) && 0 == max(max(abs(dfdx_is-dfdx_older_is))) ...
	   && length(dfdx_js) == length(dfdx_older_js) && 0 == max(max(abs(dfdx_js-dfdx_older_js)))
		fprintf(2, 'sparsity patterns of Jfx and Jfx_older are identical\n');
	else
		fprintf(2, 'sparsity patterns of Jfx and Jfx_older differ:\n');
		dfdx_is
		dfdx_older_is
		dfdx_js
		dfdx_older_js
	end

	if 0 == max(max(abs(dfdu-dfdu_older)))
		fprintf(2, 'Jfu-Jfu_older == 0\n');
	else
		
		fprintf(2, 'abs(Jfu-Jfu_older):');
		abs(dfdu-dfdu_older)
	end

	if length(dfdu_is) == length(dfdu_older_is) && 0 == max(max(abs(dfdu_is-dfdu_older_is))) ...
	   && length(dfdu_js) == length(dfdu_older_js) && 0 == max(max(abs(dfdu_js-dfdu_older_js)))
		fprintf(2, 'sparsity patterns of Jfu and Jfu_older are identical\n');
	else
		fprintf(2, 'sparsity patterns of Jfu and Jfu_older differ:\n');
		dfdu_is
		dfdu_older_is
		dfdu_js
		dfdu_older_js
	end

	if 0 == max(abs(q-q_older))
		fprintf(2, 'q-q_older == 0\n');
	else
		
		fprintf(2, 'abs(q-q_older):');
		abs(q-q_older)
	end

	if 0 == max(max(abs(dqdx-dqdx_older)))
		fprintf(2, 'Jqx-Jqx_older == 0\n');
	else
		
		fprintf(2, 'abs(Jqx-Jqx_older):');
		abs(dqdx-dqdx_older)
	end

	if length(dqdx_is) == length(dqdx_older_is) && 0 == max(max(abs(dqdx_is-dqdx_older_is))) ...
	   && length(dqdx_js) == length(dqdx_older_js) && 0 == max(max(abs(dqdx_js-dqdx_older_js)))
		fprintf(2, 'sparsity patterns of Jqx and Jqx_older are identical\n');
	else
		fprintf(2, 'sparsity patterns of Jqx and Jqx_older differ:\n');
		dqdx_is
		dqdx_older_is
		dqdx_js
		dqdx_older_js
	end
	fprintf(2, '------ end of trial %d ------\n', i);
end
