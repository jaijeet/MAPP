function uout = uQSS(DAE)
%function uout = uQSS(DAE)
%returns a vector (of size feval(DAE.ninputs, DAE)) with the QSS ("DC") input
%values for all inputs. The order of the values is given by 
%feval(DAE.inputnames, DAE).
%
%Example
%-------
%
% DAE = vsrcRLCdiode_daeAPIv6();
% feval(DAE.inputnames, DAE)
% DAE = feval(DAE.set_uQSS, 'E', -1, DAE); % set DC value of E to -1V
% feval(DAE.uQSS, DAE)
%
%See also
%--------
%
% set_uQSS, utransient, uLTISSS, QSS, op, ac
%
%Notes:
%
%1. the way uQSS operates is as follows:
%   - uout is first set to DAE.uQSSvec_default
%   - then, each scalar update in DAE.uQSSvec_updates is applied: the
%     appropriate entry of uout is overwritten
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Type "help MAPPlicense" at the MATLAB/Octave prompt to see the license      %
%% for this software.                                                          %
%% Copyright (C) 2008-2013 Jaijeet Roychowdhury <jr@berkeley.edu>. All rights  %
%% reserved.                                                                   %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%






% uQSSvec_default is a static vector that has been set up in the constructor
% already
	uout = feval(DAE.uQSSvec_default, DAE);
	if length(DAE.uQSSvec_updates.indices) > 0
		uout(DAE.uQSSvec_updates.indices(:)) = DAE.uQSSvec_updates.values(:);
	end
end % uQSS
