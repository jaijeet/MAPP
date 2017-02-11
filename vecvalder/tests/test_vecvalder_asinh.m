function [ok, funcname] = test_vecvalder_asinh(n, m, tol)
%function [ok, funcname] = test_vecvalder_asinh(n, m, tol)
%
%run tests on vecvalder/asinh; compare with handcoded expectations.
%
%Both arguments are optional:
%   n: size of vecvalder vector to test (defaults to 10 if unspecified)
%   m: number of indep vars for derivatives (defaults to n+1 if unspecified)
%   tol: absolute tolerance for error check (defaults to 1e-15 if unspecified)
%
%Return values:
%   ok: 1 if everything passes, 0 otherwise.
%   funcname: always set to 'asinh()'
%
%This function tests:
%   asinh(vecvalder_n_by_m)
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
		tol = 1e-15;
	end

	funcname = 'asinh()';
    ok = 1;

    % test asinh(vecvalder_n_by_m)
    oof = rand(n,1); oof2 = rand(n, m);
    u = vecvalder(oof, oof2);
    h = asinh(u);
    hv = val(h); hJ = jac(h);
    % if h(u) = asinh(u), dh_dx = 1/sqrt(1+u^2)*du_dx
    expected_hv = asinh(oof);
    expected_hJ = (1./sqrt(1+oof.^2)*ones(1,m)).*oof2;
    ok = ok && (max(abs(hv-expected_hv)) <= tol); 
    if ~(1==ok) 
        fprintf(2, 'vv2 asinh: avg val error = %g', full(max(abs(hv-expected_hv))));
        return; 
    end
    ok = ok && (max(max(abs(hJ-expected_hJ)))/m/n <= tol); 
    if ~(1==ok) 
        fprintf(2, 'vv2 asinh: avg jac error = %g', ...
                                    full(max(max(abs(hJ-expected_hJ))))/m/n );
        return; 
    end
end
