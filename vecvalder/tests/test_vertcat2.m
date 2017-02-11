function [ok, funcname] = test_vertcat2()

	n = 10;

	funcname = 'vertcat2';
	tol = 1e-13;

	xd = -1 + 2*rand(n,1);

	x = vecvalder(xd, speye(n));

	y = [ones(2,1);x(1:2:9);0];

	yd = double(y);

	yvals = yd(:,1);
	yderivs = full(yd(:,2:end));

	derivs = [...
		0     0     0     0     0     0     0     0     0     0; ...
		0     0     0     0     0     0     0     0     0     0; ...
		1     0     0     0     0     0     0     0     0     0; ...
		0     0     1     0     0     0     0     0     0     0; ...
		0     0     0     0     1     0     0     0     0     0; ...
		0     0     0     0     0     0     1     0     0     0; ...
		0     0     0     0     0     0     0     0     1     0; ...
		0     0     0     0     0     0     0     0     0     0 ...
	];

	err = norm(full([ones(2,1);xd(1);xd(3);xd(5);xd(7);xd(9);0]-yvals));

	if (err < tol) && 0 == sum(sum(yderivs-derivs))
		ok = 1;
		%fprintf(2, 'passed: vecvalder %s on size %d vector\n', funcname, n);
	else
		ok = 0;
		%fprintf(2, 'FAILED: vecvalder: %s on size %d vector\n', funcname);
	end
