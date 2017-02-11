clear all;
CM = 0;
CP = 0;
DL = 1;

%%%% current_mirror %%%%%
if CM == 1
	tic; test_STAEqnEngine_current_mirror_DC_tran(); t_STA_CM = toc;
	STA_CM_qss = qss;
	%STA_CM_ltisss = ltisss;
	STA_CM_Tran = LMSObj;
	tic; test_MNAEqnEngine_current_mirror_DC_tran(); t_MNA_CM = toc;
	MNA_CM_qss = qss;
	%MNA_CM_ltisss = ltisss;
	MNA_CM_Tran = LMSObj;
	close all;
	
	unk_names = MNA_CM_qss.DAE.unk_names;
	n_unks = length(unk_names);
	idx1 = 1:n_unks;
	idx2 = ones(n_unks,1);
	unk_names2 = STA_CM_qss.DAE.unk_names;
	for i=1:n_unks
		idx2(i) = find(strcmp(unk_names(i), unk_names2));
	end
	idx1_CM = idx1;
	idx2_CM = idx2;
end
%%%% charge_pump %%%%%
if CP == 1
	tic; test_STAEqnEngine_charge_pump_DC_tran(); t_STA_CP = toc;
	STA_CP_qss = qss;
	%STA_CP_ltisss = ltisss;
	STA_CP_Tran = trans;
	tic; test_MNAEqnEngine_charge_pump_DC_tran(); t_MNA_CP = toc;
	MNA_CP_qss = qss;
	%MNA_CP_ltisss = ltisss;
	MNA_CP_Tran = trans;
	close all;
	
	unk_names = MNA_CP_qss.DAE.unk_names;
	n_unks = length(unk_names);
	idx1 = 1:n_unks;
	idx2 = ones(n_unks,1);
	unk_names2 = STA_CP_qss.DAE.unk_names;
	for i=1:n_unks
		idx2(i) = find(strcmp(unk_names(i), unk_names2));
	end
	idx1_CP = idx1;
	idx2_CP = idx2;

end
%%%% delay line %%%%%
if DL == 1
	tic; test_STAEqnEngine_delay_line_DC_tran(); t_STA_DL = toc;
	STA_DL_qss = qss;
	%STA_DL_ltisss = ltisss;
	STA_DL_Tran = trans;
	tic; test_MNAEqnEngine_delay_line_DC_tran(); t_MNA_DL = toc;
	MNA_DL_qss = qss;
	%MNA_DL_ltisss = ltisss;
	MNA_DL_Tran = trans;
	close all;
	
	unk_names = MNA_DL_qss.DAE.unk_names;
	n_unks = length(unk_names);
	idx1 = 1:n_unks;
	idx2 = ones(n_unks,1);
	unk_names2 = STA_DL_qss.DAE.unk_names;
	for i=1:n_unks
		idx2(i) = find(strcmp(unk_names(i), unk_names2));
	end
	idx1_DL = idx1;
	idx2_DL = idx2;

end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%%%%%%%%%%%%%%%%%%%%%%%%% current mirror %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if CM == 1
	fprintf('\ncurrent_mirror\nTime:\n');
	fprintf('STA: %d  MNA:  %d\n', t_STA_CM, t_MNA_CM);
	fprintf('QSS error:\n');
	tran_pass = 1;
	qss_err = STA_CM_qss.solution(idx2_CM) - MNA_CM_qss.solution
	for i = 1:idx1_CM(end)
		passOrFail = compare_waveforms([MNA_CM_Tran.tpts;MNA_CM_Tran.vals(idx1_CM(i),:)],[STA_CM_Tran.tpts;STA_CM_Tran.vals(idx2_CM(i),:)]);
		if passOrFail < 1
			tran_pass = 0;
			fprintf('Transient waves of %s don''t match\n', MNA_CM_Tran.DAE.unk_names{i});
		end
	end
	if tran_pass
		fprintf('Transient result matched\n');
	else
		fprintf('Transient result mismatched\n');
	end 
end

%%%%%%%%%%%%%%%%%%%%%%%%%% Charge pump %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if CP == 1
	fprintf('\ncharge pump\nTime:\n');
	fprintf('STA: %d  MNA:  %d\n', t_STA_CP, t_MNA_CP);
	fprintf('QSS error:\n');
	tran_pass = 1;
	qss_err = STA_CP_qss.solution(idx2_CP) - MNA_CP_qss.solution
	for i = 1:idx1_CP(end)
		passOrFail = compare_waveforms([MNA_CP_Tran.tpts;MNA_CP_Tran.vals(idx1_CP(i),:)],[STA_CP_Tran.tpts;STA_CP_Tran.vals(idx2_CP(i),:)]);
		if passOrFail < 1
			tran_pass = 0;
			fprintf('Transient waves of %s don''t match\n', MNA_CP_Tran.DAE.unk_names{i});
		end
	end
	if tran_pass
		fprintf('Transient result matched\n');
	else
		fprintf('Transient result mismatched\n');
	end 
end

%%%%%%%%%%%%%%%%%%%%%%%%%% delay line %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if DL == 1
	fprintf('\ndelay line\nTime:\n');
	fprintf('STA: %d  MNA:  %d\n', t_STA_DL, t_MNA_DL);
	fprintf('QSS error:\n');
	tran_pass = 1;
	qss_err = STA_DL_qss.solution(idx2_DL) - MNA_DL_qss.solution
	for i = 1:idx1_DL(end)
		passOrFail = compare_waveforms([MNA_DL_Tran.tpts;MNA_DL_Tran.vals(idx1_DL(i),:)],[STA_DL_Tran.tpts;STA_DL_Tran.vals(idx2_DL(i),:)]);
		if passOrFail < 1
			tran_pass = 0;
			fprintf('Transient waves of %s don''t match\n', MNA_DL_Tran.DAE.unk_names{i});
		end
	end
	if tran_pass
		fprintf('Transient result matched\n');
	else
		fprintf('Transient result mismatched\n');
	end 
end

