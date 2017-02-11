function [ok, funcname] = test_vecvalder_plus(n, m, tol)
%function [ok, funcname] = test_vecvalder_plus(n, m, tol)
%
%run tests on vecvalder/plus; compare with handcoded expectations.
%
%Both arguments are optional:
%   n: size of vecvalder vector to test (defaults to 10 if unspecified)
%   m: number of indep vars for derivatives (defaults to n+1 if unspecified)
%   tol: absolute tolerance for error check (defaults to 0 if unspecified)
%
%Return values:
%   ok: 1 if everything passes, 0 otherwise.
%   funcname: always set to 'plus()'
%
%This function tests:
%   vv_n_by_m + numeric_scalar
%   vv_n_by_m + numeric_n
%   numeric_scalar + vv_n_by_m
%   numeric_n + vv_n_by_m
%   vv_n_by_m + vv_n_by_m
%   vv_n_by_m + vv_1_by_m
%   vv_1_by_m + vv_n_by_m 
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

	funcname = 'plus()';
    ok = 1;

    % test vv_n_by_m + numeric_scalar
    oof = rand(n,1); oof2 = rand(n, m);
    u = vecvalder(oof, oof2);
    v = rand(1,1); % scalar
    h = u+v;
    hv = val(h); hJ = jac(h);
    % if y = log(u), dy/dx = (1/u)*du_dx
    expected_hv = oof+v;
    expected_hJ = oof2;
    ok = ok && ~sum(hv-expected_hv); if ~(1==ok) return; end
    ok = ok && ~sum(sum(hJ-expected_hJ)); if ~(1==ok) return; end

    % test vv_n_by_m + numeric_n
    oof = rand(n,1); oof2 = rand(n, m);
    u = vecvalder(oof, oof2);
    v = rand(n,1); %
    h = u+v;
    hv = val(h); hJ = jac(h);
    expected_hv = oof+v;
    expected_hJ = oof2;
    ok = ok && ~sum(hv-expected_hv); if ~(1==ok) return; end
    ok = ok && ~sum(sum(hJ-expected_hJ)); if ~(1==ok) return; end

    % test numeric_scalar + vv_n_by_m
    oof = rand(n,1); oof2 = rand(n, m);
    u = rand(1,1); % scalar
    v = vecvalder(oof, oof2);
    h = u+v;
    hv = val(h); hJ = jac(h);
    expected_hv = u+oof;
    expected_hJ = oof2;
    ok = ok && ~sum(hv-expected_hv); if ~(1==ok) return; end
    ok = ok && ~sum(sum(hJ-expected_hJ)); if ~(1==ok) return; end

    % test numeric_n + vv_n_by_m
    oof = rand(n,1); oof2 = rand(n, m);
    u = rand(n,1); % scalar
    v = vecvalder(oof, oof2);
    h = u+v;
    hv = val(h); hJ = jac(h);
    expected_hv = u+oof;
    expected_hJ = oof2;
    ok = ok && ~sum(hv-expected_hv); if ~(1==ok) return; end
    ok = ok && ~sum(sum(hJ-expected_hJ)); if ~(1==ok) return; end

    % test vv_n_by_m + vv_n_by_m
    oof = rand(n,1); oof2 = rand(n, m);
    poof = rand(n,1); poof2 = rand(n, m);
    u = vecvalder(oof, oof2);
    v = vecvalder(poof, poof2);
    h = u+v;
    hv = val(h); hJ = jac(h);
    expected_hv = oof+poof;
    expected_hJ = oof2+poof2;
    ok = ok && ~sum(hv-expected_hv); if ~(1==ok) return; end
    ok = ok && ~sum(sum(hJ-expected_hJ)); if ~(1==ok) return; end

    % test vv_n_by_m + vv_1_by_m
    oof = rand(n,1); oof2 = rand(n, m);
    poof = rand(1,1); poof2 = rand(1, m);
    u = vecvalder(oof, oof2);
    v = vecvalder(poof, poof2);
    h = u+v;
    hv = val(h); hJ = jac(h);
    expected_hv = oof+poof;
    expected_hJ = oof2+ones(n,1)*poof2;
    ok = ok && ~sum(hv-expected_hv); if ~(1==ok) return; end
    ok = ok && ~sum(sum(hJ-expected_hJ)); if ~(1==ok) return; end

    % test vv_1_by_m + vv_n_by_m  
    oof = rand(1,1); oof2 = rand(1, m);
    poof = rand(n,1); poof2 = rand(n, m);
    u = vecvalder(oof, oof2);
    v = vecvalder(poof, poof2);
    h = u+v;
    hv = val(h); hJ = jac(h);
    expected_hv = oof+poof;
    expected_hJ = ones(n,1)*oof2+poof2;
    ok = ok && ~sum(hv-expected_hv); if ~(1==ok) return; end
    ok = ok && ~sum(sum(hJ-expected_hJ)); if ~(1==ok) return; end
end
