function dobj = diode()
%function dobj = diode()
% just returns a structure dobj with a function-handle field f, called as
% follows:
%
%function [id, d_id] = dobj.f(vd, Is, Vt)
%
%the function is vectorized wrt vd
%
%	id = Is*(exp(vd/Vt) - 1);
%	if nargout > 1
%		d_id = Is*exp(vd/Vt)/Vt;
%	end
% end diode

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Type "help MAPPlicense" at the MATLAB/Octave prompt to see the license      %
%% for this software.                                                          %
%% Copyright (C) 2008-2013 Jaijeet Roychowdhury <jr@berkeley.edu>. All rights  %
%% reserved.                                                                   %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

	dobj.f = @f;
end % of diode "constructor"

function [id, d_id] = f(vd, Is, Vt)
%function [id, d_id] = diode(vd, Is, Vt)
%
%the function is vectorized wrt Vd
%
	id = Is*(exp(vd/Vt) - 1);
	if nargout > 1
		d_id = Is*exp(vd/Vt)/Vt;
	end
end % diode
