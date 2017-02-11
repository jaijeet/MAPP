function out = vsrc_res_diode_f(x, xlim)
    u = 1;
    G = 1e3;
    out = diode_Id(xlim) + G * (x - u);
end % vsrc_res_diode_f

function Id = diode_Id(Vd)
    Is = 1e-12;
	Vt = 0.026;
	Id = Is * exp(Vd/Vt - 1);
end % diode_Id 
