function [ok, funcname] = test_vecvalder_mtimes(n, m, tol)
%function [ok, funcname] = test_vecvalder_mtimes(n, m, tol)
%
%run tests on vecvalder/mtimes; compare with handcoded expectations.
%
%Both arguments are optional:
%   n: size of vecvalder vector to test (defaults to 10 if unspecified)
%   m: number of indep vars for derivatives (defaults to n+1 if unspecified)
%   tol: absolute tolerance for error check (defaults to 0 if unspecified)
%
%Return values:
%   ok: 1 if everything passes, 0 otherwise.
%   funcname: always set to 'mtimes()'
%
%This function tests:
%   numeric_n * vecvalder_scalar
%   vecvalder_scalar * numeric_n
%   vecvalder_n_by_m * numeric_scalar
%   numeric_scalar * vecvalder_n_by_m  
%   vecvalder_n_by_m * vecvalder_scalar
%   vecvalder_scalar * vecvalder_n_by_m
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

	funcname = 'mtimes()';
    ok = 1;

    % test numeric_n * vecvalder_scalar
    u = rand(n,1); % numeric
    oof = rand(1,1); oof2 = rand(1, m);
    v = vecvalder(oof, oof2);
    h = u*v;
    hv = val(h); hJ = jac(h);
    % if h(u,v) = u*v, dh_dx = v*du_dx + u*dv_dx
    expected_hv = u*oof;
    expected_hJ = u*oof2;
    ok = ok && (max(abs(hv-expected_hv)) <= tol); 
    if ~(1==ok) 
        return; 
    end
    ok = ok && (max(max(abs(hJ-expected_hJ))) <= tol); 
    if ~(1==ok) 
        return; 
    end

    % test vecvalder_scalar * numeric_n
    oof = rand(1,1); oof2 = rand(1, m);
    u = vecvalder(oof, oof2);
    v = rand(n,1); % numeric
    h = u*v;
    hv = val(h); hJ = jac(h);
    % if h(u,v) = u*v, dh_dx = v*du_dx + u*dv_dx
    expected_hv = oof*v;
    expected_hJ = v*oof2;
    ok = ok && (max(abs(hv-expected_hv)) <= tol); 
    if ~(1==ok) 
        return; 
    end
    ok = ok && (max(max(abs(hJ-expected_hJ))) <= tol); 
    if ~(1==ok) 
        return; 
    end

    % test vecvalder_n_by_m * numeric_scalar
    oof = rand(n,1); oof2 = rand(n, m);
    u = vecvalder(oof, oof2);
    v = rand(1,1); % numeric
    h = u*v;
    hv = val(h); hJ = jac(h);
    % if h(u,v) = u*v, dh_dx = v*du_dx + u*dv_dx
    expected_hv = oof*v;
    expected_hJ = v*oof2;
    ok = ok && (max(abs(hv-expected_hv)) <= tol); 
    if ~(1==ok) 
        return; 
    end
    ok = ok && (max(max(abs(hJ-expected_hJ))) <= tol); 
    if ~(1==ok) 
        return; 
    end

    % test numeric_scalar * vecvalder_n_by_m
    u = rand(1,1); % numeric
    oof = rand(n,1); oof2 = rand(n, m);
    v = vecvalder(oof, oof2);
    h = u*v;
    hv = val(h); hJ = jac(h);
    % if h(u,v) = u*v, dh_dx = v*du_dx + u*dv_dx
    expected_hv = u*oof;
    expected_hJ = u*oof2;
    ok = ok && (max(abs(hv-expected_hv)) <= tol); 
    if ~(1==ok) 
        return; 
    end
    ok = ok && (max(max(abs(hJ-expected_hJ))) <= tol); 
    if ~(1==ok) 
        return; 
    end

    % test vecvalder_n_by_m * vecvalder_scalar
    oof = rand(n,1); oof2 = rand(n, m);
    u = vecvalder(oof, oof2);
    poof = rand(1,1); poof2 = rand(1, m);
    v = vecvalder(poof,poof2); 
    h = u*v;
    hv = val(h); hJ = jac(h);
    % if h(u,v) = u*v, dh_dx = v*du_dx + u*dv_dx
    expected_hv = oof*poof;
    expected_hJ = poof*oof2 + oof*poof2;
    ok = ok && (max(abs(hv-expected_hv)) <= tol); 
    if ~(1==ok) 
        return; 
    end
    ok = ok && (max(max(abs(hJ-expected_hJ))) <= tol); 
    if ~(1==ok) 
        return; 
    end

    % test vecvalder_scalar * vecvalder_n_by_m
    oof = rand(1,1); oof2 = rand(1, m);
    u = vecvalder(oof, oof2);
    poof = rand(n,1); poof2 = rand(n, m);
    v = vecvalder(poof,poof2); 
    h = u*v;
    hv = val(h); hJ = jac(h);
    % if h(u,v) = u*v, dh_dx = v*du_dx + u*dv_dx
    expected_hv = oof*poof;
    expected_hJ = poof*oof2 + oof*poof2;
    ok = ok && (max(abs(hv-expected_hv)) <= tol); 
    if ~(1==ok) 
        return; 
    end
    ok = ok && (max(max(abs(hJ-expected_hJ))) <= tol); 
    if ~(1==ok) 
        return; 
    end
end
