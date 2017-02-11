function [ok, funcname] = test_vecvalder_uplus(n, m, tol)
%function [ok, funcname] = test_vecvalder_uplus(n, m, tol)
%
%run tests on vecvalder/uplus; compare with handcoded expectations.
%
%Both arguments are optional:
%   n: size of vecvalder vector to test (defaults to 10 if unspecified)
%   m: number of indep vars for derivatives (defaults to n+1 if unspecified)
%   tol: absolute tolerance for error check (defaults to 0 if unspecified)
%
%Return values:
%   ok: 1 if everything passes, 0 otherwise.
%   funcname: always set to 'uplus()'
%
%This function tests:
%   +vv_n_by_m 
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

	funcname = 'uminus()';
    ok = 1;

    % test -vv_n_by_m
    oof = rand(n,1); oof2 = rand(n, m);
    u = vecvalder(oof, oof2);
    h = +u;
    hv = val(h); hJ = jac(h);
    % if y = log(u), dy/dx = (1/u)*du_dx
    expected_hv = oof;
    expected_hJ = oof2;
    ok = ok && ~sum(hv-expected_hv); if ~(1==ok) return; end
    ok = ok && ~sum(sum(hJ-expected_hJ)); if ~(1==ok) return; end
end
