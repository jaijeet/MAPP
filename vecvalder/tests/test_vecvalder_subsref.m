function [ok, funcname] = test_vecvalder_subsref(n, m, tol)
%function [ok, funcname] = test_vecvalder_subsref(n, m, tol)
%
%run tests on vecvalder/subsref; compare with handcoded expectations.
%
%Both arguments are optional:
%   n: size of vecvalder vector to test (defaults to 10 if unspecified)
%   m: number of indep vars for derivatives (defaults to n+1 if unspecified)
%   tol: absolute tolerance for error check (defaults to 0 if unspecified)
%
%Return values:
%   ok: 1 if everything passes, 0 otherwise.
%   funcname: always set to 'subsref()'
%
%This function tests:
%   
%   vecvalder_n_by_m(i)
%   vecvalder_n_by_m(i,1)
%   vecvalder_n_by_m(i,:)
%   vecvalder_n_by_m(i:j)
%   vecvalder_n_by_m(i:j,1)
%   vecvalder_n_by_m(i:j,:)
%   vecvalder_n_by_m(:)
%   vecvalder_n_by_m(:,1)
%   vecvalder_n_by_m(:,:)
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

	funcname = 'subsref()';
    ok = 1;

    % test vecvalder_n_by_m(i)
    oof = rand(n,1); oof2 = rand(n, m);
    u = vecvalder(oof, oof2);
    i = floor(n/2)+1;
    h = u(i);
    hv = val(h); hJ = jac(h);
    expected_hv = oof(i);
    expected_hJ = oof2(i,:);
    ok = ok && (abs(sum(hv-expected_hv)) <= tol); 
    if ~(1==ok) 
        return; 
    end
    ok = ok && (abs(sum(sum(hJ-expected_hJ)))/m/n <= tol); 
    if ~(1==ok) 
        return; 
    end

    % test vecvalder_n_by_m(i,1)
    oof = rand(n,1); oof2 = rand(n, m);
    u = vecvalder(oof, oof2);
    i = floor(n/2)+1;
    h = u(i,1);
    hv = val(h); hJ = jac(h);
    expected_hv = oof(i);
    expected_hJ = oof2(i,:);
    ok = ok && (abs(sum(hv-expected_hv)) <= tol); 
    if ~(1==ok) 
        return; 
    end
    ok = ok && (abs(sum(sum(hJ-expected_hJ)))/m/n <= tol); 
    if ~(1==ok) 
        return; 
    end


    % test vecvalder_n_by_m(i,:)
    oof = rand(n,1); oof2 = rand(n, m);
    u = vecvalder(oof, oof2);
    i = floor(n/2)+1;
    h = u(i,:);
    hv = val(h); hJ = jac(h);
    expected_hv = oof(i);
    expected_hJ = oof2(i,:);
    ok = ok && (abs(sum(hv-expected_hv)) <= tol); 
    if ~(1==ok) 
        return; 
    end
    ok = ok && (abs(sum(sum(hJ-expected_hJ)))/m/n <= tol); 
    if ~(1==ok) 
        return; 
    end

    % test vecvalder_n_by_m(i:j)
    oof = rand(n,1); oof2 = rand(n, m);
    u = vecvalder(oof, oof2);
    i = floor(n/2)+1;
    j = n;
    h = u(i:j);
    hv = val(h); hJ = jac(h);
    expected_hv = oof(i:j);
    expected_hJ = oof2(i:j,:);
    ok = ok && (abs(sum(hv-expected_hv)) <= tol); 
    if ~(1==ok) 
        return; 
    end
    ok = ok && (abs(sum(sum(hJ-expected_hJ)))/m/n <= tol); 
    if ~(1==ok) 
        return; 
    end

    % test vecvalder_n_by_m(i:j,1)
    oof = rand(n,1); oof2 = rand(n, m);
    u = vecvalder(oof, oof2);
    i = floor(n/2)+1;
    j = n;
    h = u(i:j,1);
    hv = val(h); hJ = jac(h);
    expected_hv = oof(i:j);
    expected_hJ = oof2(i:j,:);
    ok = ok && (abs(sum(hv-expected_hv)) <= tol); 
    if ~(1==ok) 
        return; 
    end
    ok = ok && (abs(sum(sum(hJ-expected_hJ)))/m/n <= tol); 
    if ~(1==ok) 
        return; 
    end

    % test vecvalder_n_by_m(i:j,:)
    oof = rand(n,1); oof2 = rand(n, m);
    u = vecvalder(oof, oof2);
    i = floor(n/2)+1;
    j = n;
    h = u(i:j,:);
    hv = val(h); hJ = jac(h);
    expected_hv = oof(i:j);
    expected_hJ = oof2(i:j,:);
    ok = ok && (abs(sum(hv-expected_hv)) <= tol); 
    if ~(1==ok) 
        return; 
    end
    ok = ok && (abs(sum(sum(hJ-expected_hJ)))/m/n <= tol); 
    if ~(1==ok) 
        return; 
    end

    % test vecvalder_n_by_m(:)
    oof = rand(n,1); oof2 = rand(n, m);
    u = vecvalder(oof, oof2);
    h = u(:);
    hv = val(h); hJ = jac(h);
    expected_hv = oof(:);
    expected_hJ = oof2(:,:);
    ok = ok && (abs(sum(hv-expected_hv)) <= tol); 
    if ~(1==ok) 
        return; 
    end
    ok = ok && (abs(sum(sum(hJ-expected_hJ)))/m/n <= tol); 
    if ~(1==ok) 
        return; 
    end

    % test vecvalder_n_by_m(:,1)
    oof = rand(n,1); oof2 = rand(n, m);
    u = vecvalder(oof, oof2);
    h = u(:,1);
    hv = val(h); hJ = jac(h);
    expected_hv = oof(:);
    expected_hJ = oof2(:,:);
    ok = ok && (abs(sum(hv-expected_hv)) <= tol); 
    if ~(1==ok) 
        return; 
    end
    ok = ok && (abs(sum(sum(hJ-expected_hJ)))/m/n <= tol); 
    if ~(1==ok) 
        return; 
    end

    % test vecvalder_n_by_m(:,:)
    oof = rand(n,1); oof2 = rand(n, m);
    u = vecvalder(oof, oof2);
    h = u(:,:);
    hv = val(h); hJ = jac(h);
    expected_hv = oof(:);
    expected_hJ = oof2(:,:);
    ok = ok && (abs(sum(hv-expected_hv)) <= tol); 
    if ~(1==ok) 
        return; 
    end
    ok = ok && (abs(sum(sum(hJ-expected_hJ)))/m/n <= tol); 
    if ~(1==ok) 
        return; 
    end
end
