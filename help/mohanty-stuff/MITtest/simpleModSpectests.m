%This script plots plot x vs. fe(x) and x. vs dfe_dx(x) for Shichman Hodges
%model
VDSs = -5:0.1:5;
VGSs = -1:1:5;
IDs = []; dIDs_dVds= [];
MODobj = ShichmanHodgesNMOSModel('SH-NMOS');
for count1 = 1 : 1 : length(VGSs)
    oof11 = []; oof21 = [];
    for count2 = 1 : 1: length(VDSs)
        oof12 = feval(MODobj.fe,[VDSs(count2); VGSs(count1)],[],[],MODobj);
        oof11 = [ oof11 , oof12(1) ];
    end
    IDs = [IDs; oof11];
    dIDs_dVds = [dIDs_dVds; oof21];
end

figure(1)
plot(VDSs,IDs)
xlabel('Vds');
ylabel('Ids');
legend('Vgs = -1V', 'Vgs =  0V', 'Vgs =  1V', 'Vgs =  2V', 'Vgs =  3V', 'Vgs = 4V', 'Vgs =  5V');
