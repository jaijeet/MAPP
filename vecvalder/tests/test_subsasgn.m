function [ok, funcname] = test_subsasgn()

	n = 10;

	funcname = 'subsasgn';
	tol = 1e-13;

	xd = -1 + 2*rand(n,1);
	xdder = -1 + 2*rand(n,2*n);

	x = vecvalder(xd, xdder);

	ok = 1;

	y = vecvalder(rand(n,1), rand(n,2*n));

	y(1:3) = x(1:3);
	yv = val2mat(y);
	yder = der2mat(y);
	ok = ok && (norm(full(yv(1:3)-xd(1:3))) < tol) && (norm(full(yder(1:3,:)-xdder(1:3,:))) < tol);

	y(1:3,1) = x(5:7);
	yv = val2mat(y);
	yder = der2mat(y);
	ok = ok && (norm(full(yv(1:3)-xd(5:7))) < tol) && (norm(full(yder(1:3,:)-xdder(5:7,:))) < tol);

	y(1:3,:) = x(2:4);
	yv = val2mat(y);
	yder = der2mat(y);
	ok = ok && (norm(full(yv(1:3)-xd(2:4))) < tol) && (norm(full(yder(1:3,:)-xdder(2:4,:))) < tol);

	y(1:3) = 0;
	yv = val2mat(y);
	yder = der2mat(y);
	ok = ok && (norm(full(yv(1:3))) == 0) && (norm(full(yder(1:3,:))) == 0);
	
	y(4:6) = [1;1;1];
	yv = val2mat(y);
	yder = der2mat(y);
	ok = ok && (norm(full(yv(4:6)) -[1;1;1]) == 0) && (norm(full(yder(4:6,:))) == 0);
	
	clear y;
	y(1:3) = x(1:3);
	yv = val2mat(y);
	yder = der2mat(y);
	ok = ok && (norm(full(yv(1:3)-xd(1:3))) < tol) && (norm(full(yder(1:3,:)-xdder(1:3,:))) < tol);

	clear y;
	y(1:3) = x(8:end);
	yv = val2mat(y);
	yder = der2mat(y);
	ok = ok && (norm(full(yv(1:3)-xd(8:end))) < tol) && (norm(full(yder(1:3,:)-xdder(8:end,:))) < tol);

