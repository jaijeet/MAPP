function out = dpnjlim_tianshi_dvbnew(vbold,vbnew,vt,vcrit,smoothing)
%function out = dpnjlim_tianshi_dvbnew(vbold,vbnew,vt,vcrit,smoothing)
%This function is not vectorized
%This function computes dpnjlim_dvbnew using vecvalder (automatic differentiation).
% for input arguments description, see help pnjlim

%Author: Tianshi Wang <tianshi@berkeley.edu> 2014/04/04
% 
	if 2 ~= exist('vecvalder', 'file') && 6 ~= exist('vecvalder', 'file')
		fprintf(2,'dpnjlim_dvbnew: vecvalder not found - aborting');
		out = [];
		return;
	end

	vvbnew = vecvalder(vbnew, 1);
	vvecLim = pnjlim_tianshi(vbold, vvbnew, vt, vcrit, smoothing); 

	if isa(vvecLim, 'vecvalder')
		out = der2mat(vvecLim);
	else
		warning('something wrong with dpnjlim_dvbnew...')
		out = 0;
	end
end
