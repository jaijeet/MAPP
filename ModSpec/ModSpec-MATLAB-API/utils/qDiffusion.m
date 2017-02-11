function Qdiff = qDiffusion(vd, Is, Vt, tt)
%function Qdiff = qDiffusion(vd, Is, Vt, tt)
%	Used to calculate diffusion charge. 
%	Used in diodeModSpec and EbersMoll_BJT_ModSpec
  	id = diodeId(vd, Is, Vt);
  	Qdiff = tt*id;
end %qDiffusion 

function id = diodeId(vd, Is, Vt)
	% FIXME: un-hardcode these
	%kBoltz = 1.3806503e-23;
	%qElecCharge = 1.60217646e-19;
	%vt = kBoltz*T{1}/qElecCharge;

	id = Is*(exp(vd/Vt) - 1);
end %diodeID

