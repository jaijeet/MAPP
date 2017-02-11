fprintf('\nvsrcRC\n');
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
%fprintf('Transient result matcheds\n');
if tran_pass
	fprintf('Transient result matched\n');
else
	fprintf('Transient result mismatched\n');
end 

fprintf('\nvsrcRCL\n');
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

fprintf('\nvsrc_diode\n');
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


fprintf('\ndiffpair\n');
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

