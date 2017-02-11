function [ok, funcname] = test_subsref_2()

	n = 10;

	funcname = 'subsref(1:3,1)';
	tol = 1e-13;

	xd = -1 + 2*rand(n,1);

	x = vecvalder(xd, speye(n));

	x1 = x(1:3,1);
	x2 = x(5:7,1);

	y = x1 + x2;

	yd = double(y);

	yvals = yd(:,1);
	yderivs = full(yd(:,2:end));

	derivs = [...
	     1     0     0     0     1     0     0     0     0     0; ...
	     0     1     0     0     0     1     0     0     0     0; ...
	     0     0     1     0     0     0     1     0     0     0; ...
	];

        x1 = xd(1:3);
        x2 = xd(5:7);

	err = norm(full(x1+x2-yvals));

	if (err < tol) && 0 == sum(sum(yderivs-derivs))
		ok = 1;
		%fprintf(2, 'passed: vecvalder %s on size %d vector\n', funcname, n);
	else
		ok = 0;
		%fprintf(2, 'FAILED: vecvalder: %s on size %d vector\n', funcname);
	end
