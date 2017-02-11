function [ok, funcname] = test_cross1()

	funcname = 'cross subref';
	tol = 1e-13;

	xd = -1 + 2*rand(6,1);

	x = vecvalder(xd, speye(6));

	y = cross(x(1:3), x(4:6));

	yd = double(y);

	yvals = yd(:,1);
	yderivs = full(yd(:,2:end));

	x1 = xd(1);
	x2 = xd(2);
	x3 = xd(3);
	x4 = xd(4);
	x5 = xd(5);
	x6 = xd(6);
	derivs = [...
	     0, x6, -x5, 0, -x3, x2;
		 -x6, 0, x4, x3, 0, -x1;
		 x5, -x4, 0, -x2, x1, 0	];

	err = norm(full(cross(xd(1:3), xd(4:6))-yvals));

	if (err < tol) && 0 == sum(sum(yderivs-derivs))
		ok = 1;
		%fprintf(2, 'passed: vecvalder %s on size %d vector\n', funcname, n);
	else
		ok = 0;
		%fprintf(2, 'FAILED: vecvalder: %s on size %d vector\n', funcname);
	end
