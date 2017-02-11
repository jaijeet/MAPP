function d_Qdiff = d_qDiffusion(vd, Is, Vt, tt)
%function d_Qdiff = d_qDiffusion(vd, Is, Vt, tt)
%	Used to calculate derivative of diffusion charge. 
%	Used in diodeModSpec and EbersMoll_BJT_ModSpec

  	d_id = d_diodeId(vd, Is, Vt);
  	d_Qdiff = tt*d_id;
end %d_qDiffusion 

function d_id = d_diodeId(vd, Is, Vt)
	% FIXME: un-hardcode these
	%kBoltz = 1.3806503e-23;
	%qElecCharge = 1.60217646e-19;
	%vt = kBoltz*T{1}/qElecCharge;

	d_id = Is/Vt*exp(vd/Vt);
end %d_diodeID

