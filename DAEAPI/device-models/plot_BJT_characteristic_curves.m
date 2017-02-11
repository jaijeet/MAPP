%Author: J. Roychowdhury <jr@berkeley.edu>, 2009/sometime
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Type "help MAPPlicense" at the MATLAB/Octave prompt to see the license      %
%% for this software.                                                          %
%% Copyright (C) 2008-2013 Jaijeet Roychowdhury <jr@berkeley.edu>. All rights  %
%% reserved.                                                                   %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%






alphaF = 0.99;
alphaR = 0.5;
IsF = 1e-12;
IsR = 1e-12;
VtF = 0.025;
VtR = 0.025;

NVCE = 50;
NVBE = 10;

% take VCEs over 0:1
VCEs = 0 + (0:NVCE)/NVCE*1;
VCEs = reshape(VCEs,1,[]);

% take VBEs logarithmically to make the forward diode current go to 10e-3 or so.
VBEs = VtF*log((0.5e-3 + (0:NVBE)/NVBE*(10e-3-0.5e-3))/IsF + 1);

figure;
hold on;
for i = 1:length(VBEs)
	VBE = ones(size(VCEs))*VBEs(i);
	[ICs, IBs] = EbersMoll_BJT(VBE, VCEs, IsF, VtF, IsR, VtR, alphaF, alphaR);
	plot(VCEs, ICs, '.-');
	legends{i} = sprintf('VBE=%g', VBEs(i));
end
xlabel('VCE');
ylabel('IC');
legend(legends);
title('Ebers-Moll BJT: IC vs VCE for various VBEs');
grid on; axis tight;
