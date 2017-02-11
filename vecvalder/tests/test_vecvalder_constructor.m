function [ok, funcname] = test_vecvalder_constructor(n, m, tol)
%function [ok, funcname] = test_vecvalder_constructor(n, m, tol)
%
%run tests on the constructor; compare with handcoded expectations.
%
%Both arguments are optional:
%   n: size of vecvalder vector to test (defaults to 10 if unspecified)
%   m: number of indep vars for derivatives (defaults to n+1 if unspecified)
%   tol: absolute tolerance for error check (defaults to 0 if unspecified)
%
%Return values:
%   ok: 1 if everything passes, 0 otherwise.
%   funcname: always set to 'vecvalder()'
%
%This function tests:
%   vecvalder()
%   vecvalder(size_n_numeric_vector)
%   vecvalder(size_n_numeric_vector, 'indep')
%   vecvalder(size_n_numeric_vector, numeric_matrix)
%   vecvalder=size_n_vecvalder_w_m_indep_vars
%
%It uses val(), jac() and valjac(), which get tested as well.
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

	funcname = 'vecvalder()';
    ok = 1;

    % test vecvalder()
    vv = vecvalder();
    val_jac = valjac(vv);

    ok = ok && isempty(val_jac); if ~(1==ok) return; end

    % test vecvalder(size_n_numeric_vector)
    oof = rand(n,1);
    vv = vecvalder(oof);
    v = val(vv); J = jac(vv);
    ok = ok && ~sum(v-oof) && ~(sum(sum(J -eye(n)))); if ~(1==ok) return; end

    % test vecvalder(size_n_numeric_vector, 'indep')
    oof = rand(n,1);
    vv = vecvalder(oof, 'indep');
    v = val(vv); J = jac(vv);
    ok = ok && ~sum(v-oof) && ~(sum(sum(J -eye(n)))); if ~(1==ok) return; end

    % test vecvalder(size_n_numeric_vector, numeric_matrix)
    oof = rand(n,1);
    oof2 = rand(n,m);
    vv = vecvalder(oof, oof2);
    vJ = valjac(vv);
    v = vJ(:,1); J = vJ(:,2:end);
    ok = ok && ~sum(v-oof) && ~(sum(sum(J-oof2))); if ~(1==ok) return; end
    
    % test vecvalder = size_n_vecvalder_with_m_indep_vars
    vv2 = vv;
    v = val(vv2); J = jac(vv2);
    ok = ok && ~sum(v-oof) && ~(sum(sum(J-oof2))); if ~(1==ok) return; end
end
