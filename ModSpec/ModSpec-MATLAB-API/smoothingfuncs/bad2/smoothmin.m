function out = smoothmin(a, b, smoothing)
%function out = smoothmin(a, b, smoothing)
% use smoothabs at the bottom to keep things consistent
% min(a, b) = step(b-a)*a + (1-step(b-a))*b;
%    a will be reshaped into a col vector, b into a row vector
%    out = smoothmin( a*row_of_1s, col_of_1s*b ) % outer product matrix
	la = length(a);
	a = reshape(a, [], 1)*ones(1, length(b)); % col vector * row_of_1s
	b = ones(la,1)*reshape(b, 1, []); % col of 1s * row vector
	factor = smoothstep(b-a,smoothing);
	out = factor.*a + (1-factor).*b;
% end of smoothmin
