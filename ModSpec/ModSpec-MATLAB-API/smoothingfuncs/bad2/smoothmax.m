function out = smoothmax(a, b, smoothing)
%function out = smoothmax(a, b, smoothing)
%  max(a, b) = step(a-b)*a + (1-step(a-b))*b;
%  both a and b can be vectors
%    a will be reshaped into a col vector, b into a row vector
%    out = smoothmax( a*row_of_1s, col_of_1s*b ) % outer product matrix
	la = length(a);
	a = reshape(a, [], 1)*ones(1, length(b)); % col vector * row_of_1s
	b = ones(la,1)*reshape(b, 1, []); % col of 1s * row vector
	factor = smoothstep(a-b,smoothing);
	out = factor.*a + (1-factor).*b;
	% above multiplication results in non-monotonicity of derivative
	% (see plots2.jpg) how to fix?
% end of smoothmax
