function plotfuncWtwoArgs(funchandle, xvals, parm)
%function plotfuncWtwoArgs(funchandle, xvals, parm)
%   example: plotfuncWtwoArgs(@smoothclip, -1:0.05:1, 0.1)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Type "help MAPPlicense" at the MATLAB/Octave prompt to see the license      %
%% for this software.                                                          %
%% Copyright (C) 2008-2013 Jaijeet Roychowdhury <jr@berkeley.edu>. All rights  %
%% reserved.                                                                   %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%





	outvals = feval(funchandle, xvals, parm);
	plot(xvals, outvals);
	axis tight; grid on;
	xlabel 'x';
	mystr = func2str(funchandle);
	ylabel(sprintf('%s(x,%g)', mystr, parm));
	%legend(sprintf('%s(x,%g)', func2str(funchandle), parm));
	title(sprintf('%s(%g:%g,%g)', mystr, ...
		min(xvals), max(xvals), parm));
end
% end function plotfuncWtwoArgs
