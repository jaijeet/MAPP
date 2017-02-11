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
ndx = 51;
%dxs = (0:ndx)/ndx*6*Vt-3*Vt;
%dxs = (0:ndx)/ndx*10*Vcrit-5*Vcrit;
%xs = (0:nx)/nx*3*Vcrit-1.5*Vcrit;
dxs = -2:0.1:2;
xs = -1:0.1:1;

for i = 1:length(xs)
	x = xs(i);
	for j = 1:length(dxs)
		dx = dxs(j);
		newdxs(i,j) = pnjlim_dx(dx,x,Vt,Vcrit);
	end
end

surf(dxs,xs,newdxs);

title 'PNJLIM(dx,x)';
ylabel 'xold'
xlabel 'dx'
zlabel 'newdx=PNJLIM(dx,x)';
view (10,40);
