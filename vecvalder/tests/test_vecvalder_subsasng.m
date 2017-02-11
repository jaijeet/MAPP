function [ok, funcname] = test_vecvalder_subsasgn(n, m, tol)
%function [ok, funcname] = test_vecvalder_subsasgn(n, m, tol)
%
%run tests on vecvalder/subsasgn; compare with handcoded expectations.
%
%Both arguments are optional:
%   n: size of vecvalder vector to test (defaults to 10 if unspecified)
%   m: number of indep vars for derivatives (defaults to n+1 if unspecified)
%   tol: absolute tolerance for error check (defaults to 0 if unspecified)
%
%Return values:
%   ok: 1 if everything passes, 0 otherwise.
%   funcname: always set to 'subsasgn()'
%
%This function tests:
%   
%   vecvalder_n_by_m(i) = numeric_scalar
%   vecvalder_n_by_m(i,1) = numeric_scalar
%   vecvalder_n_by_m(i,:) = numeric_scalar
%   vecvalder_n_by_m(i) = vecvalder_scalar
%   vecvalder_n_by_m(i,1) = vecvalder_scalar
%   vecvalder_n_by_m(i,:) = vecvalder_scalar
%
%   vecvalder_n_by_m(i:j) = numeric_scalar
%   vecvalder_n_by_m(i:j,1) = numeric_scalar
%   vecvalder_n_by_m(i:j,:) = numeric_scalar
%   vecvalder_n_by_m(i:j) = vecvalder_scalar
%   vecvalder_n_by_m(i:j,1) = vecvalder_scalar
%   vecvalder_n_by_m(i:j,:) = vecvalder_scalar
%   vecvalder_n_by_m(i:j) = numeric_vector
%   vecvalder_n_by_m(i:j,1) = numeric_vector
%   vecvalder_n_by_m(i:j,:) = numeric_vector
%   vecvalder_n_by_m(i:j) = vecvalder_vector
%   vecvalder_n_by_m(i:j,1) = vecvalder_vector
%   vecvalder_n_by_m(i:j,:) = vecvalder_vector
%
%   vecvalder_n_by_m(:) = numeric_scalar
%   vecvalder_n_by_m(:,1) = numeric_scalar
%   vecvalder_n_by_m(:,:) = numeric_scalar
%   vecvalder_n_by_m(:) = vecvalder_scalar
%   vecvalder_n_by_m(:,1) = vecvalder_scalar
%   vecvalder_n_by_m(:,:) = vecvalder_scalar
%   vecvalder_n_by_m(:) = numeric_vector
%   vecvalder_n_by_m(:,1) = numeric_vector
%   vecvalder_n_by_m(:,:) = numeric_vector
%   vecvalder_n_by_m(:) = vecvalder_vector
%   vecvalder_n_by_m(:,1) = vecvalder_vector
%   vecvalder_n_by_m(:,:) = vecvalder_vector
%
%   nonexistent vecvalder(i) = vecvalder_scalar;
%   nonexistent vecvalder(i,1) = vecvalder_scalar;
%   nonexistent vecvalder(i,:) = vecvalder_scalar;
%   nonexistent vecvalder(i:j) = vecvalder_scalar;
%   nonexistent vecvalder(i:j,1) = vecvalder_scalar;
%   nonexistent vecvalder(i:j,:) = vecvalder_scalar;
%   nonexistent vecvalder(:,1) = vecvalder_scalar;
%   nonexistent vecvalder(:,:) = vecvalder_scalar;
%   
%   nonexistent vecvalder(i:j) = vecvalder_vector;
%   nonexistent vecvalder(i:j,1) = vecvalder_vector;
%   nonexistent vecvalder(i:j,:) = vecvalder_vector;
%   nonexistent vecvalder(:,1) = vecvalder_vector;
%   nonexistent vecvalder(:,:) = vecvalder_vector;
%
%   vecvalder_n_by_m(n+1) = numeric_scalar
%   vecvalder_n_by_m(n+1,1) = numeric_scalar
%   vecvalder_n_by_m(n+1,:) = numeric_scalar
%   vecvalder_n_by_m(n+1) = vecvalder_scalar
%   vecvalder_n_by_m(n+1,1) = vecvalder_scalar
%   vecvalder_n_by_m(n+1,:) = vecvalder_scalar
%
%   vecvalder_n_by_m(n+1:n+k) = numeric_scalar
%   vecvalder_n_by_m(n+1:n+k,1) = numeric_scalar
%   vecvalder_n_by_m(n+1:n+k,:) = numeric_scalar
%   vecvalder_n_by_m(n+1:n+k) = vecvalder_scalar
%   vecvalder_n_by_m(n+1:n+k,1) = vecvalder_scalar
%   vecvalder_n_by_m(n+1:n+k,:) = vecvalder_scalar
%
%   vecvalder_n_by_m(n+1:n+k) = numeric_vector
%   vecvalder_n_by_m(n+1:n+k,1) = numeric_vector
%   vecvalder_n_by_m(n+1:n+k,:) = numeric_vector
%   vecvalder_n_by_m(n+1:n+k) = vecvalder_vector
%   vecvalder_n_by_m(n+1:n+k,1) = vecvalder_vector
%   vecvalder_n_by_m(n+1:n+k,:) = vecvalder_vector
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

	funcname = 'subsasgn()';
    ok = 1;

    % test vecvalder_n_by_m(i) = numeric_scalar
    oof = rand(n,1); oof2 = rand(n, m);
    u = vecvalder(oof, oof2);
    i = floor(n/2)+1;
    v = rand(1,1);
    u(i) = v;
    hv = val(u); hJ = jac(u);
    expected_hv = oof; expected_hv(i) = v;
    expected_hJ = oof2; expected_hJ(i,:) = zeros(1,m);
    ok = ok && (abs(sum(hv-expected_hv)) <= tol); 
    if ~(1==ok) 
        return; 
    end
    ok = ok && (abs(sum(sum(hJ-expected_hJ)))/m/n <= tol); 
    if ~(1==ok) 
        return; 
    end

    % test vecvalder_n_by_m(i,1) = numeric_scalar
    oof = rand(n,1); oof2 = rand(n, m);
    u = vecvalder(oof, oof2);
    i = floor(n/2)+1;
    v = rand(1,1);
    u(i,1) = v;
    hv = val(u); hJ = jac(u);
    expected_hv = oof; expected_hv(i) = v;
    expected_hJ = oof2; expected_hJ(i,:) = zeros(1,m);
    ok = ok && (abs(sum(hv-expected_hv)) <= tol); 
    if ~(1==ok) 
        return; 
    end
    ok = ok && (abs(sum(sum(hJ-expected_hJ)))/m/n <= tol); 
    if ~(1==ok) 
        return; 
    end

    % test vecvalder_n_by_m(i,:) = numeric_scalar
    oof = rand(n,1); oof2 = rand(n, m);
    u = vecvalder(oof, oof2);
    i = floor(n/2)+1;
    v = rand(1,1);
    u(i,:) = v;
    hv = val(u); hJ = jac(u);
    expected_hv = oof; expected_hv(i) = v;
    expected_hJ = oof2; expected_hJ(i,:) = zeros(1,m);
    ok = ok && (abs(sum(hv-expected_hv)) <= tol); 
    if ~(1==ok) 
        return; 
    end
    ok = ok && (abs(sum(sum(hJ-expected_hJ)))/m/n <= tol); 
    if ~(1==ok) 
        return; 
    end

    % test vecvalder_n_by_m(i) = vecvalder_scalar
    oof = rand(n,1); oof2 = rand(n, m);
    u = vecvalder(oof, oof2);
    i = floor(n/2)+1;
    poof = rand(1,1); poof2 = rand(1,m);
    v = vecvalder(poof, poof2);
    u(i) = v;
    hv = val(u); hJ = jac(u);
    expected_hv = oof; expected_hv(i) = poof;
    expected_hJ = oof2; expected_hJ(i,:) = poof2;
    ok = ok && (abs(sum(hv-expected_hv)) <= tol); 
    if ~(1==ok) 
        return; 
    end
    ok = ok && (abs(sum(sum(hJ-expected_hJ)))/m/n <= tol); 
    if ~(1==ok) 
        return; 
    end

    % test vecvalder_n_by_m(i,1) = vecvalder_scalar
    oof = rand(n,1); oof2 = rand(n, m);
    u = vecvalder(oof, oof2);
    i = floor(n/2)+1;
    poof = rand(1,1); poof2 = rand(1,m);
    v = vecvalder(poof, poof2);
    u(i,1) = v;
    hv = val(u); hJ = jac(u);
    expected_hv = oof; expected_hv(i) = poof;
    expected_hJ = oof2; expected_hJ(i,:) = poof2;
    ok = ok && (abs(sum(hv-expected_hv)) <= tol); 
    if ~(1==ok) 
        return; 
    end
    ok = ok && (abs(sum(sum(hJ-expected_hJ)))/m/n <= tol); 
    if ~(1==ok) 
        return; 
    end

    % test vecvalder_n_by_m(i,:) = vecvalder_scalar
    oof = rand(n,1); oof2 = rand(n, m);
    u = vecvalder(oof, oof2);
    i = floor(n/2)+1;
    poof = rand(1,1); poof2 = rand(1,m);
    v = vecvalder(poof, poof2);
    u(i,1) = v;
    hv = val(u); hJ = jac(u);
    expected_hv = oof; expected_hv(i) = poof;
    expected_hJ = oof2; expected_hJ(i,:) = poof2;
    ok = ok && (abs(sum(hv-expected_hv)) <= tol); 
    if ~(1==ok) 
        return; 
    end
    ok = ok && (abs(sum(sum(hJ-expected_hJ)))/m/n <= tol); 
    if ~(1==ok) 
        return; 
    end

    % test vecvalder_n_by_m(i:j) = numeric_scalar
    oof = rand(n,1); oof2 = rand(n, m);
    u = vecvalder(oof, oof2);
    i = floor(n/2)+1;
    j = n;
    v = rand(1,1);
    u(i:j) = v;
    hv = val(u); hJ = jac(u);
    expected_hv = oof; expected_hv(i:j) = v;
    expected_hJ = oof2; expected_hJ(i:j,:) = zeros(abs(j-i)+1,m);
    ok = ok && (abs(sum(hv-expected_hv)) <= tol); 
    if ~(1==ok) 
        return; 
    end
    ok = ok && (abs(sum(sum(hJ-expected_hJ)))/m/n <= tol); 
    if ~(1==ok) 
        return; 
    end

    % test vecvalder_n_by_m(i:j,1) = numeric_scalar
    oof = rand(n,1); oof2 = rand(n, m);
    u = vecvalder(oof, oof2);
    i = floor(n/2)+1;
    j = n;
    v = rand(1,1);
    u(i:j,1) = v;
    hv = val(u); hJ = jac(u);
    expected_hv = oof; expected_hv(i:j) = v;
    expected_hJ = oof2; expected_hJ(i:j,:) = zeros(abs(j-i)+1,m);
    ok = ok && (abs(sum(hv-expected_hv)) <= tol); 
    if ~(1==ok) 
        return; 
    end
    ok = ok && (abs(sum(sum(hJ-expected_hJ)))/m/n <= tol); 
    if ~(1==ok) 
        return; 
    end

    % test vecvalder_n_by_m(i:j,:) = numeric_scalar
    oof = rand(n,1); oof2 = rand(n, m);
    u = vecvalder(oof, oof2);
    i = floor(n/2)+1;
    j = n;
    v = rand(1,1);
    u(i:j,:) = v;
    hv = val(u); hJ = jac(u);
    expected_hv = oof; expected_hv(i:j) = v;
    expected_hJ = oof2; expected_hJ(i:j,:) = zeros(abs(j-i)+1,m);
    ok = ok && (abs(sum(hv-expected_hv)) <= tol); 
    if ~(1==ok) 
        return; 
    end
    ok = ok && (abs(sum(sum(hJ-expected_hJ)))/m/n <= tol); 
    if ~(1==ok) 
        return; 
    end

    % test vecvalder_n_by_m(i:j) = vecvalder_scalar
    oof = rand(n,1); oof2 = rand(n, m);
    u = vecvalder(oof, oof2);
    i = floor(n/2)+1;
    j = n;
    poof = rand(1,1); poof2 = rand(1,m);
    v = vecvalder(poof, poof2);
    u(i:j) = v;
    hv = val(u); hJ = jac(u);
    expected_hv = oof; expected_hv(i:j) = poof;
    expected_hJ = oof2; expected_hJ(i:j,:) = ones(abs(j-i)+1,1)*poof2;
    ok = ok && (abs(sum(hv-expected_hv)) <= tol); 
    if ~(1==ok) 
        return; 
    end
    ok = ok && (abs(sum(sum(hJ-expected_hJ)))/m/n <= tol); 
    if ~(1==ok) 
        return; 
    end

    % test vecvalder_n_by_m(i:j,1) = vecvalder_scalar
    oof = rand(n,1); oof2 = rand(n, m);
    u = vecvalder(oof, oof2);
    i = floor(n/2)+1;
    j = n;
    poof = rand(1,1); poof2 = rand(1,m);
    v = vecvalder(poof, poof2);
    u(i:j,1) = v;
    hv = val(u); hJ = jac(u);
    expected_hv = oof; expected_hv(i:j) = poof;
    expected_hJ = oof2; expected_hJ(i:j,:) = ones(abs(j-i)+1,1)*poof2;
    ok = ok && (abs(sum(hv-expected_hv)) <= tol); 
    if ~(1==ok) 
        return; 
    end
    ok = ok && (abs(sum(sum(hJ-expected_hJ)))/m/n <= tol); 
    if ~(1==ok) 
        return; 
    end

    % test vecvalder_n_by_m(i:j,:) = vecvalder_scalar
    oof = rand(n,1); oof2 = rand(n, m);
    u = vecvalder(oof, oof2);
    i = floor(n/2)+1;
    j = n;
    poof = rand(1,1); poof2 = rand(1,m);
    v = vecvalder(poof, poof2);
    u(i:j,:) = v;
    hv = val(u); hJ = jac(u);
    expected_hv = oof; expected_hv(i:j) = poof;
    expected_hJ = oof2; expected_hJ(i:j,:) = ones(abs(j-i)+1,1)*poof2;
    ok = ok && (abs(sum(hv-expected_hv)) <= tol); 
    if ~(1==ok) 
        return; 
    end
    ok = ok && (abs(sum(sum(hJ-expected_hJ)))/m/n <= tol); 
    if ~(1==ok) 
        return; 
    end

    % test vecvalder_n_by_m(i:j) = numeric_vector
    oof = rand(n,1); oof2 = rand(n, m);
    u = vecvalder(oof, oof2);
    i = floor(n/2)+1;
    j = n;
    v = rand(abs(j-i)+1,1);
    u(i:j) = v;
    hv = val(u); hJ = jac(u);
    expected_hv = oof; expected_hv(i:j) = v;
    expected_hJ = oof2; expected_hJ(i:j,:) = zeros(abs(j-i)+1,m);
    ok = ok && (abs(sum(hv-expected_hv)) <= tol); 
    if ~(1==ok) 
        return; 
    end
    ok = ok && (abs(sum(sum(hJ-expected_hJ)))/m/n <= tol); 
    if ~(1==ok) 
        return; 
    end

    % test vecvalder_n_by_m(i:j,1) = numeric_vector
    oof = rand(n,1); oof2 = rand(n, m);
    u = vecvalder(oof, oof2);
    i = floor(n/2)+1;
    j = n;
    v = rand(abs(j-i)+1,1);
    u(i:j,1) = v;
    hv = val(u); hJ = jac(u);
    expected_hv = oof; expected_hv(i:j) = v;
    expected_hJ = oof2; expected_hJ(i:j,:) = zeros(abs(j-i)+1,m);
    ok = ok && (abs(sum(hv-expected_hv)) <= tol); 
    if ~(1==ok) 
        return; 
    end
    ok = ok && (abs(sum(sum(hJ-expected_hJ)))/m/n <= tol); 
    if ~(1==ok) 
        return; 
    end

    % test vecvalder_n_by_m(i:j,:) = numeric_vector
    oof = rand(n,1); oof2 = rand(n, m);
    u = vecvalder(oof, oof2);
    i = floor(n/2)+1;
    j = n;
    v = rand(abs(j-i)+1,1);
    u(i:j,1) = v;
    hv = val(u); hJ = jac(u);
    expected_hv = oof; expected_hv(i:j) = v;
    expected_hJ = oof2; expected_hJ(i:j,:) = zeros(abs(j-i)+1,m);
    ok = ok && (abs(sum(hv-expected_hv)) <= tol); 
    if ~(1==ok) 
        return; 
    end
    ok = ok && (abs(sum(sum(hJ-expected_hJ)))/m/n <= tol); 
    if ~(1==ok) 
        return; 
    end

    % test vecvalder_n_by_m(i:j) = vecvalder_vector
    oof = rand(n,1); oof2 = rand(n, m);
    u = vecvalder(oof, oof2);
    i = floor(n/2)+1;
    j = n;
    poof = rand(abs(j-i)+1,1); poof2 = rand(abs(j-i)+1,m);
    v = vecvalder(poof, poof2);
    u(i:j) = v;
    hv = val(u); hJ = jac(u);
    expected_hv = oof; expected_hv(i:j) = poof;
    expected_hJ = oof2; expected_hJ(i:j,:) = poof2;
    ok = ok && (abs(sum(hv-expected_hv)) <= tol); 
    if ~(1==ok) 
        return; 
    end
    ok = ok && (abs(sum(sum(hJ-expected_hJ)))/m/n <= tol); 
    if ~(1==ok) 
        return; 
    end

    % test vecvalder_n_by_m(i:j,1) = vecvalder_vector
    oof = rand(n,1); oof2 = rand(n, m);
    u = vecvalder(oof, oof2);
    i = floor(n/2)+1;
    j = n;
    poof = rand(abs(j-i)+1,1); poof2 = rand(abs(j-i)+1,m);
    v = vecvalder(poof, poof2);
    u(i:j,1) = v;
    hv = val(u); hJ = jac(u);
    expected_hv = oof; expected_hv(i:j) = poof;
    expected_hJ = oof2; expected_hJ(i:j,:) = poof2;
    ok = ok && (abs(sum(hv-expected_hv)) <= tol); 
    if ~(1==ok) 
        return; 
    end
    ok = ok && (abs(sum(sum(hJ-expected_hJ)))/m/n <= tol); 
    if ~(1==ok) 
        return; 
    end

    % test vecvalder_n_by_m(i:j,:) = vecvalder_vector
    oof = rand(n,1); oof2 = rand(n, m);
    u = vecvalder(oof, oof2);
    i = floor(n/2)+1;
    j = n;
    poof = rand(abs(j-i)+1,1); poof2 = rand(abs(j-i)+1,m);
    v = vecvalder(poof, poof2);
    u(i:j,:) = v;
    hv = val(u); hJ = jac(u);
    expected_hv = oof; expected_hv(i:j) = poof;
    expected_hJ = oof2; expected_hJ(i:j,:) = poof2;
    ok = ok && (abs(sum(hv-expected_hv)) <= tol); 
    if ~(1==ok) 
        return; 
    end
    ok = ok && (abs(sum(sum(hJ-expected_hJ)))/m/n <= tol); 
    if ~(1==ok) 
        return; 
    end

    % test vecvalder_n_by_m(:) = numeric_scalar
    oof = rand(n,1); oof2 = rand(n, m);
    u = vecvalder(oof, oof2);
    v = rand(1,1);
    u(:) = v;
    hv = val(u); hJ = jac(u);
    expected_hv = oof; expected_hv(:) = v;
    expected_hJ = oof2; expected_hJ(:,:) = zeros(n,m);
    ok = ok && (abs(sum(hv-expected_hv)) <= tol); 
    if ~(1==ok) 
        return; 
    end
    ok = ok && (abs(sum(sum(hJ-expected_hJ)))/m/n <= tol); 
    if ~(1==ok) 
        return; 
    end

    % test vecvalder_n_by_m(:,1) = numeric_scalar
    oof = rand(n,1); oof2 = rand(n, m);
    u = vecvalder(oof, oof2);
    v = rand(1,1);
    u(:,1) = v;
    hv = val(u); hJ = jac(u);
    expected_hv = oof; expected_hv(:) = v;
    expected_hJ = oof2; expected_hJ(:,:) = zeros(n,m);
    ok = ok && (abs(sum(hv-expected_hv)) <= tol); 
    if ~(1==ok) 
        return; 
    end
    ok = ok && (abs(sum(sum(hJ-expected_hJ)))/m/n <= tol); 
    if ~(1==ok) 
        return; 
    end

    % test vecvalder_n_by_m(:,:) = numeric_scalar
    oof = rand(n,1); oof2 = rand(n, m);
    u = vecvalder(oof, oof2);
    v = rand(1,1);
    u(:,:) = v;
    hv = val(u); hJ = jac(u);
    expected_hv = oof; expected_hv(:) = v;
    expected_hJ = oof2; expected_hJ(:,:) = zeros(n,m);
    ok = ok && (abs(sum(hv-expected_hv)) <= tol); 
    if ~(1==ok) 
        return; 
    end
    ok = ok && (abs(sum(sum(hJ-expected_hJ)))/m/n <= tol); 
    if ~(1==ok) 
        return; 
    end

    % test vecvalder_n_by_m(:) = vecvalder_scalar
    oof = rand(n,1); oof2 = rand(n, m);
    u = vecvalder(oof, oof2);
    poof = rand(1,1); poof2 = rand(1,m);
    v = vecvalder(poof, poof2);
    u(:) = v;
    hv = val(u); hJ = jac(u);
    expected_hv = oof; expected_hv(:) = poof;
    expected_hJ = oof2; expected_hJ(:,:) = ones(n,1)*poof2;
    ok = ok && (abs(sum(hv-expected_hv)) <= tol); 
    if ~(1==ok) 
        return; 
    end
    ok = ok && (abs(sum(sum(hJ-expected_hJ)))/m/n <= tol); 
    if ~(1==ok) 
        return; 
    end

    % test vecvalder_n_by_m(:,1) = vecvalder_scalar
    oof = rand(n,1); oof2 = rand(n, m);
    u = vecvalder(oof, oof2);
    poof = rand(1,1); poof2 = rand(1,m);
    v = vecvalder(poof, poof2);
    u(:,1) = v;
    hv = val(u); hJ = jac(u);
    expected_hv = oof; expected_hv(:) = poof;
    expected_hJ = oof2; expected_hJ(:,:) = ones(n,1)*poof2;
    ok = ok && (abs(sum(hv-expected_hv)) <= tol); 
    if ~(1==ok) 
        return; 
    end
    ok = ok && (abs(sum(sum(hJ-expected_hJ)))/m/n <= tol); 
    if ~(1==ok) 
        return; 
    end

    % test vecvalder_n_by_m(:,:) = vecvalder_scalar
    oof = rand(n,1); oof2 = rand(n, m);
    u = vecvalder(oof, oof2);
    poof = rand(1,1); poof2 = rand(1,m);
    v = vecvalder(poof, poof2);
    u(:,:) = v;
    hv = val(u); hJ = jac(u);
    expected_hv = oof; expected_hv(:) = poof;
    expected_hJ = oof2; expected_hJ(:,:) = ones(n,1)*poof2;
    ok = ok && (abs(sum(hv-expected_hv)) <= tol); 
    if ~(1==ok) 
        return; 
    end
    ok = ok && (abs(sum(sum(hJ-expected_hJ)))/m/n <= tol); 
    if ~(1==ok) 
        return; 
    end

    % test vecvalder_n_by_m(:) = numeric_vector
    oof = rand(n,1); oof2 = rand(n, m);
    u = vecvalder(oof, oof2);
    v = rand(n,1);
    u(:) = v;
    hv = val(u); hJ = jac(u);
    expected_hv = oof; expected_hv(:) = v;
    expected_hJ = oof2; expected_hJ(:,:) = zeros(n,m);
    ok = ok && (abs(sum(hv-expected_hv)) <= tol); 
    if ~(1==ok) 
        return; 
    end
    ok = ok && (abs(sum(sum(hJ-expected_hJ)))/m/n <= tol); 
    if ~(1==ok) 
        return; 
    end

    % test vecvalder_n_by_m(:,1) = numeric_vector
    oof = rand(n,1); oof2 = rand(n, m);
    u = vecvalder(oof, oof2);
    v = rand(n,1);
    u(:,1) = v;
    hv = val(u); hJ = jac(u);
    expected_hv = oof; expected_hv(:) = v;
    expected_hJ = oof2; expected_hJ(:,:) = zeros(n,m);
    ok = ok && (abs(sum(hv-expected_hv)) <= tol); 
    if ~(1==ok) 
        return; 
    end
    ok = ok && (abs(sum(sum(hJ-expected_hJ)))/m/n <= tol); 
    if ~(1==ok) 
        return; 
    end

    % test vecvalder_n_by_m(:,:) = numeric_vector
    oof = rand(n,1); oof2 = rand(n, m);
    u = vecvalder(oof, oof2);
    v = rand(n,1);
    u(:,:) = v;
    hv = val(u); hJ = jac(u);
    expected_hv = oof; expected_hv(:) = v;
    expected_hJ = oof2; expected_hJ(:,:) = zeros(n,m);
    ok = ok && (abs(sum(hv-expected_hv)) <= tol); 
    if ~(1==ok) 
        return; 
    end
    ok = ok && (abs(sum(sum(hJ-expected_hJ)))/m/n <= tol); 
    if ~(1==ok) 
        return; 
    end

    % test vecvalder_n_by_m(:) = vecvalder_vector
    oof = rand(n,1); oof2 = rand(n, m);
    u = vecvalder(oof, oof2);
    poof = rand(n,1); poof2 = rand(n,m);
    v = vecvalder(poof, poof2);
    u(:) = v;
    hv = val(u); hJ = jac(u);
    expected_hv = oof; expected_hv(:) = poof;
    expected_hJ = oof2; expected_hJ(:,:) = poof2;
    ok = ok && (abs(sum(hv-expected_hv)) <= tol); 
    if ~(1==ok) 
        return; 
    end
    ok = ok && (abs(sum(sum(hJ-expected_hJ)))/m/n <= tol); 
    if ~(1==ok) 
        return; 
    end

    % test vecvalder_n_by_m(:,1) = vecvalder_vector
    oof = rand(n,1); oof2 = rand(n, m);
    u = vecvalder(oof, oof2);
    poof = rand(n,1); poof2 = rand(n,m);
    v = vecvalder(poof, poof2);
    u(:,1) = v;
    hv = val(u); hJ = jac(u);
    expected_hv = oof; expected_hv(:) = poof;
    expected_hJ = oof2; expected_hJ(:,:) = poof2;
    ok = ok && (abs(sum(hv-expected_hv)) <= tol); 
    if ~(1==ok) 
        return; 
    end
    ok = ok && (abs(sum(sum(hJ-expected_hJ)))/m/n <= tol); 
    if ~(1==ok) 
        return; 
    end

    % test vecvalder_n_by_m(:,:) = vecvalder_vector
    oof = rand(n,1); oof2 = rand(n, m);
    u = vecvalder(oof, oof2);
    poof = rand(n,1); poof2 = rand(n,m);
    v = vecvalder(poof, poof2);
    u(:,:) = v;
    hv = val(u); hJ = jac(u);
    expected_hv = oof; expected_hv(:) = poof;
    expected_hJ = oof2; expected_hJ(:,:) = poof2;
    ok = ok && (abs(sum(hv-expected_hv)) <= tol); 
    if ~(1==ok) 
        return; 
    end
    ok = ok && (abs(sum(sum(hJ-expected_hJ)))/m/n <= tol); 
    if ~(1==ok) 
        return; 
    end


    % test nonexistent_vecvalder(i) = vecvalder_scalar
    i = floor(n/2)+1;
    poof = rand(1,1); poof2 = rand(1,m);
    v = vecvalder(poof, poof2);
    clear u;
    u(i) = v;
    hv = val(u); hJ = jac(u);
    clear expected_hv;
    clear expected_hJ;
    expected_hv(i,1) = poof; 
    expected_hJ(i,:) = poof2;
    ok = ok && (abs(sum(hv-expected_hv)) <= tol); 
    if ~(1==ok) 
        return; 
    end
    ok = ok && (abs(sum(sum(hJ-expected_hJ)))/m/n <= tol); 
    if ~(1==ok) 
        return; 
    end

    % test nonexistent_vecvalder(i,1) = vecvalder_scalar
    i = floor(n/2)+1;
    poof = rand(1,1); poof2 = rand(1,m);
    v = vecvalder(poof, poof2);
    clear u;
    u(i,1) = v;
    hv = val(u); hJ = jac(u);
    clear expected_hv;
    clear expected_hJ;
    expected_hv(i,1) = poof; 
    expected_hJ(i,:) = poof2;
    ok = ok && (abs(sum(hv-expected_hv)) <= tol); 
    if ~(1==ok) 
        return; 
    end
    ok = ok && (abs(sum(sum(hJ-expected_hJ)))/m/n <= tol); 
    if ~(1==ok) 
        return; 
    end

    % test nonexistent_vecvalder(i,:) = vecvalder_scalar
    i = floor(n/2)+1;
    poof = rand(1,1); poof2 = rand(1,m);
    v = vecvalder(poof, poof2);
    clear u;
    u(i,1) = v;
    hv = val(u); hJ = jac(u);
    clear expected_hv;
    clear expected_hJ;
    expected_hv(i,1) = poof; 
    expected_hJ(i,:) = poof2;
    ok = ok && (abs(sum(hv-expected_hv)) <= tol); 
    if ~(1==ok) 
        return; 
    end
    ok = ok && (abs(sum(sum(hJ-expected_hJ)))/m/n <= tol); 
    if ~(1==ok) 
        return; 
    end

    % test nonexistent_vecvalder(i:j) = vecvalder_scalar
    i = floor(n/2)+1;
    j = n;
    poof = rand(1,1); poof2 = rand(1,m);
    v = vecvalder(poof, poof2);
    clear u;
    u(i:j) = v;
    hv = val(u); hJ = jac(u);
    clear expected_hv;
    clear expected_hJ;
    expected_hv(i:j,1) = poof; 
    expected_hJ(i:j,:) = ones(abs(j-i)+1,1)*poof2;
    ok = ok && (abs(sum(hv-expected_hv)) <= tol); 
    if ~(1==ok) 
        return; 
    end
    ok = ok && (abs(sum(sum(hJ-expected_hJ)))/m/n <= tol); 
    if ~(1==ok) 
        return; 
    end

    % test nonexistent_vecvalder(i:j,1) = vecvalder_scalar
    i = floor(n/2)+1;
    j = n;
    poof = rand(1,1); poof2 = rand(1,m);
    v = vecvalder(poof, poof2);
    clear u;
    u(i:j,1) = v;
    hv = val(u); hJ = jac(u);
    clear expected_hv;
    clear expected_hJ;
    expected_hv(i:j,1) = poof; 
    expected_hJ(i:j,:) = ones(abs(j-i)+1,1)*poof2;
    ok = ok && (abs(sum(hv-expected_hv)) <= tol); 
    if ~(1==ok) 
        return; 
    end
    ok = ok && (abs(sum(sum(hJ-expected_hJ)))/m/n <= tol); 
    if ~(1==ok) 
        return; 
    end

    % test nonexistent_vecvalder(i:j,:) = vecvalder_scalar
    i = floor(n/2)+1;
    j = n;
    poof = rand(1,1); poof2 = rand(1,m);
    v = vecvalder(poof, poof2);
    clear u;
    u(i:j,:) = v;
    hv = val(u); hJ = jac(u);
    clear expected_hv;
    clear expected_hJ;
    expected_hv(i:j,1) = poof; 
    expected_hJ(i:j,:) = ones(abs(j-i)+1,1)*poof2;
    ok = ok && (abs(sum(hv-expected_hv)) <= tol); 
    if ~(1==ok) 
        return; 
    end
    ok = ok && (abs(sum(sum(hJ-expected_hJ)))/m/n <= tol); 
    if ~(1==ok) 
        return; 
    end

    % test nonexistent_vecvalder(:,1) = vecvalder_scalar
    poof = rand(1,1); poof2 = rand(1,m);
    v = vecvalder(poof, poof2);
    clear u;
    u(:,1) = v;
    hv = val(u); hJ = jac(u);
    clear expected_hv;
    clear expected_hJ;
    expected_hv(:,1) = poof; 
    expected_hJ(:,:) = poof2;
    ok = ok && (abs(sum(hv-expected_hv)) <= tol); 
    if ~(1==ok) 
        return; 
    end
    ok = ok && (abs(sum(sum(hJ-expected_hJ)))/m/n <= tol); 
    if ~(1==ok) 
        return; 
    end

    % test nonexistent_vecvalder(:,:) = vecvalder_scalar
    poof = rand(1,1); poof2 = rand(1,m);
    v = vecvalder(poof, poof2);
    clear u;
    u(:,:) = v;
    hv = val(u); hJ = jac(u);
    clear expected_hv;
    clear expected_hJ;
    expected_hv(:,1) = poof; 
    expected_hJ(:,:) = poof2;
    ok = ok && (abs(sum(hv-expected_hv)) <= tol); 
    if ~(1==ok) 
        return; 
    end
    ok = ok && (abs(sum(sum(hJ-expected_hJ)))/m/n <= tol); 
    if ~(1==ok) 
        return; 
    end

    % test nonexistent_vecvalder(i:j) = vecvalder_vector
    i = floor(n/2)+1;
    j = n;
    poof = rand(abs(j-i)+1,1); poof2 = rand(abs(j-i)+1,m);
    v = vecvalder(poof, poof2);
    clear u;
    u(i:j) = v;
    hv = val(u); hJ = jac(u);
    clear expected_hv;
    clear expected_hJ;
    expected_hv(i:j,1) = poof; 
    expected_hJ(i:j,:) = poof2;
    ok = ok && (abs(sum(hv-expected_hv)) <= tol); 
    if ~(1==ok) 
        return; 
    end
    ok = ok && (abs(sum(sum(hJ-expected_hJ)))/m/n <= tol); 
    if ~(1==ok) 
        return; 
    end


    % test nonexistent_vecvalder(i:j,1) = vecvalder_vector
    i = floor(n/2)+1;
    j = n;
    poof = rand(abs(j-i)+1,1); poof2 = rand(abs(j-i)+1,m);
    v = vecvalder(poof, poof2);
    clear u;
    u(i:j,1) = v;
    hv = val(u); hJ = jac(u);
    clear expected_hv;
    clear expected_hJ;
    expected_hv(i:j,1) = poof; 
    expected_hJ(i:j,:) = poof2;
    ok = ok && (abs(sum(hv-expected_hv)) <= tol); 
    if ~(1==ok) 
        return; 
    end
    ok = ok && (abs(sum(sum(hJ-expected_hJ)))/m/n <= tol); 
    if ~(1==ok) 
        return; 
    end


    % test nonexistent_vecvalder(i:j,:) = vecvalder_vector
    i = floor(n/2)+1;
    j = n;
    poof = rand(abs(j-i)+1,1); poof2 = rand(abs(j-i)+1,m);
    v = vecvalder(poof, poof2);
    clear u;
    u(i:j,:) = v;
    hv = val(u); hJ = jac(u);
    clear expected_hv;
    clear expected_hJ;
    expected_hv(i:j,1) = poof; 
    expected_hJ(i:j,:) = poof2;
    ok = ok && (abs(sum(hv-expected_hv)) <= tol); 
    if ~(1==ok) 
        return; 
    end
    ok = ok && (abs(sum(sum(hJ-expected_hJ)))/m/n <= tol); 
    if ~(1==ok) 
        return; 
    end

    % test nonexistent_vecvalder(:,1) = vecvalder_vector
    i = floor(n/2)+1;
    j = n;
    poof = rand(abs(j-i)+1,1); poof2 = rand(abs(j-i)+1,m);
    v = vecvalder(poof, poof2);
    clear u;
    u(:,1) = v;
    hv = val(u); hJ = jac(u);
    clear expected_hv;
    clear expected_hJ;
    expected_hv(:,1) = poof; 
    expected_hJ(:,:) = poof2;
    ok = ok && (abs(sum(hv-expected_hv)) <= tol); 
    if ~(1==ok) 
        return; 
    end
    ok = ok && (abs(sum(sum(hJ-expected_hJ)))/m/n <= tol); 
    if ~(1==ok) 
        return; 
    end

    % test nonexistent_vecvalder(:,:) = vecvalder_vector
    i = floor(n/2)+1;
    j = n;
    poof = rand(abs(j-i)+1,1); poof2 = rand(abs(j-i)+1,m);
    v = vecvalder(poof, poof2);
    clear u;
    u(:,:) = v;
    hv = val(u); hJ = jac(u);
    clear expected_hv;
    clear expected_hJ;
    expected_hv(:,1) = poof; 
    expected_hJ(:,:) = poof2;
    ok = ok && (abs(sum(hv-expected_hv)) <= tol); 
    if ~(1==ok) 
        return; 
    end
    ok = ok && (abs(sum(sum(hJ-expected_hJ)))/m/n <= tol); 
    if ~(1==ok) 
        return; 
    end

    % test vecvalder_n_by_m(n+1) = numeric_scalar
    oof = rand(n,1); oof2 = rand(n, m);
    u = vecvalder(oof, oof2);
    i = n+1;
    v = rand(1,1);
    u(i) = v;
    hv = val(u); hJ = jac(u);
    expected_hv = oof; expected_hv(i) = v;
    expected_hJ = oof2; expected_hJ(i,:) = zeros(1,m);
    ok = ok && (abs(sum(hv-expected_hv)) <= tol); 
    if ~(1==ok) 
        return; 
    end
    ok = ok && (abs(sum(sum(hJ-expected_hJ)))/m/n <= tol); 
    if ~(1==ok) 
        return; 
    end

    % test vecvalder_n_by_m(n+1,1) = numeric_scalar
    oof = rand(n,1); oof2 = rand(n, m);
    u = vecvalder(oof, oof2);
    i = n+1;
    v = rand(1,1);
    u(i,1) = v;
    hv = val(u); hJ = jac(u);
    expected_hv = oof; expected_hv(i) = v;
    expected_hJ = oof2; expected_hJ(i,:) = zeros(1,m);
    ok = ok && (abs(sum(hv-expected_hv)) <= tol); 
    if ~(1==ok) 
        return; 
    end
    ok = ok && (abs(sum(sum(hJ-expected_hJ)))/m/n <= tol); 
    if ~(1==ok) 
        return; 
    end

    % test vecvalder_n_by_m(n+1,:) = numeric_scalar
    oof = rand(n,1); oof2 = rand(n, m);
    u = vecvalder(oof, oof2);
    i = n+1;
    v = rand(1,1);
    u(i,:) = v;
    hv = val(u); hJ = jac(u);
    expected_hv = oof; expected_hv(i) = v;
    expected_hJ = oof2; expected_hJ(i,:) = zeros(1,m);
    ok = ok && (abs(sum(hv-expected_hv)) <= tol); 
    if ~(1==ok) 
        return; 
    end
    ok = ok && (abs(sum(sum(hJ-expected_hJ)))/m/n <= tol); 
    if ~(1==ok) 
        return; 
    end

    % test vecvalder_n_by_m(n+1) = vecvalder_scalar
    oof = rand(n,1); oof2 = rand(n, m);
    u = vecvalder(oof, oof2);
    i = n+1;
    poof = rand(1,1); poof2 = rand(1,m);
    v = vecvalder(poof, poof2);
    u(i) = v;
    hv = val(u); hJ = jac(u);
    expected_hv = oof; expected_hv(i) = poof;
    expected_hJ = oof2; expected_hJ(i,:) = poof2;
    ok = ok && (abs(sum(hv-expected_hv)) <= tol); 
    if ~(1==ok) 
        return; 
    end
    ok = ok && (abs(sum(sum(hJ-expected_hJ)))/m/n <= tol); 
    if ~(1==ok) 
        return; 
    end

    % test vecvalder_n_by_m(n+1,1) = vecvalder_scalar
    oof = rand(n,1); oof2 = rand(n, m);
    u = vecvalder(oof, oof2);
    i = n+1;
    poof = rand(1,1); poof2 = rand(1,m);
    v = vecvalder(poof, poof2);
    u(i,1) = v;
    hv = val(u); hJ = jac(u);
    expected_hv = oof; expected_hv(i) = poof;
    expected_hJ = oof2; expected_hJ(i,:) = poof2;
    ok = ok && (abs(sum(hv-expected_hv)) <= tol); 
    if ~(1==ok) 
        return; 
    end
    ok = ok && (abs(sum(sum(hJ-expected_hJ)))/m/n <= tol); 
    if ~(1==ok) 
        return; 
    end

    % test vecvalder_n_by_m(n+1,:) = vecvalder_scalar
    oof = rand(n,1); oof2 = rand(n, m);
    u = vecvalder(oof, oof2);
    i = n+1;
    poof = rand(1,1); poof2 = rand(1,m);
    v = vecvalder(poof, poof2);
    u(i,:) = v;
    hv = val(u); hJ = jac(u);
    expected_hv = oof; expected_hv(i) = poof;
    expected_hJ = oof2; expected_hJ(i,:) = poof2;
    ok = ok && (abs(sum(hv-expected_hv)) <= tol); 
    if ~(1==ok) 
        return; 
    end
    ok = ok && (abs(sum(sum(hJ-expected_hJ)))/m/n <= tol); 
    if ~(1==ok) 
        return; 
    end

    % test vecvalder_n_by_m(n+1:n+k) = numeric_scalar
    oof = rand(n,1); oof2 = rand(n, m);
    u = vecvalder(oof, oof2);
    i = n+1; k = 5; j = n+k;
    v = rand(1,1);
    u(i:j) = v;
    hv = val(u); hJ = jac(u);
    expected_hv = oof; expected_hv(i:j) = v;
    expected_hJ = oof2; expected_hJ(i:j,:) = zeros(abs(j-i)+1,m);
    ok = ok && (abs(sum(hv-expected_hv)) <= tol); 
    if ~(1==ok) 
        return; 
    end
    ok = ok && (abs(sum(sum(hJ-expected_hJ)))/m/n <= tol); 
    if ~(1==ok) 
        return; 
    end

    % test vecvalder_n_by_m(n+1:n+k,1) = numeric_scalar
    oof = rand(n,1); oof2 = rand(n, m);
    u = vecvalder(oof, oof2);
    i = n+1; k = 5; j = n+k;
    v = rand(1,1);
    u(i:j,1) = v;
    hv = val(u); hJ = jac(u);
    expected_hv = oof; expected_hv(i:j) = v;
    expected_hJ = oof2; expected_hJ(i:j,:) = zeros(abs(j-i)+1,m);
    ok = ok && (abs(sum(hv-expected_hv)) <= tol); 
    if ~(1==ok) 
        return; 
    end
    ok = ok && (abs(sum(sum(hJ-expected_hJ)))/m/n <= tol); 
    if ~(1==ok) 
        return; 
    end

    % test vecvalder_n_by_m(n+1:n+k,:) = numeric_scalar
    oof = rand(n,1); oof2 = rand(n, m);
    u = vecvalder(oof, oof2);
    i = n+1; k = 5; j = n+k;
    v = rand(1,1);
    u(i:j,:) = v;
    hv = val(u); hJ = jac(u);
    expected_hv = oof; expected_hv(i:j) = v;
    expected_hJ = oof2; expected_hJ(i:j,:) = zeros(abs(j-i)+1,m);
    ok = ok && (abs(sum(hv-expected_hv)) <= tol); 
    if ~(1==ok) 
        return; 
    end
    ok = ok && (abs(sum(sum(hJ-expected_hJ)))/m/n <= tol); 
    if ~(1==ok) 
        return; 
    end

    % test vecvalder_n_by_m(n+1:n+k) = vecvalder_scalar
    oof = rand(n,1); oof2 = rand(n, m);
    u = vecvalder(oof, oof2);
    i = n+1; k = 5; j = n+k;
    poof = rand(1,1); poof2 = rand(1,m);
    v = vecvalder(poof, poof2);
    u(i:j) = v;
    hv = val(u); hJ = jac(u);
    expected_hv = oof; expected_hv(i:j) = poof;
    expected_hJ = oof2; expected_hJ(i:j,:) = ones(abs(j-i)+1,1)*poof2;
    ok = ok && (abs(sum(hv-expected_hv)) <= tol); 
    if ~(1==ok) 
        return; 
    end
    ok = ok && (abs(sum(sum(hJ-expected_hJ)))/m/n <= tol); 
    if ~(1==ok) 
        return; 
    end

    % test vecvalder_n_by_m(n+1:n+k,1) = vecvalder_scalar
    oof = rand(n,1); oof2 = rand(n, m);
    u = vecvalder(oof, oof2);
    i = n+1; k = 5; j = n+k;
    poof = rand(1,1); poof2 = rand(1,m);
    v = vecvalder(poof, poof2);
    u(i:j,1) = v;
    hv = val(u); hJ = jac(u);
    expected_hv = oof; expected_hv(i:j) = poof;
    expected_hJ = oof2; expected_hJ(i:j,:) = ones(abs(j-i)+1,1)*poof2;
    ok = ok && (abs(sum(hv-expected_hv)) <= tol); 
    if ~(1==ok) 
        return; 
    end
    ok = ok && (abs(sum(sum(hJ-expected_hJ)))/m/n <= tol); 
    if ~(1==ok) 
        return; 
    end

    % test vecvalder_n_by_m(n+1:n+k,:) = vecvalder_scalar
    oof = rand(n,1); oof2 = rand(n, m);
    u = vecvalder(oof, oof2);
    i = n+1; k = 5; j = n+k;
    poof = rand(1,1); poof2 = rand(1,m);
    v = vecvalder(poof, poof2);
    u(i:j,:) = v;
    hv = val(u); hJ = jac(u);
    expected_hv = oof; expected_hv(i:j) = poof;
    expected_hJ = oof2; expected_hJ(i:j,:) = ones(abs(j-i)+1,1)*poof2;
    ok = ok && (abs(sum(hv-expected_hv)) <= tol); 
    if ~(1==ok) 
        return; 
    end
    ok = ok && (abs(sum(sum(hJ-expected_hJ)))/m/n <= tol); 
    if ~(1==ok) 
        return; 
    end

    % test vecvalder_n_by_m(n+1:n+k) = numeric_vector
    oof = rand(n,1); oof2 = rand(n, m);
    u = vecvalder(oof, oof2);
    i = n+1; k = 5; j = n+k;
    v = rand(abs(j-i)+1,1);
    u(i:j) = v;
    hv = val(u); hJ = jac(u);
    expected_hv = oof; expected_hv(i:j) = v;
    expected_hJ = oof2; expected_hJ(i:j,:) = zeros(abs(j-i)+1,m);
    ok = ok && (abs(sum(hv-expected_hv)) <= tol); 
    if ~(1==ok) 
        return; 
    end
    ok = ok && (abs(sum(sum(hJ-expected_hJ)))/m/n <= tol); 
    if ~(1==ok) 
        return; 
    end

    % test vecvalder_n_by_m(n+1:n+k,1) = numeric_vector
    oof = rand(n,1); oof2 = rand(n, m);
    u = vecvalder(oof, oof2);
    i = n+1; k = 5; j = n+k;
    v = rand(abs(j-i)+1,1);
    u(i:j,1) = v;
    hv = val(u); hJ = jac(u);
    expected_hv = oof; expected_hv(i:j) = v;
    expected_hJ = oof2; expected_hJ(i:j,:) = zeros(abs(j-i)+1,m);
    ok = ok && (abs(sum(hv-expected_hv)) <= tol); 
    if ~(1==ok) 
        return; 
    end
    ok = ok && (abs(sum(sum(hJ-expected_hJ)))/m/n <= tol); 
    if ~(1==ok) 
        return; 
    end

    % test vecvalder_n_by_m(n+1:n+k,:) = numeric_vector
    oof = rand(n,1); oof2 = rand(n, m);
    u = vecvalder(oof, oof2);
    i = n+1; k = 5; j = n+k;
    v = rand(abs(j-i)+1,1);
    u(i:j,:) = v;
    hv = val(u); hJ = jac(u);
    expected_hv = oof; expected_hv(i:j) = v;
    expected_hJ = oof2; expected_hJ(i:j,:) = zeros(abs(j-i)+1,m);
    ok = ok && (abs(sum(hv-expected_hv)) <= tol); 
    if ~(1==ok) 
        return; 
    end
    ok = ok && (abs(sum(sum(hJ-expected_hJ)))/m/n <= tol); 
    if ~(1==ok) 
        return; 
    end

    % test vecvalder_n_by_m(n+1:n+k) = vecvalder_vector
    oof = rand(n,1); oof2 = rand(n, m);
    u = vecvalder(oof, oof2);
    i = n+1; k = 5; j = n+k;
    poof = rand(abs(j-i)+1,1); poof2 = rand(abs(j-i)+1,m);
    v = vecvalder(poof, poof2);
    u(i:j) = v;
    hv = val(u); hJ = jac(u);
    expected_hv = oof; expected_hv(i:j) = poof;
    expected_hJ = oof2; expected_hJ(i:j,:) = poof2;
    ok = ok && (abs(sum(hv-expected_hv)) <= tol); 
    if ~(1==ok) 
        return; 
    end
    ok = ok && (abs(sum(sum(hJ-expected_hJ)))/m/n <= tol); 
    if ~(1==ok) 
        return; 
    end

    % test vecvalder_n_by_m(n+1:n+k,1) = vecvalder_vector
    oof = rand(n,1); oof2 = rand(n, m);
    u = vecvalder(oof, oof2);
    i = n+1; k = 5; j = n+k;
    poof = rand(abs(j-i)+1,1); poof2 = rand(abs(j-i)+1,m);
    v = vecvalder(poof, poof2);
    u(i:j,1) = v;
    hv = val(u); hJ = jac(u);
    expected_hv = oof; expected_hv(i:j) = poof;
    expected_hJ = oof2; expected_hJ(i:j,:) = poof2;
    ok = ok && (abs(sum(hv-expected_hv)) <= tol); 
    if ~(1==ok) 
        return; 
    end
    ok = ok && (abs(sum(sum(hJ-expected_hJ)))/m/n <= tol); 
    if ~(1==ok) 
        return; 
    end

    % test vecvalder_n_by_m(n+1:n+k,:) = vecvalder_vector
    oof = rand(n,1); oof2 = rand(n, m);
    u = vecvalder(oof, oof2);
    i = n+1; k = 5; j = n+k;
    poof = rand(abs(j-i)+1,1); poof2 = rand(abs(j-i)+1,m);
    v = vecvalder(poof, poof2);
    u(i:j,:) = v;
    hv = val(u); hJ = jac(u);
    expected_hv = oof; expected_hv(i:j) = poof;
    expected_hJ = oof2; expected_hJ(i:j,:) = poof2;
    ok = ok && (abs(sum(hv-expected_hv)) <= tol); 
    if ~(1==ok) 
        return; 
    end
    ok = ok && (abs(sum(sum(hJ-expected_hJ)))/m/n <= tol); 
    if ~(1==ok) 
        return; 
    end
end
