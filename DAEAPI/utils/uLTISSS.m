function uout = uLTISSS(f, DAE)
%function uout = uLTISSS(f, DAE)
%
%Evaluates all LTISSS ("AC") inputs of DAE at frequency f, returning a column 
%vector of size feval(DAE.ninputs, DAE).  The order of the values is given by
%feval(DAE.inputnames, DAE).
%
%Examples
%--------
%
% nsegs = 5; R = 1e3; C = 1e-6;
% DAE =  RClineDAEAPIv6('', nsegs, R, C);
%
% % set AC analysis input as a function of frequency
% Ufargs.string = 'no args used';; % 
% Uffunc = @(f, args) ones(size(f)); % constant U(j 2 pi f) \equiv 1
% DAE = feval(DAE.set_uLTISSS, Uffunc, Ufargs, DAE);
%
% % show all AC inputs at random frequencies
% fs = rand(1, 10);
% feval(DAE.uLTISSS, fs, DAE)
%
%See also
%--------
%
% set_uLTISSS, LTISSS, ac, uQSS, set_uQSS, utransient, set_utransient
%
%Notes:
%1. the way uLTISSS operates is as follows:
%   - if DAE.vector_Uffunc is set, then it is called first and uout is set to
%     its return value;
%     else: DAE.Uffunc_default is called, uout is set to its return value
%   - then, each scalar utfunc in DAE.Uffunclist is called, and the appropriate
%     entry of uout is overwritten
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Type "help MAPPlicense" at the MATLAB/Octave prompt to see the license      %
%% for this software.                                                          %
%% Copyright (C) 2008-2013 Jaijeet Roychowdhury <jr@berkeley.edu>. All rights  %
%% reserved.                                                                   %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%





	if isempty(DAE.Uffunc_updates.vector_Uffunc)
		%Uffunc_default = @(f, DAEarg) zeros(feval(DAEarg.ninputs,DAEarg),length(f));
		uout = feval(DAE.Uffunc_default, f, DAE);
	else
		uout = feval(DAE.Uffunc_updates.vector_Uffunc, f, DAE.Uffunc_updates.vector_Uffunc_args);
	end

	nI = length(DAE.Uffunc_updates.indices);
	for i=1:nI
		u = feval(DAE.Uffunc_updates.Uffunclist{i}, f, DAE.Uffunc_updates.Ufargslist{i});
		uout(DAE.Uffunc_updates.indices(i),:) = u;
		%                                  ^
		%				vectorized
	end
end % uLTISSS
