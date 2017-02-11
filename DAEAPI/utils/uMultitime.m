function uout = uMultitime(ts, DAE)
%function uout = uMultitime([t1, ..., tm], DAE)
%evaluates all Multitime inputs of DAE at the artificial time values 
%t1, ..., tm, returning a column vector of size feval(DAE.ninputs, DAE).  The
%order of the values is given by feval(DAE.inputnames, DAE).
%
%Examples
%--------
%
% % set up DAE
% nsegs = 1; R = 1e3; C = 1e-6;
% DAE =  RClineDAEAPIv6('', nsegs, R, C);
%
% % set multitime input to the DAE
% uMtargs.A1 = 1; uMtargs.A2 = 1; uMtargs.f1=1e3; uMtargs.f2=1e1;
% uMtfunc = @(t1t2, args) args.A1*sin(2*pi*args.f1*t1t2(1)) + ...
%                         args.A2*sin(2*pi*args.f2*t1t2(2));
% feval(DAE.inputnames, DAE)
% DAE = feval(DAE.set_uMultitime, 'line driving voltage: E(t)', uMtfunc, ...
%             uMtargs, DAE);
% 
% % evaluate the DAE's Multitime inputs at some random times t1 and t2
% ts = rand(1,2);
% feval(DAE.uMultitime, ts, DAE)
%
%
%See also
%--------
%
% set_uMultitime.
%
%Notes:
%
%1. the way uMultitime operates is as follows:
%   - if DAE.vector_uMtfunc is set, then it is called first and uout is set to
%     its return value;
%     else: DAE.uMtfunc_default is called, uout is set to its return value
%   - then, each scalar uMtfunc in DAE.uMtfunclist is called, and the
%     appropriate entry of uout is overwritten
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Type "help MAPPlicense" at the MATLAB/Octave prompt to see the license      %
%% for this software.                                                          %
%% Copyright (C) 2008-2020 Jaijeet Roychowdhury <jr@berkeley.edu>. All rights  %
%% reserved.                                                                   %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


	if isempty(DAE.uMtfunc_updates.vector_uMtfunc)
		%uMtfunc_default = @(t, DAEarg) zeros(feval(DAEarg.ninputs,DAEarg), length(t));
		uout = feval(DAE.uMtfunc_default, ts, DAE);
	else
		uout = feval(DAE.uMtfunc_updates.vector_uMtfunc, ts, DAE.uMtfunc_updates.vector_uMtfunc_args);
	end

	nI = length(DAE.uMtfunc_updates.indices);
	for i=1:nI
		u = feval(DAE.uMtfunc_updates.uMtfunclist{i}, ts, DAE.uMtfunc_updates.uMtargslist{i});
		uout(DAE.uMtfunc_updates.indices(i),:) = u;
		%                                   ^
		%				                vectorized
	end
end % uMultitime
