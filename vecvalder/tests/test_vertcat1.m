function [ok, funcname] = test_vertcat1()

	n = 1;

	funcname = 'vertcat[x;1]';
	tol = 1e-13;

	xd = -1 + 2*rand(n,1);

	x = vecvalder(xd, speye(n));

	y = [x;1];

	yd = double(y);

	yvals = yd(:,1);
	yderivs = full(yd(:,2:end));

	derivs = [...
	     1; ...
	     0 ...
	];

	err = norm(full([xd;1]-yvals));

	if (err < tol) && 0 == sum(sum(yderivs-derivs))
		ok = 1;
		%fprintf(2, 'passed: vecvalder %s on size %d vector\n', funcname, n);
	else
		ok = 0;
		%fprintf(2, 'FAILED: vecvalder: %s on size %d vector\n', funcname);
	end
