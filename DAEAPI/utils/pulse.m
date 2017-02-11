function out = pulse(t, td, thi, tfs, tfe)
%function out = pulse(t, td, thi, tfs, tfe)
%This function returns the output of a 1-periodic unit pulse signal at a
%specified time instance (or vector of time instances).
%
%Only the first argument is mandatory.
%
%INPUT args:
%   t           - time 
%   td          - initial delay (default 0)
%   thi         - time at which pulse reaches 1 (default 0.1)
%   tfs         - time at which falling edge starts (default 0.5)
%   tfe         - time at which falling edge ends (default 0.6)
%
%OUTPUT:
%   out         - output of a periodic pulse signal at t
%
%EXAMPLE (50% duty cycle 1Khz pulse stream): 
%   pulse(t/1e-3, 0, 0.1, 0.5, 0.6);

%JR, 2017/02/09: added code to make args 2-5 optional.
%Author: Jaijeet Roychowdhury <jr@berkeley.edu> circa 2008, or before
% 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Type "help MAPPlicense" at the MATLAB/Octave prompt to see the license      %
%% for this software.                                                          %
%% Copyright (C) 2008-2013 Jaijeet Roychowdhury <jr@berkeley.edu>. All rights  %
%% reserved.                                                                   %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%





%
	t = t - floor(t);
    
    if nargin < 5
        tfe = 0.6;
    end
    if nargin < 4
        tfs = 0.5;
    end
    if nargin < 3
        thi = 0.1;
    end
    if nargin < 2
        td = 0;
    end

	if 0 == 1 % vanilla implementation
		if (t < td)
			out = 0;
		elseif t < thi
			out = (t-td)/(thi-td);
		elseif t < tfs
			out = 1;
		elseif t < tfe
			out = (tfe-t)/(tfe-tfs);
		else
			out = 0;
		end
	else % vectorized wrt t
		out = (t < td)*0 ...
		      + (t >= td).*(t < thi).*(t-td)/(thi-td) ...
		      + (t >= thi).*(t < tfs)*1 ... 
		      + (t >= tfs).*(t < tfe).*(tfe-t)/(tfe-tfs) ...
		      + (t >= tfe)*0;
	end
end % of pulse()
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
