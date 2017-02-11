function [ok, funcname] = test_vecvalder_mpower(m, tol)
%function [ok, funcname] = test_vecvalder_mpower(m, tol)
%
%run tests on vecvalder/mpower; compare with handcoded expectations.
%
%Both arguments are optional:
%   m: number of indep vars for derivatives (defaults to 10 if unspecified)
%   tol: absolute tolerance for error check (defaults to 1e-15 if unspecified)
%
%Return values:
%   ok: 1 if everything passes, 0 otherwise.
%   funcname: always set to 'mpower()'
%
%This function tests:
%   scalar_vecvalder^scalar_numeric
%   scalar_numeric^scalar_vecvalder
%   scalar_vecvalder^scalar_vecvalder
%
%   Note that vector^scalar, scalar^vector, and vector^vector do not make sense.
%
%It uses vecvalder(), val() and jac(), which get tested as well.
%
%Author: JR, 2014/06/18

    n = 1;
	if nargin < 1
		m = 10;
	end
	if nargin < 2
		tol = 1e-15;
	end

	funcname = 'mpower()';
    ok = 1;
    offset = 0.1; 

    % test scalar_vecvalder^scalar_numeric
    oof = offset+rand(1,1); oof2 = rand(1, m);
    u = vecvalder(oof, oof2);
    v = rand(1,1); % scalar
    h = u^v;
    hv = val(h); hJ = jac(h);
    % if h(u,v) = u^v, dh_dx = dh_du*du_dx + dh_dv*dv_dx
    % dh_du = v*u^(v-1) = v*h/u
    % dh_dv: log(h) = v*log(u) => h = e^{v*log(u)} => dh_dv = log(u)*h
    expected_hv = oof^v;
    expected_hJ = v*expected_hv/oof*oof2;
    ok = ok && (max(abs(hv-expected_hv)/n) <= tol); 
    if ~(1==ok) 
        fprintf(2, 'vv2 mpower: avg val error = %g', full(max(abs(hv-expected_hv))));
        return; 
    end
    ok = ok && (max(max(abs(hJ-expected_hJ))) <= tol); 
    if ~(1==ok) 
        fprintf(2, 'vv2 mpower: avg jac error = %g', ...
                                    full(max(max(abs(hJ-expected_hJ)))) );
        return; 
    end

    % test scalar_numeric^scalar_vecvalder
    oof = offset+rand(1,1); oof2 = rand(1, m);
    u = rand(1,1); % scalar
    v = vecvalder(oof, oof2);
    h = u^v;
    hv = val(h); hJ = jac(h);
    % if h(u,v) = u^v, dh_dx = dh_du*du_dx + dh_dv*dv_dx
    % dh_du = v*u^(v-1) = v*h/u
    % dh_dv: log(h) = v*log(u) => h = e^{v*log(u)} => dh_dv = log(u)*h
    expected_hv = u^oof;
    expected_hJ = log(u)*expected_hv*oof2;
    ok = ok && (max(abs(hv-expected_hv)/n) <= tol); 
    if ~(1==ok) 
        fprintf(2, 'vv2 mpower: avg val error = %g', full(max(abs(hv-expected_hv))));
        return; 
    end
    ok = ok && (max(max(abs(hJ-expected_hJ))) <= tol); 
    if ~(1==ok) 
        fprintf(2, 'vv2 mpower: avg jac error = %g', ...
                                    full(max(max(abs(hJ-expected_hJ)))) );
        return; 
    end

    % test scalar_vecvalder^scalar_vecvalder
    oof = offset+rand(1,1); oof2 = rand(1, m);
    poof = rand(1,1); poof2 = rand(1, m);
    u = vecvalder(oof, oof2);
    v = vecvalder(poof, poof2);
    h = u^v;
    hv = val(h); hJ = jac(h);
    % if h(u,v) = u^v, dh_dx = dh_du*du_dx + dh_dv*dv_dx
    % dh_du = v*u^(v-1) = v*h/u
    % dh_dv: log(h) = v*log(u) => h = e^{v*log(u)} => dh_dv = log(u)*h
    expected_hv = oof^poof;
    expected_hJ = poof*expected_hv/oof*oof2 + log(oof)*expected_hv*poof2;
    ok = ok && (max(abs(hv-expected_hv)/n) <= tol); 
    if ~(1==ok) 
        fprintf(2, 'vv2 mpower: avg val error = %g', full(max(abs(hv-expected_hv))));
        return; 
    end
    ok = ok && (max(max(abs(hJ-expected_hJ))) <= tol); 
    if ~(1==ok) 
        fprintf(2, 'vv2 mpower: avg jac error = %g', ...
                                    full(max(max(abs(hJ-expected_hJ)))) );
        return; 
    end
end
