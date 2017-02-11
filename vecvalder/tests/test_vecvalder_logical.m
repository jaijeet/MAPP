function [ok, funcname] = test_vecvalder_logical(n, m, tol)
%function [ok, funcname] = test_vecvalder_logical(n, m, tol)
%
%run tests on vecvalder/logical; compare with handcoded expectations.
%
%Both arguments are optional:
%   n: size of vecvalder vector to test (defaults to 10 if unspecified)
%   m: number of indep vars for derivatives (defaults to n+1 if unspecified)
%   tol: absolute tolerance for error check (defaults to 0 if unspecified)
%
%Return values:
%   ok: 1 if everything passes, 0 otherwise.
%   funcname: always set to 'logical()'
%
%This function tests:
%   logical(vecvalder_n_by_m)
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

	funcname = 'logical()';
    ok = 1;

    % test logical(vecvalder_n_by_m)
    oof = randn(n,1); oof2 = randn(n, m);
    u = vecvalder(oof, oof2);
    h = logical(u);
    expected_h = logical(oof);
    ok = ok && (abs(sum(h-expected_h)) <= tol); 
    if ~(1==ok) 
        fprintf(2, 'vv2 logical: avg val error = %g', full(abs(sum(h-expected_h)))/n);
        return; 
    end
end
