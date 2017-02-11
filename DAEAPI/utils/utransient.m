function uout = utransient(t, DAE)
%function uout = utransient(t, DAE)
%evaluates all transient inputs of DAE at time t, returning a column vector of
%size feval(DAE.ninputs, DAE).  The order of the values is given by
%feval(DAE.inputnames, DAE).
%
%Examples
%--------
%
% % set up DAE
% nsegs = 1; R = 1e3; C = 1e-6;
% DAE =  RClineDAEAPIv6('', nsegs, R, C);
% 
% % set transient input to the DAE
% utargs.A = 1; utargs.f=1e3; utargs.phi=0;
% utfunc = @(t, args) args.A*sin(2*pi*args.f*t + args.phi);
% DAE = feval(DAE.set_utransient, utfunc, utargs, DAE);
%
% % evaluate the DAE's transient inputs at some random time
% t = rand;
% feval(DAE.utransient, t, DAE)
%
%
%See also
%--------
%
% set_utransient, transient, LMS.
%
%Notes:
%
%1. the way utransient operates is as follows:
%   - if DAE.vector_utfunc is set, then it is called first and uout is set to
%     its return value;
%     else: DAE.utfunc_default is called, uout is set to its return value
%   - then, each scalar utfunc in DAE.utfunclist is called, and the appropriate
%     entry of uout is overwritten
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Type "help MAPPlicense" at the MATLAB/Octave prompt to see the license      %
%% for this software.                                                          %
%% Copyright (C) 2008-2013 Jaijeet Roychowdhury <jr@berkeley.edu>. All rights  %
%% reserved.                                                                   %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%





	if isempty(DAE.utfunc_updates.vector_utfunc)
		%utfunc_default = @(t, DAEarg) zeros(feval(DAEarg.ninputs,DAEarg), length(t));
		uout = feval(DAE.utfunc_default, t, DAE);
	else
		uout = feval(DAE.utfunc_updates.vector_utfunc, t, DAE.utfunc_updates.vector_utfunc_args);
	end

	nI = length(DAE.utfunc_updates.indices);
	for i=1:nI
		u = feval(DAE.utfunc_updates.utfunclist{i}, t, DAE.utfunc_updates.utargslist{i});
		uout(DAE.utfunc_updates.indices(i),:) = u;
		%                                  ^
		%				vectorized
	end
end % utransient
