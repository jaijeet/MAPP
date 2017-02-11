%Author: Jaijeet Roychowdhury <jr@berkeley.edu> 2008/sometime
% Test script for <TODO>
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Type "help MAPPlicense" at the MATLAB/Octave prompt to see the license      %
%% for this software.                                                          %
%% Copyright (C) 2008-2013 Jaijeet Roychowdhury <jr@berkeley.edu>. All rights  %
%% reserved.                                                                   %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%






function [sol, iters] = runNRonXsqrM4(initguess)
%run this with no args for help
	if 0 == nargin
		display('Usage: [sol, iters] = runNRonXsqrM4(initguess)');
		display('calls: [sol, iters] = NR(@tanhfunc,@dtanhfunc,initguess)');
		display('initguess = 3; % converges');
		return
	end


	xs = (0:100)/100*12 - 6;
	fs = xsqrM4(xs);

	figure;

	plot(xs, fs, '.-');

	title 'Plot of f(x) = x^2-4'
	xlabel 'x';
	ylabel 'f(x)';

	grid on;

	hold on;

	stem(initguess, xsqrM4(initguess));

	[sol, iters, success] = NR(@xsqrM4,[],initguess,[]);

	stem(sol, xsqrM4(sol), 'rh');
end

function [g, J] = xsqrM4(x, args)
	g = x.^2 - 4.0;
	J = 2*x;
end
