%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Type "help MAPPlicense" at the MATLAB/Octave prompt to see the license      %
%% for this software.                                                          %
%% Copyright (C) 2008-2013 Jaijeet Roychowdhury <jr@berkeley.edu>. All rights  %
%% reserved.                                                                   %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%






Vt = 0.025;
Vcrit = 0.6145;
nx = 50;
ndx = 51;
%dxs = (0:ndx)/ndx*6*Vt-3*Vt;
dxs = (0:ndx)/ndx*10*Vcrit-5*Vcrit;
xs = (0:nx)/nx*3*Vcrit-1.5*Vcrit;

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
