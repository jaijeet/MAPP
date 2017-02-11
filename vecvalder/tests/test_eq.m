function [ok, funcname] = test_eq()

	n = 10;

	funcname = 'eq: vv1 == vv2';

	xd = -1 + 2*rand(n,1);

	x = vecvalder(xd, speye(n));

	x1 = x(1:3);
	x2 = x(5:7);

	ok = 1;

	ok = ok && (prod((x1 == x1)*1,1));
	ok = ok && (~prod((x1 == x2)*1,1));

	if 0 == 1
		if 1 == ok
			fprintf(2, 'passed: vecvalder %s on size %d vector\n', funcname, n);
		else
			fprintf(2, 'FAILED: vecvalder: %s on size %d vector\n', ...
				funcname, n);
		end
	end
