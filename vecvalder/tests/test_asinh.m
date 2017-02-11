function [ok, funcname] = test_asinh(n)

	if nargin < 1
		n = 10;
	end

	funcname = 'asinh()';
	func = @asinh;
	dfunc = @dasinh;
	tol = 1e-13;

	xd = -1 + 2*rand(n,1);

	x = vecvalder(xd, speye(n));

	y = feval(func, x);

	yd = double(y);

	yval = yd(:,1);
	yderivs = diag(yd(:,2:end));

	err = norm(full(yderivs- feval(dfunc, xd)));

	if err < tol
		ok = 1;
		%fprintf(2, 'passed: vecvalder %s on size %d vector\n', funcname, n);
	else
		ok = 0;
		%fprintf(2, 'FAILED: vecvalder: %s on size %d vector\n', funcname);
	end

function out = dasinh(x)
	out = x;
	for c = 1:length(x)
		out(c) = 1/sqrt(1 + x(c)^2);
	end
