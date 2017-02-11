%
%Author: Tianshi Wang <tianshi@berkeley.edu>, 2013/sometime
%

vto = 0.3;
nx = 50;
ndx = 51;
%dxs = (0:ndx)/ndx*6*Vt-3*Vt;
dxs = (0:ndx)/ndx*10*vto-5*vto;
xs = (0:nx)/nx*3*vto-1.5*vto;

for i = 1:length(xs)
	x = xs(i);
	for j = 1:length(dxs)
		dx = dxs(j);
		newdxs(i,j) = fetlim_dx(dx,x,vto);
	end
end

surf(dxs,xs,newdxs);

title 'FETLIM_DX(dx,x)';
ylabel 'xold'
xlabel 'dx'
zlabel 'newdx=FETLIM_DX(dx,x)';
view (10,40);

