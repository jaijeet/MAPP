function [ok, funcname] = test_and()

	funcname = 'and: vv1 & vv2';

	x = vecvalder([0.1;-2;0], rand(3,10));
	y = vecvalder([0;2;3], rand(3,10));


	ok = 1;

	xyand = x & y; % should be 0; 1; 0

	ok = xyand(1) == 0 && xyand(3) == 0 && xyand(2) == 1;

	if 0 == 1
		if 1 == ok
			fprintf(2, 'passed: vecvalder %s on size %d vector\n', funcname, n);
		else
			fprintf(2, 'FAILED: vecvalder: %s on size %d vector\n', ...
				funcname, n);
		end
	end
