function [ok, funcname] = test_vecvalder_log10(n, m, tol)
%function [ok, funcname] = test_vecvalder_log10(n, m, tol)
%
%run tests on vecvalder/log10; compare with handcoded expectations.
%
%Both arguments are optional:
%   n: size of vecvalder vector to test (defaults to 10 if unspecified)
%   m: number of indep vars for derivatives (defaults to n+1 if unspecified)
%   tol: absolute tolerance for error check (defaults to 1e-15 if unspecified)
%
%Return values:
%   ok: 1 if everything passes, 0 otherwise.
%   funcname: always set to 'log10()'
%
%This function tests:
%   log(size_n_vecvalder_w_m_indep_vars)
%
%It uses log(), vecvalder(), val() and jac(), which get tested as well.
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

	funcname = 'log10()';
    ok = 1;

    % test log10(size_n_vecvalder_w_m_indep_vars)
    oof = 0.20+rand(n,1); % anything more than 0.1474 should be safe enough
    oof2 = rand(n, m);
    vv = vecvalder(oof, oof2);
    vv2 = log10(vv);
    v = val(vv2); J = jac(vv2);
    % if y = log10(u) => 10^y = u => (e^log(10))^y = u => e^(y*log(10))=u
    % => log(u) = y*log(10) => y = log(u)/log(10)
    logvv = log(vv);
    expected_v = val(logvv)/log(10);
    expected_J = jac(logvv)/log(10);
    ok = ok && (abs(sum(v-expected_v)) <= tol); 
    if ~(1==ok) 
        fprintf(2, '%s: value error = %g\n', funcname, full(abs(sum(v-expected_v))));
        return; 
    end
    ok = ok && (abs(sum(sum(J-expected_J)))/m/n <= tol);
    if ~(1==ok) 
        fprintf(2, '%s: avg jac error = %g\n', funcname, ...
                                        full(abs(sum(sum(J-expected_J))))/m/n);
        return; 
    end
end
