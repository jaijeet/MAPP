function plotfuncWthreeArgs(funchandle, xvals, yvals, parm)
%function plotfuncWthreeArgs(funchandle, xvals, yvals, parm)
%   example: plotfuncWthreeArgs(@smoothmax, -1:0.05:1, -1:0.025:2, 0.01)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Type "help MAPPlicense" at the MATLAB/Octave prompt to see the license      %
%% for this software.                                                          %
%% Copyright (C) 2008-2013 Jaijeet Roychowdhury <jr@berkeley.edu>. All rights  %
%% reserved.                                                                   %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%





	outvals = feval(funchandle, xvals, yvals, parm);
	 % xvals will be made into a col vector, yvals into a row vector
	 % outvals will be of dimension length(xvals), length(yvals)
	%surf(yvals, xvals, outvals);
	mesh(yvals, xvals, outvals);
	axis tight; grid on;
	xlabel 'y';
	ylabel 'x';
	mystr = func2str(funchandle);
	zlabel(sprintf('%s(x,y,%g)', mystr, parm));
	%legend(sprintf('%s(x,%g)', func2str(funchandle), parm));
	title(sprintf('%s(%g:%g,%g:%g,%g)', mystr, ...
		min(xvals), max(xvals), min(yvals), max(yvals), parm));
end
% end function plotfuncWthreeArgs
