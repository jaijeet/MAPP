%
%Author: J. Roychowdhury <jr@berkeley.edu>, 2011/sometime
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Author: J. Roychowdhury.
% Copyright (C) 2008-2012 Jaijeet Roychowdhury <jr@berkeley.edu>. All rights reserved.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

Vt = 0.025;
Vcrit = 0.6145;
nx = 50;
%dxs = (0:ndx)/ndx*6*Vt-3*Vt;
xs = (0:nx)/nx*3*Vcrit-1.5*Vcrit;
xsold = (0:nx)/nx*3*Vcrit-1.5*Vcrit;

for i = 1:length(xs)
	x = xs(i);
	for j = 1:length(xsold)
		xold = xsold(j);
		newxs(i,j) = dsmoothpnjlim_dx(xold,x,Vt,Vcrit, 1e-5);
	end
end

surf(xsold,xs,newxs);

title 'DPNJLIM\_DX(xold,x)';
xlabel 'xold'
ylabel 'x'
zlabel 'newx=DPNJLIM\_DX(xold,x)';
view (135,45);
