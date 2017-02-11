function [ok, funcname] = test_vecvalder_cross(n, m, tol)
%function [ok, funcname] = test_vecvalder_cross(n, m, tol)
%
%run tests on vecvalder/cross; compare with handcoded expectations.
%
%Both arguments are optional:
%   n: size of vecvalder vector to test (defaults to 3 if unspecified)
%   m: number of indep vars for derivatives (defaults to n+1 if unspecified)
%   tol: absolute tolerance for error check (defaults to 1e-15 if unspecified)
%
%Return values:
%   ok: 1 if everything passes, 0 otherwise.
%   funcname: always set to 'cross()'
%
%This function tests:
%   cross(vecvalder_n_by_m, numeric_n)
%   cross(numeric_n, vecvalder_n_by_m)
%   cross(vecvalder_n_by_m, vecvalder_n_by_m)
%
%It uses vecvalder(), val() and jac(), which get tested as well.
%
%Author: JR, 2014/06/18

	if nargin < 1
		n = 3;
	end
	if nargin < 2
		m = n+1;
	end
	if nargin < 3
		tol = 1e-15;
	end

	funcname = 'cross()';
    ok = 1;

    % test cross(vecvalder_n_by_m, numeric_n)
    oof = rand(n,1); oof2 = rand(n, m);
    u = vecvalder(oof, oof2);
    v = rand(n,1); % numeric
    h = cross(u,v);
    hv = val(h); hJ = jac(h);
    % if h(u,v) = cross(u,v), dh_dx = cross(du_dx, v) + cross(u, dv_dx)
    expected_hv = cross(oof,v);
    expected_hJ = cross(oof2, v*ones(1,m), 1);
    ok = ok && (max(abs(hv-expected_hv)) <= tol); 
    if ~(1==ok) 
        fprintf(2, 'vv2 cross: avg val error = %g', full(max(abs(hv-expected_hv))));
        return; 
    end
    ok = ok && (max(max(abs(hJ-expected_hJ))) <= tol); 
    if ~(1==ok) 
        fprintf(2, 'vv2 cross: avg jac error = %g', ...
                                    full(max(max(abs(hJ-expected_hJ)))) );
        return; 
    end

    % test cross(numeric_n, vecvalder_n_by_m)
    u = rand(n,1); % numeric
    oof = rand(n,1); oof2 = rand(n, m);
    v = vecvalder(oof, oof2);
    h = cross(u,v);
    hv = val(h); hJ = jac(h);
    % if h(u,v) = cross(u,v), dh_dx = cross(du_dx, v) + cross(u, dv_dx)
    expected_hv = cross(u,oof);
    expected_hJ = cross(u*ones(1,m), oof2, 1);
    ok = ok && (max(abs(hv-expected_hv)) <= tol); 
    if ~(1==ok) 
        fprintf(2, 'vv2 cross: avg val error = %g', full(max(abs(hv-expected_hv))));
        return; 
    end
    ok = ok && (max(max(abs(hJ-expected_hJ))) <= tol); 
    if ~(1==ok) 
        fprintf(2, 'vv2 cross: avg jac error = %g', ...
                                    full(max(max(abs(hJ-expected_hJ)))) );
        return; 
    end

    % test cross(vecvalder_n_by_m, vecvalder_n_by_m)
    oof = rand(n,1); oof2 = rand(n, m);
    u = vecvalder(oof, oof2);
    poof = rand(n,1); poof2 = rand(n, m);
    v = vecvalder(poof, poof2);
    h = cross(u,v);
    hv = val(h); hJ = jac(h);
    % if h(u,v) = cross(u,v), dh_dx = cross(du_dx, v) + cross(u, dv_dx)
    expected_hv = cross(oof,poof);
    expected_hJ = cross(oof2, poof*ones(1,m), 1) + ...
                        cross(oof*ones(1,m), poof2, 1);
    ok = ok && (max(abs(hv-expected_hv)) <= tol); 
    if ~(1==ok) 
        fprintf(2, 'vv2 cross: avg val error = %g', full(max(abs(hv-expected_hv))));
        return; 
    end
    ok = ok && (max(max(abs(hJ-expected_hJ))) <= tol); 
    if ~(1==ok) 
        fprintf(2, 'vv2 cross: avg jac error = %g', ...
                                    full(max(max(abs(hJ-expected_hJ)))) );
        return; 
    end
end
