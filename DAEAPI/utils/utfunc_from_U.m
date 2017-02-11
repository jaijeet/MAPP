function outs = utfunc_from_U(ts, arg)
%function outs = utfunc_from_U(ts, arg)
%This function evaluates u(t) specified by Fourier coeffs at timepoints ts.
%
%INPUT args:
%   ts              - time (scalar or vector)
%   arg             - should contain the following fields
%       .f          - fundamental frequency for the Fourier coefficients 
%       .U_twoD     - a 2-D representation (size ni x N) of the Fourier coeffs
%                     of u(t). The ith row should contain the Fourier coeffs of
%                     u_i(t) in standard FFT order.
%
%if ts is scalar, outs = u(ts) is a column vector of size ni. If ts is
%a vector of timepoints, out is a matrix of size ni x length(ts).
%The ith column of outs corresponds to u(ts(i)).

%Author: Jaijeet Roychowdhury <jr@berkeley.edu> 2012/06/08
% 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Type "help MAPPlicense" at the MATLAB/Octave prompt to see the license      %
%% for this software.                                                          %
%% Copyright (C) 2008-2013 Jaijeet Roychowdhury <jr@berkeley.edu>. All rights  %
%% reserved.                                                                   %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%





	ni = size(arg.U_twoD,1);
	N = size(arg.U_twoD,2);
	if 1 ~= mod(N,2)
		fprintf('utransient_from_U: error: N is even.\n');
		outs = [];
		return;
	end
	M = (N-1)/2;
	Fidxs = [0:M, -M:-1];
	jay = 1i;
	% make sure ts is a row vector
	ts = reshape(ts, 1, []);
	exps = exp(jay*2*pi*arg.f*Fidxs.' * ts); % matrix of size N x length(ts)
	outs = real(arg.U_twoD * exps);
end
