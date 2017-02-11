function out = DAE_fqstruct (X, XLIM, U, DAE)

    out = DAE_qstruct (X, XLIM, DAE);

	%Tianshi: the only difference between fqstruct and fstruct is that fqstruct
	%allows U to be [] as when flag.f==0, U may be set to [] for evaluating q.
	%The original fstruct is kept because when U==[] but DAE has inputs, then
	%the code should report error instead of bypassing it.
	if ~isempty(U)
		% U -> inputnames
		for idx = 1 : 1 : length(DAE.inputnameList)
			eval ( ['out.', DAE.inputnameList{idx}, ' = U(idx,1);'] );
		end
	end
end
