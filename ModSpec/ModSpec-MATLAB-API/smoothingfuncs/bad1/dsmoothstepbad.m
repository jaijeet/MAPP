%function out = dsmoothstep(x,smoothing)
%	d/dx smoothstep(x,smoothing)
function out = dsmoothstep(x,smoothing)
	out = 0.5/smoothing*dtanh(x/smoothing);
% end of dsmoothstep_dx
