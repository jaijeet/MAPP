function [ok, funcname] = test_vecvalder_min(n, m, tol)
%function [ok, funcname] = test_vecvalder_min(n, m, tol)
%
%run tests on vecvalder/min; compare with handcoded expectations.
%
%Both arguments are optional:
%   n: size of vecvalder vector to test (defaults to 10 if unspecified)
%   m: number of indep vars for derivatives (defaults to n+1 if unspecified)
%   tol: absolute tolerance for error check (defaults to 0 if unspecified)
%
%Return values:
%   ok: 1 if everything passes, 0 otherwise.
%   funcname: always set to 'min()'
%
%This function tests:
%   min(numeric_scalar, vecvalder_n_by_m)
%   min(vecvalder_n_by_m, numeric_scalar)
%   min(numeric_n, vecvalder_n_by_m)
%   min(vecvalder_n_by_m, numeric_n)
%   min(vecvalder_n_by_m, vecvalder_scalar)
%   min(vecvalder_scalar, vecvalder_n_by_m)
%   min(vecvalder_n_by_m, vecvalder_n_by_m)
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

	funcname = 'min()';
    ok = 1;

    % test min(numeric_scalar, vecvalder_n_by_m)
    u = rand(1,1); % numeric
    oof = rand(n,1); oof2 = rand(n, m);
    v = vecvalder(oof, oof2);
    h = min(u, v);
    hv = val(h); hJ = jac(h);
    % if h(u,v) = min(u,v), dh_dx = dmin_du(u,v)*du_dx + dmin_dv(u,v)*dv_dx
    % min(u, v) = 0.5*(-abs(u-v) + u + v) =>
    % dmin_du = 0.5*(-sign(u-v) + 1)
    % dmin_dv = 0.5*(sign(u-v) + 1) 
    expected_hv = min(u, oof);
    expected_hJ = 0.5*((sign(u-oof)+1)*ones(1,m)).*oof2;
    ok = ok && (abs(sum(hv-expected_hv)) <= tol); 
    if ~(1==ok) 
        return; 
    end
    ok = ok && (abs(sum(sum(hJ-expected_hJ)))/m/n <= tol); 
    if ~(1==ok) 
        return; 
    end

    % test min(vecvalder_n_by_m, numeric_scalar)
    oof = rand(n,1); oof2 = rand(n, m);
    u = vecvalder(oof, oof2);
    v = rand(1,1); % numeric
    h = min(u, v);
    hv = val(h); hJ = jac(h);
    % if h(u,v) = min(u,v), dh_dx = dmin_du(u,v)*du_dx + dmin_dv(u,v)*dv_dx
    % min(u, v) = 0.5*(-abs(u-v) + u + v) =>
    % dmin_du = 0.5*(-sign(u-v) + 1)
    % dmin_dv = 0.5*(sign(u-v) + 1) 
    expected_hv = min(oof, v);
    expected_hJ = 0.5*((-sign(oof-v)+1)*ones(1,m)).*oof2;
    ok = ok && (abs(sum(hv-expected_hv)) <= tol); 
    if ~(1==ok) 
        return; 
    end
    ok = ok && (abs(sum(sum(hJ-expected_hJ)))/m/n <= tol); 
    if ~(1==ok) 
        return; 
    end

    % test min(numeric_n, vecvalder_n_by_m)
    u = rand(n,1); % numeric
    oof = rand(n,1); oof2 = rand(n, m);
    v = vecvalder(oof, oof2);
    h = min(u, v);
    hv = val(h); hJ = jac(h);
    % if h(u,v) = min(u,v), dh_dx = dmin_du(u,v)*du_dx + dmin_dv(u,v)*dv_dx
    % min(u, v) = 0.5*(-abs(u-v) + u + v) =>
    % dmin_du = 0.5*(-sign(u-v) + 1)
    % dmin_dv = 0.5*(sign(u-v) + 1) 
    expected_hv = min(u, oof);
    expected_hJ = 0.5*((sign(u-oof)+1)*ones(1,m)).*oof2;
    ok = ok && (abs(sum(hv-expected_hv)) <= tol); 
    if ~(1==ok) 
        return; 
    end
    ok = ok && (abs(sum(sum(hJ-expected_hJ)))/m/n <= tol); 
    if ~(1==ok) 
        return; 
    end


    % test min(vecvalder_n_by_m, numeric_n)
    oof = rand(n,1); oof2 = rand(n, m);
    u = vecvalder(oof, oof2);
    v = rand(n,1); % numeric
    h = min(u, v);
    hv = val(h); hJ = jac(h);
    % if h(u,v) = min(u,v), dh_dx = dmin_du(u,v)*du_dx + dmin_dv(u,v)*dv_dx
    % min(u, v) = 0.5*(-abs(u-v) + u + v) =>
    % dmin_du = 0.5*(-sign(u-v) + 1)
    % dmin_dv = 0.5*(sign(u-v) + 1) 
    expected_hv = min(oof, v);
    expected_hJ = 0.5*((-sign(oof-v)+1)*ones(1,m)).*oof2;
    ok = ok && (abs(sum(hv-expected_hv)) <= tol); 
    if ~(1==ok) 
        return; 
    end
    ok = ok && (abs(sum(sum(hJ-expected_hJ)))/m/n <= tol); 
    if ~(1==ok) 
        return; 
    end


    % test min(vecvalder_n_by_m, vecvalder_scalar)
    oof = rand(n,1); oof2 = rand(n, m);
    u = vecvalder(oof, oof2);
    poof = rand(1,1); poof2 = rand(1,m);
    v = vecvalder(poof, poof2);
    h = min(u, v);
    hv = val(h); hJ = jac(h);
    % if h(u,v) = min(u,v), dh_dx = dmin_du(u,v)*du_dx + dmin_dv(u,v)*dv_dx
    % min(u, v) = 0.5*(-abs(u-v) + u + v) =>
    % dmin_du = 0.5*(-sign(u-v) + 1)
    % dmin_dv = 0.5*(sign(u-v) + 1) 
    expected_hv = min(oof, poof);
    expected_hJ = 0.5*((-sign(oof-poof)+1)*ones(1,m)).*oof2 + ...
                  0.5*((sign(oof-poof)+1)*ones(1,m)).*(ones(n,1)*poof2);
    ok = ok && (abs(sum(hv-expected_hv)) <= tol); 
    if ~(1==ok) 
        return; 
    end
    ok = ok && (abs(sum(sum(hJ-expected_hJ)))/m/n <= tol); 
    if ~(1==ok) 
        return; 
    end


    % test min(vecvalder_scalar, vecvalder_n_by_m)
    oof = rand(1,1); oof2 = rand(1, m);
    u = vecvalder(oof, oof2);
    poof = rand(n,1); poof2 = rand(n,m);
    v = vecvalder(poof, poof2);
    h = min(u, v);
    hv = val(h); hJ = jac(h);
    % if h(u,v) = min(u,v), dh_dx = dmin_du(u,v)*du_dx + dmin_dv(u,v)*dv_dx
    % min(u, v) = 0.5*(-abs(u-v) + u + v) =>
    % dmin_du = 0.5*(-sign(u-v) + 1)
    % dmin_dv = 0.5*(sign(u-v) + 1) 
    expected_hv = min(oof, poof);
    expected_hJ = 0.5*((-sign(oof-poof)+1)*ones(1,m)).*(ones(n,1)*oof2) + ...
                  0.5*((sign(oof-poof)+1)*ones(1,m)).*poof2;
    ok = ok && (abs(sum(hv-expected_hv)) <= tol); 
    if ~(1==ok) 
        return; 
    end
    ok = ok && (abs(sum(sum(hJ-expected_hJ)))/m/n <= tol); 
    if ~(1==ok) 
        return; 
    end

    % test min(vecvalder_n_by_m, vecvalder_n_by_m)
    oof = rand(n,1); oof2 = rand(n, m);
    u = vecvalder(oof, oof2);
    poof = rand(n,1); poof2 = rand(n,m);
    v = vecvalder(poof, poof2);
    h = min(u, v);
    hv = val(h); hJ = jac(h);
    % if h(u,v) = min(u,v), dh_dx = dmin_du(u,v)*du_dx + dmin_dv(u,v)*dv_dx
    % min(u, v) = 0.5*(-abs(u-v) + u + v) =>
    % dmin_du = 0.5*(-sign(u-v) + 1)
    % dmin_dv = 0.5*(sign(u-v) + 1) 
    expected_hv = min(oof, poof);
    expected_hJ = 0.5*((-sign(oof-poof)+1)*ones(1,m)).*oof2 + ...
                  0.5*((sign(oof-poof)+1)*ones(1,m)).*poof2;
    ok = ok && (abs(sum(hv-expected_hv)) <= tol); 
    if ~(1==ok) 
        return; 
    end
    ok = ok && (abs(sum(sum(hJ-expected_hJ)))/m/n <= tol); 
    if ~(1==ok) 
        return; 
    end
end
