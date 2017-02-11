function out = vsrc_res_diode_dfdxlim(x, xlim)
    out = ddiode_Id(xlim);
end % vsrc_res_diode_f

function Id = ddiode_Id(Vd)
    Is = 1e-12;
	Vt = 0.026;
	Id = Is * exp(Vd/Vt - 1) / Vt;
end % ddiode_Id 


