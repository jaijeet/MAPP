function [ok, funcname] = test_mod()

	n = 10;
	tol = 1e-14;

	funcname = 'mod(a,b)';

	xd = -1 + 2*rand(n,1);
	x = vecvalder(xd, speye(n));
	yd = -1 + 2*rand(n,1);
	y = vecvalder(yd, speye(n));

	ok = 1;

	modxdyd = mod(xd,yd);
	modxy = mod(x,y);

	ok = ok && (norm(full(modxdyd - val2mat(modxy))) < tol) && (norm(full(speye(n)- der2mat(modxy))) < tol);

	modxyd = mod(x,yd);
	ok = ok && (norm(full(modxdyd - val2mat(modxyd))) < tol) && (norm(full(speye(n)- der2mat(modxyd))) < tol);

	modxdy = mod(xd,y);
	ok = ok && (norm(full(modxdyd - val2mat(modxdy))) < tol) && (norm(full(der2mat(modxdy))) < tol);
end
