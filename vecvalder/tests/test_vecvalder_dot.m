function [ok, funcname] = test_vecvalder_dot(n, m, tol)
%function [ok, funcname] = test_vecvalder_dot(n, m, tol)
%
%run tests on vecvalder/dot; compare with handcoded expectations.
%
%Both arguments are optional:
%   n: size of vecvalder vector to test (defaults to 10 if unspecified)
%   m: number of indep vars for derivatives (defaults to n+1 if unspecified)
%   tol: absolute tolerance for error check (defaults to 1e-15 if unspecified)
%
%Return values:
%   ok: 1 if everything passes, 0 otherwise.
%   funcname: always set to 'dot()'
%
%This function tests:
%   dot(vecvalder_n_by_m, numeric_n)
%   dot(numeric_n, vecvalder_n_by_m)
%   dot(vecvalder_n_by_m, vecvalder_n_by_m)
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
		% tol = 1e-15;
		% assuming truncation error is 1e-16 (may not be true), theoretical bound for hv error is
		% tol = 2*n * 1e-16;
		% theoretical bound for hJ error is
		% tol = 4*n * 1e-16;
		tol = 1.1 * 4*n * 1e-16;
	end

	funcname = 'dot()';
    ok = 1;

    % test dot(vecvalder_n_by_m, numeric_n)
    oof = rand(n,1); oof2 = rand(n, m);
    u = vecvalder(oof, oof2);
    v = rand(n,1); % numeric
    h = dot(u,v);
    hv = val(h); hJ = jac(h);
    % if h(u,v) = dot(u,v) = u.' * v, dh/dx = du_dx.' * v + u.' * dv_dx
    expected_hv = dot(oof,v);
    expected_hJ = v.'*oof2;
    ok = ok && (max(abs(hv-expected_hv)) <= tol); 
    if ~(1==ok) 
        fprintf(2, 'vv2 dot: avg val error = %g', full(max(abs(hv-expected_hv))));
        return; 
    end
    ok = ok && (max(max(abs(hJ-expected_hJ))) <= tol); 
    if ~(1==ok) 
        fprintf(2, 'vv2 dot: avg jac error = %g', ...
                                    full(max(max(abs(hJ-expected_hJ)))) );
        return; 
    end

    % test dot(numeric_n, vecvalder_n_by_m)
    u = rand(n,1); % numeric
    oof = rand(n,1); oof2 = rand(n, m);
    v = vecvalder(oof, oof2);
    h = dot(u,v);
    hv = val(h); hJ = jac(h);
    % if h(u,v) = dot(u,v) = u.' * v, dh/dx = du_dx.' * v + u.' * dv_dx
    expected_hv = dot(u,oof);
    expected_hJ = u.'*oof2;
    ok = ok && (max(abs(hv-expected_hv)) <= tol); 
    if ~(1==ok) 
        fprintf(2, 'vv2 dot: avg val error = %g', full(max(abs(hv-expected_hv))));
        return; 
    end
    ok = ok && (max(max(abs(hJ-expected_hJ))) <= tol); 
    if ~(1==ok) 
        fprintf(2, 'vv2 dot: avg jac error = %g', ...
                                    full(max(max(abs(hJ-expected_hJ)))) );
        return; 
    end

    % test dot(vecvalder_n_by_m, vecvalder_n_by_m)
    oof = rand(n,1); oof2 = rand(n, m);
    u = vecvalder(oof, oof2);
    poof = rand(n,1); poof2 = rand(n, m);
    v = vecvalder(poof, poof2);
    h = dot(u,v);
    hv = val(h); hJ = jac(h);
    % if h(u,v) = dot(u,v) = u.' * v, dh/dx = du_dx.' * v + u.' * dv_dx
    expected_hv = dot(oof,poof);
    expected_hJ = poof.'*oof2 + oof.'*poof2;
    ok = ok && (max(abs(hv-expected_hv)) <= tol); 
    if ~(1==ok) 
        fprintf(2, 'vv2 dot: avg val error = %g', full(max(abs(hv-expected_hv))));
        return; 
    end
    ok = ok && (max(max(abs(hJ-expected_hJ))) <= tol); 
    if ~(1==ok) 
        fprintf(2, 'vv2 dot: avg jac error = %g', ...
                                    full(max(max(abs(hJ-expected_hJ)))) );
        return; 
    end
end
