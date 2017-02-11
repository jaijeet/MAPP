function [ok, funcname] = test_ne()

	n = 10;

	funcname = 'neq: vv1 ~= vv2';

	xd = -1 + 2*rand(n,1);

	x = vecvalder(xd, speye(n));

	x1 = x(1:3);
	x2 = x(5:7);

	ok = 1;

	ok = ok && (sum(x1 ~= x2));
	ok = ok && ~(sum(x1 ~= x1));

	if 0 == 1
		if 1 == ok
			fprintf(2, 'passed: vecvalder %s on size %d vector\n', funcname, n);
		else
			fprintf(2, 'FAILED: vecvalder: %s on size %d vector\n', ...
				funcname, n);
		end
	end
