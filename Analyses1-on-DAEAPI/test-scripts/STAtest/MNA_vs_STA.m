clear all;
%%%% vsrcRC %%%%%
tic; test_STAEqnEngine_vsrcRC_DC_AC_tran(); t_STA_RC = toc;
STA_vsrcRC_qss = qss;
STA_vsrcRC_ltisss = ltisss;
STA_vsrcRC_Tran = TransObjTRAP;
tic; test_MNAEqnEngine_vsrcRC_DC_AC_tran(); t_MNA_RC = toc;
MNA_vsrcRC_qss = qss;
MNA_vsrcRC_ltisss = ltisss;
MNA_vsrcRC_Tran = TransObjTRAP;
close all;
%%%% vsrcRCL %%%%%
tic; test_STAEqnEngine_vsrcRCL_DC_AC_tran();t_STA_RCL = toc;
STA_vsrcRCL_qss = qss;
STA_vsrcRCL_ltisss = ltisss;
STA_vsrcRCL_Tran = TransObjTRAP;
tic; test_MNAEqnEngine_vsrcRCL_DC_AC_tran();t_MNA_RCL = toc;
MNA_vsrcRCL_qss = qss;
MNA_vsrcRCL_ltisss = ltisss;
MNA_vsrcRCL_Tran = TransObjTRAP;
close all;
%%%% vsrc_diode %%%%%
tic; test_STAEqnEngine_vsrc_diode_DC_AC_tran();t_STA_D = toc;
STA_vsrc_diode_qss = qss;
STA_vsrc_diode_ltisss = ltisss;
STA_vsrc_diode_Tran = TransObjTRAP;
tic; test_MNAEqnEngine_vsrc_diode_DC_AC_tran();t_MNA_D = toc;
MNA_vsrc_diode_qss = qss;
MNA_vsrc_diode_ltisss = ltisss;
MNA_vsrc_diode_Tran = TransObjTRAP;
close all;
%%%% diffpair %%%%%
tic; test_STAEqnEngine_SH_MOSdiffpair_DC_AC_tran();t_STA_DP = toc;
STA_diffpair_qss = qss;
STA_diffpair_ltisss = ltisss;
STA_diffpair_Tran = Trans;
tic; test_MNAEqnEngine_SH_MOSdiffpair_DC_AC_tran();t_MNA_DP = toc;
MNA_diffpair_qss = qss;
MNA_diffpair_ltisss = ltisss;
MNA_diffpair_Tran = Trans;
close all;
%}
fprintf('\n');

fprintf('\nvsrcRC time:\n');
fprintf('STA: %d  MNA: %d\n', t_STA_RC, t_MNA_RC);
fprintf('QSS error:\n');
idx1 = 1:3;
idx2 = [1 2 6];
tran_pass = 1;
qss_err = STA_vsrcRC_qss.solution(idx2) - MNA_vsrcRC_qss.solution
for i = 1:3
	passOrFail = compare_waveforms([MNA_vsrcRC_Tran.tpts;MNA_vsrcRC_Tran.vals(idx1(i),:)],[STA_vsrcRC_Tran.tpts;STA_vsrcRC_Tran.vals(idx2(i),:)]);
	if passOrFail < 1
		tran_pass = 0;
		fprintf('Transient waves of %s don''t match\n', MNA_vsrcRC_Tran.DAE.unk_names{i});
	end
end
if tran_pass
	fprintf('Transient result matched\n');
else
	fprintf('Transient result mismatched\n');
end 

fprintf('\nvsrcRCL time:\n');
fprintf('STA: %d  MNA: %d\n', t_STA_RCL, t_MNA_RCL);
fprintf('QSS error:\n');
idx1 = 1:5;
idx2 = [1 2 3 8 11];
qss_err = STA_vsrcRCL_qss.solution(idx2) - MNA_vsrcRCL_qss.solution
tran_pass = 1;
for i = 1:5
	passOrFail = compare_waveforms([MNA_vsrcRCL_Tran.tpts;MNA_vsrcRCL_Tran.vals(idx1(i),:)],[STA_vsrcRCL_Tran.tpts;STA_vsrcRCL_Tran.vals(idx2(i),:)]);
	if passOrFail < 1
		tran_pass = 0;
		fprintf('Transient waves of %s don''t match\n', MNA_vsrcRCL_Tran.DAE.unk_names{i});
	end
end
if tran_pass
	fprintf('Transient result matched\n');
else
	fprintf('Transient result mismatched\n');
end 

fprintf('\nvsrc_diode time: \n');
fprintf('STA: %d  MNA: %d\n', t_STA_D, t_MNA_D);
fprintf('QSS error:\n');
idx1 = 1:3;
idx2 = [1 4 6];
qss_err = STA_vsrc_diode_qss.solution(idx2) - MNA_vsrc_diode_qss.solution
tran_pass = 1;
for i = 1:3
	passOrFail = compare_waveforms([MNA_vsrc_diode_Tran.tpts;MNA_vsrc_diode_Tran.vals(idx1(i),:)],[STA_vsrc_diode_Tran.tpts;STA_vsrc_diode_Tran.vals(idx2(i),:)]);
	if passOrFail < 1
		tran_pass = 0;
		fprintf('Transient waves of %s don''t match\n', MNA_vsrc_diode_Tran.DAE.unk_names{i});
	end
end
if tran_pass
	fprintf('Transient result matched\n');
else
	fprintf('Transient result mismatched\n');
end 


fprintf('\ndiffpair time: \n');
fprintf('STA: %d  MNA: %d\n', t_STA_DP, t_MNA_DP);
fprintf('QSS error:\n');
idx1 = 1:7;
idx2 = [1 2 3 4 5 17 18];
qss_err = STA_diffpair_qss.solution(idx2) - MNA_diffpair_qss.solution
tran_pass = 1;
for i = 1:7
	passOrFail = compare_waveforms([MNA_diffpair_Tran.tpts;MNA_diffpair_Tran.vals(idx1(i),:)],[STA_diffpair_Tran.tpts;STA_diffpair_Tran.vals(idx2(i),:)]);
	if passOrFail < 1
		tran_pass = 0;
		fprintf('Transient waves of %s don''t match\n', MNA_diffpair_Tran.DAE.unk_names{i});
	end
end
if tran_pass
	fprintf('Transient result matched\n');
else
	fprintf('Transient result mismatched\n');
end 

