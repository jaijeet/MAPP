function [ok, funcname] = test_vecvalder_rdivide(n, m, tol)
%function [ok, funcname] = test_vecvalder_rdivide(n, m, tol)
%
%run tests on vecvalder/rdivide; compare with handcoded expectations.
%
%Both arguments are optional:
%   n: size of the vecvalder (defaults to 10 if unspecified)
%   m: number of indep vars for derivatives (defaults to n+1 if unspecified)
%   tol: absolute tolerance for error check (defaults to 1e-15 if unspecified)
%
%Return values:
%   ok: 1 if everything passes, 0 otherwise.
%   funcname: always set to 'rdivide()'
%
%This function tests:
%   vecvalder_n_by_m./numeric_scalar
%   numeric_scalar./vecvalder_n_by_m
%   numeric_n./vecvalder_n_by_m
%   vecvalder_n_by_m./vecvalder_n_by_m
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

	funcname = 'rdivide()';
    ok = 1;
    offset = 0.5;

    % test vecvalder_n_by_m./numeric_scalar
    oof = rand(n,1); oof2 = rand(n, m);
    u = vecvalder(oof, oof2);
    v = offset+rand(1,1); % scalar
    h = u./v;
    hv = val(h); hJ = jac(h);
    % if h(u,v) = u/v, dh_dx = dh_du*du_dx + dh_dv*dv_dx
    % dh_du = 1/v
    % dh_dv = -u/v^2 = -h/v
    expected_hv = oof./v;
    expected_hJ = 1./v*oof2;
    ok = ok && (max(abs(hv-expected_hv)/n) <= tol); 
    if ~(1==ok) 
        fprintf(2, 'vv2 rdivide: avg val error = %g', full(max(abs(hv-expected_hv))));
        return; 
    end
    ok = ok && (max(max(abs(hJ-expected_hJ))) <= tol); 
    if ~(1==ok) 
        fprintf(2, 'vv2 rdivide: avg jac error = %g', ...
                                    full(max(max(abs(hJ-expected_hJ)))) );
        return; 
    end

    % test numeric_scalar./vecvalder_n_by_m
    u = rand(1,1); % scalar
    oof = offset+rand(n,1); oof2 = rand(n, m);
    v = vecvalder(oof, oof2);
    h = u./v;
    hv = val(h); hJ = jac(h);
    % if h(u,v) = u/v, dh_dx = dh_du*du_dx + dh_dv*dv_dx
    % dh_du = 1/v
    % dh_dv = -u/v^2 = -h/v
    expected_hv = u./oof;
    expected_hJ = -((expected_hv./oof)*ones(1,m)).*oof2;
    ok = ok && (max(abs(hv-expected_hv)/n) <= tol); 
    if ~(1==ok) 
        fprintf(2, 'vv2 rdivide: avg val error = %g', full(max(abs(hv-expected_hv))));
        return; 
    end
    ok = ok && (max(max(abs(hJ-expected_hJ))) <= tol); 
    if ~(1==ok) 
        fprintf(2, 'vv2 rdivide: avg jac error = %g', ...
                                    full(max(max(abs(hJ-expected_hJ)))) );
        return; 
    end

    % test numeric_n./vecvalder_n_by_m
    u = rand(n,1); % scalar
    oof = offset+rand(n,1); oof2 = rand(n, m);
    v = vecvalder(oof, oof2);
    h = u./v;
    hv = val(h); hJ = jac(h);
    % if h(u,v) = u/v, dh_dx = dh_du*du_dx + dh_dv*dv_dx
    % dh_du = 1/v
    % dh_dv = -u/v^2 = -h/v
    expected_hv = u./oof;
    expected_hJ = -((expected_hv./oof)*ones(1,m)).*oof2;
    ok = ok && (max(abs(hv-expected_hv)/n) <= tol); 
    if ~(1==ok) 
        fprintf(2, 'vv2 rdivide: avg val error = %g', full(max(abs(hv-expected_hv))));
        return; 
    end
    ok = ok && (max(max(abs(hJ-expected_hJ))) <= tol); 
    if ~(1==ok) 
        fprintf(2, 'vv2 rdivide: avg jac error = %g', ...
                                    full(max(max(abs(hJ-expected_hJ)))) );
        return; 
    end

    % test vecvalder_n_by_m/vecvalder_n_by_m
    oof = rand(n,1); oof2 = rand(n, m);
    u = vecvalder(oof, oof2);
    poof = offset+rand(n,1); poof2 = rand(n, m);
    v = vecvalder(poof, poof2); 
    h = u./v;
    hv = val(h); hJ = jac(h);
    % if h(u,v) = u/v, dh_dx = dh_du*du_dx + dh_dv*dv_dx
    % dh_du = 1/v
    % dh_dv = -u/v^2 = -h/v
    expected_hv = oof./poof;
    expected_hJ = ((1./poof)*ones(1,m)).*oof2 - ...
                  ((expected_hv./poof)*ones(1,m)).*poof2;
    ok = ok && (max(abs(hv-expected_hv)/n) <= tol); 
    if ~(1==ok) 
        fprintf(2, 'vv2 rdivide: avg val error = %g', full(max(abs(hv-expected_hv))));
        return; 
    end
    ok = ok && (max(max(abs(hJ-expected_hJ))) <= tol); 
    if ~(1==ok) 
        fprintf(2, 'vv2 rdivide: avg jac error = %g', ...
                                    full(max(max(abs(hJ-expected_hJ)))) );
        return; 
    end
end
