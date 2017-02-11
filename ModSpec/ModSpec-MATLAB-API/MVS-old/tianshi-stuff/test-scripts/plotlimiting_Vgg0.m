%
%Author: Tianshi Wang <tianshi@berkeley.edu>, 2013/sometime
%

clear;
MOD = MVS_1_0_1_10_ModSpec;

vgg = 0;
Vdd = -5:0.1:5;
VddOld = -5:0.1:5;

for i = 1:length(Vdd)
	vdd = Vdd(i);
	for j = 1:length(VddOld)
		vddold = VddOld(j);
		vecLimNew = feval(MOD.limiting, [vdd; vgg; 0], zeros(2,1), [vddold; vgg; 0], [], MOD);
		newVddOld(i,j) = vecLimNew(1); 
	end
end

figure;
surf(VddOld, Vdd, newVddOld);

title 'LIMITING(VddOld, Vdd)';
xlabel 'VddOld'
ylabel 'Vdd'
zlabel 'newVdd = limiting(VddOld, Vdd)';
view (45,45);
