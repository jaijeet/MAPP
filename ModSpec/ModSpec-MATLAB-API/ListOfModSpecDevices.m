function out = ListOfModSpecDevices()
% This function lists all the available ModSpec device models
	out = {};
	out = {out{:}, 'resModSpec'};
	out = {out{:}, 'capModSpec'};
	out = {out{:}, 'indModSpec'};
	out = {out{:}, 'vsrcModSpec'};
	out = {out{:}, 'isrcModSpec'};
	out = {out{:}, 'vcvsModSpec'};
	out = {out{:}, 'vccsModSpec'};
	out = {out{:}, 'cccsModSpec'};
	out = {out{:}, 'ccvsModSpec'};
	out = {out{:}, 'diodeModSpec'};
	out = {out{:}, 'EbersMoll_BJT_ModSpec'};
	out = {out{:}, 'SH_MOS_ModSpec'};
	out = {out{:}, 'MVS_1_0_1_ModSpec'};
	out = {out{:}, 'BSIM3v3_2_4_ModSpec'};
end % ListOfModSpecDevices
