%
%Author: Tianshi Wang <tianshi@berkeley.edu>, 2013/sometime
%

Vt = 0.025;
Vcrit = 0.6145;
nx = 50;
%dxs = (0:ndx)/ndx*6*Vt-3*Vt;
xs = (0:nx)/nx*5*Vcrit-1.5*Vcrit;
xsold = (0:nx)/nx*5*Vcrit-1.5*Vcrit;

for i = 1:length(xs)
	x = xs(i);
	for j = 1:length(xsold)
		xold = xsold(j);
		newxs(i,j) = pnjlim(xold,x,Vt,Vcrit);
		% newxs(i,j) = pnjlim(x,x,Vt,Vcrit);
	end
end

surf(xsold,xs,newxs);

title 'PNJLIM(xold,x)';
xlabel 'xold'
ylabel 'x'
zlabel 'newx=PNJLIM(xold,x)';
view (10,40);
