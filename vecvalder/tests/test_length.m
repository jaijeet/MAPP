function [ok, funcname] = test_length(n)

	if nargin < 1
		n = 10;
	end

	funcname = 'length()';
	func = @length;

	ok = 1;

	for c = 1:n
		xd = -1 + 2*rand(c,1);

		x = vecvalder(xd, speye(c));

		y = feval(func, x);

		yd = double(y);

		yval = yd(:,1);
		
		if yval == c
		else
			ok = 0;
		end
	end
