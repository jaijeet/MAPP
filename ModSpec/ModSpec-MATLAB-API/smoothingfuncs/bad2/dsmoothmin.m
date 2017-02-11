function [douta, doutb] = dsmoothmin(a, b, smoothing)
%function [douta, doutb] = dsmoothmin(a, b, smoothing)
% d/d[a,b] smoothmin(a,b,smoothing)
	la = length(a);
	a = reshape(a, [], 1)*ones(1, length(b)); % col vector * row_of_1s
	b = ones(la,1)*reshape(b, 1, []); % col of 1s * row vector
	%
	factor = smoothstep(b-a,smoothing);
	dfactorb = dsmoothstep(b-a,smoothing);
	dfactora = -dfactorb;
	% out = factor.*a + (1-factor).*b;
	%douta = dfactora .* a + factor - dfactora.*b;
	douta = dfactora .* (a-b) + factor;
	%doutb = dfactorb.*a + (1-factor) -dfactorb.*b;
	doutb = dfactorb.*(a-b) + (1-factor);
% end of dsmoothmin
