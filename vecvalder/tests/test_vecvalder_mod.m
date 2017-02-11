function [ok, funcname] = test_vecvalder_mod(n, m, tol)
%function [ok, funcname] = test_vecvalder_mod(n, m, tol)
%
%run tests on vecvalder/mod; compare with handcoded expectations.
%
%Both arguments are optional:
%   n: size of vecvalder vector to test (defaults to 10 if unspecified)
%   m: number of indep vars for derivatives (defaults to n+1 if unspecified)
%   tol: absolute tolerance for error check (defaults to 0 if unspecified)
%
%Return values:
%   ok: 1 if everything passes, 0 otherwise.
%   funcname: always set to 'mod()'
%
%This function tests:
%   mod(numeric_scalar, vecvalder_n_by_m)
%   mod(vecvalder_n_by_m, numeric_scalar)
%   mod(numeric_n, vecvalder_n_by_m)
%   mod(vecvalder_n_by_m, numeric_n)
%   mod(vecvalder_n_by_m, vecvalder_scalar)
%   mod(vecvalder_scalar, vecvalder_n_by_m)
%   mod(vecvalder_n_by_m, vecvalder_n_by_m)
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

	funcname = 'mod()';
    ok = 1;

    % test mod(numeric_scalar, vecvalder_n_by_m)
    u = rand(1,1); % numeric
    oof = rand(n,1); oof2 = rand(n, m);
    v = vecvalder(oof, oof2);
    h = mod(u, v);
    hv = val(h); hJ = jac(h);
    % if h(u,v) = mod(u,v), dh_dx = dmod_du(u,v)*du_dx + dmod_dv(u,v)*dv_dx
    % mod(u, v) = u - floor(u/v)*v =>
    % dmod_du = 1 - dfloor_darg(u/v) = 1
    % dmod_dv = dfloor_darg(u/v)*u/v^2 - floor(u/v) = -floor(u/v)
    expected_hv = mod(u, oof);
    expected_hJ = -(floor(u./oof)*ones(1,m)).*oof2;
    ok = ok && (max(abs(hv-expected_hv)) <= tol); 
    if ~(1==ok) 
        return; 
    end
    ok = ok && (max(max(abs(hJ-expected_hJ))) <= tol); 
    if ~(1==ok) 
        return; 
    end

    % test mod(vecvalder_n_by_m, numeric_scalar)
    oof = rand(n,1); oof2 = rand(n, m);
    u = vecvalder(oof, oof2);
    v = rand(1,1); % numeric
    h = mod(u, v);
    hv = val(h); hJ = jac(h);
    % if h(u,v) = mod(u,v), dh_dx = dmod_du(u,v)*du_dx + dmod_dv(u,v)*dv_dx
    % mod(u, v) = u - floor(u/v)*v =>
    % dmod_du = 1 - dfloor_darg(u/v) = 1
    % dmod_dv = dfloor_darg(u/v)*u/v^2 - floor(u/v) = -floor(u/v)
    expected_hv = mod(oof, v);
    expected_hJ = oof2;
    ok = ok && (max(abs(hv-expected_hv)) <= tol); 
    if ~(1==ok) 
        return; 
    end
    ok = ok && (max(max(abs(hJ-expected_hJ))) <= tol); 
    if ~(1==ok) 
        return; 
    end

    % test mod(numeric_n, vecvalder_n_by_m)
    u = rand(n,1); % numeric
    oof = rand(n,1); oof2 = rand(n, m);
    v = vecvalder(oof, oof2);
    h = mod(u, v);
    hv = val(h); hJ = jac(h);
    % if h(u,v) = mod(u,v), dh_dx = dmod_du(u,v)*du_dx + dmod_dv(u,v)*dv_dx
    % mod(u, v) = u - floor(u/v)*v =>
    % dmod_du = 1 - dfloor_darg(u/v) = 1
    % dmod_dv = dfloor_darg(u/v)*u/v^2 - floor(u/v) = -floor(u/v)
    expected_hv = mod(u, oof);
    expected_hJ = -(floor(u./oof)*ones(1,m)).*oof2;
    ok = ok && (max(abs(hv-expected_hv)) <= tol); 
    if ~(1==ok) 
        return; 
    end
    ok = ok && (max(max(abs(hJ-expected_hJ))) <= tol); 
    if ~(1==ok) 
        return; 
    end

    % test mod(vecvalder_n_by_m, numeric_n)
    oof = rand(n,1); oof2 = rand(n, m);
    u = vecvalder(oof, oof2);
    v = rand(n,1); % numeric
    h = mod(u, v);
    hv = val(h); hJ = jac(h);
    % if h(u,v) = mod(u,v), dh_dx = dmod_du(u,v)*du_dx + dmod_dv(u,v)*dv_dx
    % mod(u, v) = u - floor(u/v)*v =>
    % dmod_du = 1 - dfloor_darg(u/v) = 1
    % dmod_dv = dfloor_darg(u/v)*u/v^2 - floor(u/v) = -floor(u/v)
    expected_hv = mod(oof, v);
    expected_hJ = oof2;
    ok = ok && (max(abs(hv-expected_hv)) <= tol); 
    if ~(1==ok) 
        return; 
    end
    ok = ok && (max(max(abs(hJ-expected_hJ))) <= tol); 
    if ~(1==ok) 
        return; 
    end

    % test mod(vecvalder_n_by_m, vecvalder_scalar)
    oof = rand(n,1); oof2 = rand(n, m);
    u = vecvalder(oof, oof2);
    poof = rand(1,1); poof2 = rand(1,m);
    v = vecvalder(poof, poof2);
    h = mod(u, v);
    hv = val(h); hJ = jac(h);
    % if h(u,v) = mod(u,v), dh_dx = dmod_du(u,v)*du_dx + dmod_dv(u,v)*dv_dx
    % mod(u, v) = u - floor(u/v)*v =>
    % dmod_du = 1 - dfloor_darg(u/v) = 1
    % dmod_dv = dfloor_darg(u/v)*u/v^2 - floor(u/v) = -floor(u/v)
    expected_hv = mod(oof, poof);
    expected_hJ = oof2 - floor(oof/poof)*poof2;
    ok = ok && (max(abs(hv-expected_hv)) <= tol); 
    if ~(1==ok) 
        return; 
    end
    ok = ok && (max(max(abs(hJ-expected_hJ))) <= tol); 
    if ~(1==ok) 
        return; 
    end

    % test mod(vecvalder_scalar, vecvalder_n_by_m)
    oof = rand(1,1); oof2 = rand(1, m);
    u = vecvalder(oof, oof2);
    poof = rand(n,1); poof2 = rand(n,m);
    v = vecvalder(poof, poof2);
    h = mod(u, v);
    hv = val(h); hJ = jac(h);
    % if h(u,v) = mod(u,v), dh_dx = dmod_du(u,v)*du_dx + dmod_dv(u,v)*dv_dx
    % mod(u, v) = u - floor(u/v)*v =>
    % dmod_du = 1 - dfloor_darg(u/v) = 1
    % dmod_dv = dfloor_darg(u/v)*u/v^2 - floor(u/v) = -floor(u/v)
    expected_hv = mod(oof, poof);
    expected_hJ = ones(n,1)*oof2 - (floor(oof./poof)*ones(1,m)).*poof2;
    ok = ok && (max(abs(hv-expected_hv)) <= tol); 
    if ~(1==ok) 
        return; 
    end
    ok = ok && (max(max(abs(hJ-expected_hJ))) <= tol); 
    if ~(1==ok) 
        return; 
    end

    % test mod(vecvalder_n_by_m, vecvalder_n_by_m)
    oof = rand(n,1); oof2 = rand(n, m);
    u = vecvalder(oof, oof2);
    poof = rand(n,1); poof2 = rand(n,m);
    v = vecvalder(poof, poof2);
    h = mod(u, v);
    hv = val(h); hJ = jac(h);
    % if h(u,v) = mod(u,v), dh_dx = dmod_du(u,v)*du_dx + dmod_dv(u,v)*dv_dx
    % mod(u, v) = u - floor(u/v)*v =>
    % dmod_du = 1 - dfloor_darg(u/v) = 1
    % dmod_dv = dfloor_darg(u/v)*u/v^2 - floor(u/v) = -floor(u/v)
    expected_hv = mod(oof, poof);
    expected_hJ = oof2 - (floor(oof./poof)*ones(1,m)).*poof2;
    ok = ok && (max(abs(hv-expected_hv)) <= tol); 
    if ~(1==ok) 
        return; 
    end
    ok = ok && (max(max(abs(hJ-expected_hJ))) <= tol); 
    if ~(1==ok) 
        return; 
    end

end
