function [ok, funcname] = test_vecvalder_log(n, m, tol)
%function [ok, funcname] = test_vecvalder_log(n, m, tol)
%
%run tests on vecvalder/log; compare with handcoded expectations.
%
%Both arguments are optional:
%   n: size of vecvalder vector to test (defaults to 10 if unspecified)
%   m: number of indep vars for derivatives (defaults to n+1 if unspecified)
%   tol: absolute tolerance for error check (defaults to 0 if unspecified)
%
%Return values:
%   ok: 1 if everything passes, 0 otherwise.
%   funcname: always set to 'log()'
%
%This function tests:
%   log(size_n_vecvalder_w_m_indep_vars)
%
%It uses vecvalder(), val() and jac(), which get tested as well.
%
%Author: JR, 2014/06/18

	if nargin < 1
		n = 10;
	end
	if nargin < 2
		m = n+1;
	end
	if nargin < 3
		tol = 0;
	end

	funcname = 'log()';
    ok = 1;

    % test log(size_n_vecvalder_w_m_indep_vars)
    oof = rand(n,1);
    oof2 = rand(n, m);
    vv = vecvalder(oof, oof2);
    vv2 = log(vv);
    v = val(vv2); J = jac(vv2);
    % if y = log(u), dy/dx = (1/u)*du_dx
    expected_v = log(oof);
    expected_J = (1./oof*ones(1, m)).*oof2;
    ok = ok && ~sum(v-expected_v); if ~(1==ok) return; end
    ok = ok && ~sum(sum(J-expected_J)); if ~(1==ok) return; end
end
