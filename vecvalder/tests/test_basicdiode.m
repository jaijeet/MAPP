function [ok, funcname] = test_basicdiode(n)

	if nargin < 1
		n = 10;
	end

	funcname = 'basicdiode()';
	tol = 1e-13;

	xd = 0.6*rand(n,1);

	x = vecvalder(xd, speye(n));

	diode = basicdiode;
	Is = 1e-12;
	Vt = 0.025;
	y = feval(diode.f, x, Is, Vt);

	yd = double(y);

	yval = yd(:,1);
	yderivs = diag(yd(:,2:end));

	[oof, dIds] = feval(diode.f, xd, Is, Vt);

	err = norm(full(yderivs- dIds));

	if err < tol
		ok = 1;
		%fprintf(2, 'passed: vecvalder %s on size %d vector\n', funcname, n);
	else
		%fprintf(2, 'FAILED: vecvalder: %s on size %d vector\n', funcname, n);
		ok = 0;
	end
