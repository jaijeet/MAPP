MOD = DAAV6ModSpec;

%   Rs=1
MOD = feval(MOD.setparms,'Rs',1, MOD);
%   Rd=1 
MOD = feval(MOD.setparms,'Rd',1, MOD);

VGBs = 0:0.1:1;
% VDBs = -1.5:0.02:1.5;
VDBs = -0.5:0.02:1.5;
OUTs1 = [];
for c = 1:length(VGBs)
	OUTs = 0 * VDBs;
	for d = 1:length(VDBs)
		% vdb = 1;
		vdb = VDBs(d);
		vgb = VGBs(c);
		vsb = 0;
		vdib = vdb;
		vsib = vsb;

		vecX = [vdb; vgb; vsb];
		vecY = [vdib; vsib];
		u = [];

		vecZ = feval(MOD.fe, vecX, vecY, [], u, MOD);
		vecW = feval(MOD.fi, vecX, vecY, [], u, MOD);

		OUTs(d) = vecW(1) + vecZ(1); % I(disi)
	end
	% plot(VDBs, OUTs);
	% hold on;
	OUTs1 = [OUTs1; OUTs];
end
figure;
surf(VDBs, VGBs, OUTs1);
