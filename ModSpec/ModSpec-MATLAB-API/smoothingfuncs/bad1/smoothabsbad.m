%function out = smoothabs(x,smoothing)
%   abs(x) = x*sign(x)
function out = smoothabs(x,smoothing)
	out = x.*smoothsign(x,smoothing);
% end of smoothabs
