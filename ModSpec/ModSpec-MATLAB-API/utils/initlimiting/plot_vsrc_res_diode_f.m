% vsrc_res_diode_f is fhat
% ftilde(x, xlimOld) = fhat(x, pnjlim(x, xlimOld)

clear;

limit_on = 1;

vt = 0.026;
Is=1e-12;
vcrit = vt * log(vt / (sqrt(2) * Is));
smoothing = 1e-5;

xlimOlds = -0.8:0.1:0.7;
xs = -0.8:0.01:2;

outf = zeros(length(xlimOlds), length(xs));
outdf = zeros(length(xlimOlds), length(xs));

for c = 1:length(xlimOlds)
	xlimOld = xlimOlds(c);
	for d = 1:length(xs)
		x = xs(d);
		if limit_on
			%xlim = pnjlim(xlimOld, x, vt, vcrit);
			%xlim = smoothpnjlim(xlimOld, x, vt, vcrit,smoothing);
			xlim = pnjlim_tianshi(xlimOld, x, vt, vcrit,smoothing);
		else
			xlim = x;
		end
        outf(c, d) = vsrc_res_diode_f(x, xlim);
		if limit_on
			% outdf(c, d) =  vsrc_res_diode_dfdx(x, xlim) + vsrc_res_diode_dfdxlim(x, xlim) * dpnjlim_dvbnew(xlimOld,x,vt,vcrit);
			% outdf(c, d) =  vsrc_res_diode_dfdx(x, xlim) + vsrc_res_diode_dfdxlim(x, xlim) * dsmoothpnjlim_dvbnew(xlimOld,x,vt,vcrit,smoothing);
			outdf(c, d) =  vsrc_res_diode_dfdx(x, xlim) + vsrc_res_diode_dfdxlim(x, xlim) * dpnjlim_tianshi_dvbnew(xlimOld,x,vt,vcrit,smoothing);
		else
			outdf(c, d) =  vsrc_res_diode_dfdx(x, xlim)...
		   	+ vsrc_res_diode_dfdxlim(x, xlim);
		end
		fprintf('.');
	end
end

figure;
surf(xs, xlimOlds, outf);

title 'ftilde(x, xold)';
xlabel 'xold'
ylabel 'x'
zlabel 'newx=ftilde(x,xold)';
view (10,40);

figure;
surf(xs, xlimOlds, outdf);

title 'dftilde\_dx(x, xold)';
xlabel 'xold'
ylabel 'x'
view (10,40);
