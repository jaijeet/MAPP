function [ok, funcname] = test_vecvalder_ge(n, m, tol)
%function [ok, funcname] = test_vecvalder_ge(n, m, tol)
%
%run tests on vecvalder/ge; compare with handcoded expectations.
%
%Both arguments are optional:
%   n: size of vecvalder vector to test (defaults to 10 if unspecified)
%   m: number of indep vars for derivatives (defaults to n+1 if unspecified)
%   tol: absolute tolerance for error check (defaults to 0 if unspecified)
%
%Return values:
%   ok: 1 if everything passes, 0 otherwise.
%   funcname: always set to 'ge()'
%
%This function tests:
%   numeric_n >= vecvalder_n_by_m
%   vecvalder_n_by_m >= numeric_n
%   vecvalder_n_by_m >= vecvalder_n_by_m
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

	funcname = 'ge()';
    ok = 1;


    % test numeric_n > vecvalder_n_by_m
    u = randn(n,1); % numeric
    oof = randn(n,1); oof2 = randn(n, m);
    v = vecvalder(oof, oof2);
    h = (u >= v);
    expected_h = (u >= oof);
    ok = ok && (abs(sum(h-expected_h)) <= tol); 
    h = (oof >= v);
    expected_h = (oof >= oof);
    ok = ok && (abs(sum(h-expected_h)) <= tol); 
    if ~(1==ok) 
        return; 
    end

    % test vecvalder_n_by_m == numeric_n
    oof = randn(n,1); oof2 = randn(n, m);
    u = vecvalder(oof, oof2);
    v = randn(n,1); % numeric
    h = (u >= v);
    expected_h = (oof >= v);
    ok = ok && (abs(sum(h-expected_h)) <= tol); 
    h = (oof >= u);
    expected_h = (oof >= oof);
    ok = ok && (abs(sum(h-expected_h)) <= tol); 
    if ~(1==ok) 
        return; 
    end

    % test vecvalder_n_by_m == vecvalder_n_by_m 
    oof = randn(n,1); oof2 = randn(n, m);
    u = vecvalder(oof, oof2);
    poof = randn(n,1); poof2 = randn(n, m);
    v = vecvalder(poof, poof2);
    h = (u >= v);
    expected_h = (oof >= poof);
    ok = ok && (abs(sum(h-expected_h)) <= tol); 
    h = (u >= u);
    expected_h = (oof >= oof);
    ok = ok && (abs(sum(h-expected_h)) <= tol); 
    if ~(1==ok) 
        return; 
    end
end
