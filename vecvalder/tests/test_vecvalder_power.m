function [ok, funcname] = test_vecvalder_power(n, m, tol)
%function [ok, funcname] = test_vecvalder_power(n, m, tol)
%
%run tests on vecvalder/power; compare with handcoded expectations.
%
%Both arguments are optional:
%   n: size of the vecvalder (defaults to 10 if unspecified)
%   m: number of indep vars for derivatives (defaults to n+1 if unspecified)
%   tol: absolute tolerance for error check (defaults to 1e-15 if unspecified)
%
%Return values:
%   ok: 1 if everything passes, 0 otherwise.
%   funcname: always set to 'power()'
%
%This function tests:
%   vecvalder_n_by_m.^numeric_scalar
%   numeric_scalar.^vecvalder_n_by_m
%   vecvalder_n_by_m.^numeric_n
%   numeric_n.^vecvalder_n_by_m
%   vecvalder_n_by_m.^vecvalder_n_by_m
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
	if nargin < 2
		tol = 1e-15;
	end

	funcname = 'power()';
    ok = 1;
    offset = 0.1; 

    % test vecvalder_n_by_m.^numeric_scalar
    oof = offset+rand(n,1); oof2 = rand(n, m);
    u = vecvalder(oof, oof2);
    v = rand(1,1); % scalar
    h = u.^v;
    hv = val(h); hJ = jac(h);
    % if h(u,v) = u^v, dh_dx = dh_du*du_dx + dh_dv*dv_dx
    % dh_du = v*u^(v-1) = v*h/u
    % dh_dv: log(h) = v*log(u) => h = e^{v*log(u)} => dh_dv = log(u)*h
    expected_hv = oof.^v;
    expected_hJ = ((v*expected_hv./oof)*ones(1,m)).*oof2;
    ok = ok && (max(abs(hv-expected_hv)/n) <= tol); 
    if ~(1==ok) 
        fprintf(2, 'vv2 power: avg val error = %g', full(max(abs(hv-expected_hv))));
        return; 
    end
    ok = ok && (max(max(abs(hJ-expected_hJ))) <= tol); 
    if ~(1==ok) 
        fprintf(2, 'vv2 power: avg jac error = %g', ...
                                    full(max(max(abs(hJ-expected_hJ)))) );
        return; 
    end

    % test numeric_scalar.^vecvalder_n_by_m
    u = offset+rand(1,1); % scalar
    oof = rand(n,1); oof2 = rand(n, m);
    v = vecvalder(oof, oof2);
    h = u.^v;
    hv = val(h); hJ = jac(h);
    % if h(u,v) = u^v, dh_dx = dh_du*du_dx + dh_dv*dv_dx
    % dh_du = v*u^(v-1) = v*h/u
    % dh_dv: log(h) = v*log(u) => h = e^{v*log(u)} => dh_dv = log(u)*h
    expected_hv = u.^oof;
    expected_hJ = ((log(u)*expected_hv)*ones(1,m)).*oof2;
    ok = ok && (max(abs(hv-expected_hv)/n) <= tol); 
    if ~(1==ok) 
        fprintf(2, 'vv2 power: avg val error = %g', full(max(abs(hv-expected_hv))));
        return; 
    end
    ok = ok && (max(max(abs(hJ-expected_hJ))) <= tol); 
    if ~(1==ok) 
        fprintf(2, 'vv2 power: avg jac error = %g', ...
                                    full(max(max(abs(hJ-expected_hJ)))) );
        return; 
    end

    % test vecvalder_n_by_m.^numeric_n
    oof = offset+rand(n,1); oof2 = rand(n, m);
    u = vecvalder(oof, oof2);
    v = rand(n,1); % scalar
    h = u.^v;
    hv = val(h); hJ = jac(h);
    % if h(u,v) = u^v, dh_dx = dh_du*du_dx + dh_dv*dv_dx
    % dh_du = v*u^(v-1) = v*h/u
    % dh_dv: log(h) = v*log(u) => h = e^{v*log(u)} => dh_dv = log(u)*h
    expected_hv = oof.^v;
    expected_hJ = ((v.*expected_hv./oof)*ones(1,m)).*oof2;
    ok = ok && (max(abs(hv-expected_hv)/n) <= tol); 
    if ~(1==ok) 
        fprintf(2, 'vv2 power: avg val error = %g', full(max(abs(hv-expected_hv))));
        return; 
    end
    ok = ok && (max(max(abs(hJ-expected_hJ))) <= tol); 
    if ~(1==ok) 
        fprintf(2, 'vv2 power: avg jac error = %g', ...
                                    full(max(max(abs(hJ-expected_hJ)))) );
        return; 
    end

    % test numeric_n.^vecvalder_n_by_m
    u = offset+rand(n,1); % scalar
    oof = rand(n,1); oof2 = rand(n, m);
    v = vecvalder(oof, oof2);
    h = u.^v;
    hv = val(h); hJ = jac(h);
    % if h(u,v) = u^v, dh_dx = dh_du*du_dx + dh_dv*dv_dx
    % dh_du = v*u^(v-1) = v*h/u
    % dh_dv: log(h) = v*log(u) => h = e^{v*log(u)} => dh_dv = log(u)*h
    expected_hv = u.^oof;
    expected_hJ = ((log(u).*expected_hv)*ones(1,m)).*oof2;
    ok = ok && (max(abs(hv-expected_hv)/n) <= tol); 
    if ~(1==ok) 
        fprintf(2, 'vv2 power: avg val error = %g', full(max(abs(hv-expected_hv))));
        return; 
    end
    ok = ok && (max(max(abs(hJ-expected_hJ))) <= tol); 
    if ~(1==ok) 
        fprintf(2, 'vv2 power: avg jac error = %g', ...
                                    full(max(max(abs(hJ-expected_hJ)))) );
        return; 
    end

    % test vecvalder_n_by_m.^vecvalder_n_by_m
    oof = offset+rand(n,1); oof2 = rand(n, m);
    poof = rand(n,1); poof2 = rand(n, m);
    u = vecvalder(oof, oof2);
    v = vecvalder(poof, poof2);
    h = u.^v;
    hv = val(h); hJ = jac(h);
    % if h(u,v) = u^v, dh_dx = dh_du*du_dx + dh_dv*dv_dx
    % dh_du = v*u^(v-1) = v*h/u
    % dh_dv: log(h) = v*log(u) => h = e^{v*log(u)} => dh_dv = log(u)*h
    expected_hv = oof.^poof;
    expected_hJ = ((poof.*expected_hv./oof)*ones(1,m)).*oof2 + ...
                   ((log(oof).*expected_hv)*ones(1,m)).*poof2;
    ok = ok && (max(abs(hv-expected_hv)/n) <= tol); 
    if ~(1==ok) 
        fprintf(2, 'vv2 power: avg val error = %g', full(max(abs(hv-expected_hv))));
        return; 
    end
    ok = ok && (max(max(abs(hJ-expected_hJ))) <= tol); 
    if ~(1==ok) 
        fprintf(2, 'vv2 power: avg jac error = %g', ...
                                    full(max(max(abs(hJ-expected_hJ)))) );
        return; 
    end
end
