function [ok, funcname] = test_or()

	n = 3;

	funcname = 'or: vv1 | vv2';

	x = vecvalder([0;-2;0], rand(3,10));
	y = vecvalder([0;2;3], rand(3,10));


	ok = 1;

	xyor = x | y; % should be 0; 1; 1

	ok = xyor(1) == 0 && xyor(3) == 1 && xyor(2) == 1;

	if 0 == 1
		if 1 == ok
			fprintf(2, 'passed: vecvalder %s on size %d vector\n', funcname, n);
		else
			fprintf(2, 'FAILED: vecvalder: %s on size %d vector\n', ...
				funcname, n);
		end
	end
