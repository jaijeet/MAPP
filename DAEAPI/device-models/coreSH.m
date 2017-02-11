function [ID, dID_dVGS, dID_dVDS] = coreSH(VGS, VDS, beta, VT)
%function [ID, dID_dVGS, dID_dVDS] = coreSH(VGS, VDS, beta, VT)
%the function is vectorized wrt VDS (rows) and VGS (cols)
%VGS and VDS should be identically sized matrices.
%ID is a matrix of the same size: nVGS rows x nVDS cols
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Type "help MAPPlicense" at the MATLAB/Octave prompt to see the license      %
%% for this software.                                                          %
%% Copyright (C) 2008-2013 Jaijeet Roychowdhury <jr@berkeley.edu>. All rights  %
%% reserved.                                                                   %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%






	% non-vectorized version: commented out
	% if (VGS < VT)
	% 	% off
	% 	ID = 0*VDS; % return vector
	% 	dID_dVGS = 0;
	% 	dID_dVDS = 0;
	% elseif (VGS <= VDS + VT)
	% 	% active
	% 	ID =beta/2*(VGS-VT)^2 
	% 	dID_dVGS = beta*(VGS-VT);
	% 	dID_dVDS = 0;
	% else % VGS > VDS+VT
	% 	% triode
	% 	ID = beta*VDS*(VGS-VT-VDS/2);
	% 	dID_dVGS = beta*VDS;
	% 	dID_dVDS = beta*(VGS-VT-VDS/2) - beta*VDS/2
	% 		 = beta*(VGS-VT) - beta*VDS = beta*(VGS-VT-VDS)
	% end

	% vectorized version
	notoff = (VGS >= VT); % vector/matrix (of size VGS) of 0s/1s 
	active = (VGS <= VDS + VT); % vector/matrix (of size VDS) of 0s/1s 
	triode = 1-active;

	ID = notoff.*(active.*(beta/2*(VGS-VT).^2) + ... 
			triode.*beta.*VDS.*(VGS-VT-VDS/2));

	if nargout >= 2
		dID_dVGS = notoff.*(active.*beta.*(VGS-VT) + ...
			triode.*beta.*VDS);
	end % if

	if nargout == 3
		dID_dVDS = notoff.*triode.*beta.*(VGS-VT-VDS);
	end % if

