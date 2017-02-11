function out = magH2(freq, R, C)
% mag^2 of the RC transfer function

out = R^2./(1+((2*pi*freq).^2).*R^2*C^2);
