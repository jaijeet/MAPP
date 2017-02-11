function [ok, funcname] = test_vecvalder_vertcat(n, m, tol)
%function [ok, funcname] = test_vecvalder_vertcat(n, m, tol)
%
%run tests on vecvalder/vertcat; compare with handcoded expectations.
%
%Both arguments are optional:
%   n: size of vecvalder vectors to test (defaults to 10 if unspecified)
%   m: number of indep vars for derivatives (defaults to n+1 if unspecified)
%   tol: absolute tolerance for error check (defaults to 0 if unspecified)
%
%Return values:
%   ok: 1 if everything passes, 0 otherwise.
%   funcname: always set to 'vertcat()'
%
%This function tests:
%   [numeric_scalar; vecvalder_scalar; numeric_vector; vecvalder_vector]
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

	funcname = 'vertcat()';
    ok = 1;

    % test [numeric_scalar; vecvalder_scalar; numeric_vector; vecvalder_vector]
    u = rand(1,1);
    oof = rand(n,1); oof2 = rand(n,m);
    v = vecvalder(oof, oof2);
    w = rand(n,1);
    poof = rand(n,1); poof2 = rand(n,m);
    x = vecvalder(poof, poof2);

    h = [u; v; w; x];
    hv = val(h); hJ = jac(h);
    % if h(u) = vertcat(u), dh_dx = sec^2(u)*du_dx
    expected_hv = [u; oof; w; poof];
    expected_hJ = [zeros(1,m); oof2; zeros(n,m); poof2];
    ok = ok && (abs(sum(hv-expected_hv)) <= tol); 
    if ~(1==ok) 
        return; 
    end
    ok = ok && (abs(sum(sum(hJ-expected_hJ)))/m/n <= tol); 
    if ~(1==ok) 
        return; 
    end
end
