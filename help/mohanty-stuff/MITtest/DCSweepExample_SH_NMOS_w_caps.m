%This script runs DCSweep on a circuit with two voltage sources and 3
%capacitors and one NMOS.
%The resulting graphs are VI characteristics of a Shichman-Hodges NMOS model.

%DAE = SH_NMOS_cap_DAEAPI('my NMOS');
DAE = MNAEqnEngine_SH_NMOS_w_caps(); %SH_NMOS_cap_DAEAPI('my NMOS');

VDSs = 2:-0.05:-2;
VGSs = 2:-0.2:-2;

sol =[];
Ivds = [];
for count1 = 1:length(VDSs)
    if abs(count1-1) < 1e-9
        initGuess = [-0.01;0;5;5];
    else
        initGuess = sol(:,(count1-2)*length(VGSs)+1);
    end
    Ivds_oof =[];
    for count2 = 1:length(VGSs)
        IN = [VDSs(count1); VGSs(count2)];
        DAE = feval(DAE.set_uQSS,IN,DAE);
        QSSObj = QSS(DAE);
        QSSObj = feval(QSSObj.solve,initGuess,QSSObj);
        oof = feval(QSSObj.getSolution,QSSObj);
        Ivds_oof = [ Ivds_oof, oof(3)];
        %Ivds_oof = [ Ivds_oof, oof(1)]; % For DAEAPI till we get the ordering
        %right
        sol = [sol, feval(QSSObj.getSolution,QSSObj)];
        initGuess = feval(QSSObj.getSolution,QSSObj);
    end
    Ivds =[Ivds;Ivds_oof];
end
disp(' ');
figure(1)
title('VI characteristic curves of a Shichman Hodges NMOS','FontSize',16);
subplot(121)
plot(VDSs,-Ivds*1e6);
xlabel('Vds (V)','FontSize',16);

ylabel('Ids (\mu A)','FontSize',16);
%legend('Vgs = -1V', 'Vgs =  0V', 'Vgs =  1V', 'Vgs =  2V', 'Vgs =  3V', 'Vgs = 4V', 'Vgs =  5V', 'Location', 'NorthWest');




VGSs = -2:0.05:2;
VDSs = -2:0.2:2;

sol =[];
Ivds = [];
for count1 = 1:length(VDSs)
    if abs(count1-1) < 1e-9
        initGuess = [0.01;0;-2;-2];
    else
        initGuess = sol(:,(count1-2)*length(VGSs)+1);
    end
    Ivds_oof =[];
    for count2 = 1:length(VGSs)
        IN = [VDSs(count1); VGSs(count2)];
        DAE = feval(DAE.set_uQSS,IN,DAE);
        QSSObj = QSS(DAE);
        QSSObj = feval(QSSObj.solve,initGuess,QSSObj);
        oof = feval(QSSObj.getSolution,QSSObj);
        Ivds_oof = [ Ivds_oof, oof(3)]; % For MNA Equation Engine
        %Ivds_oof = [ Ivds_oof, oof(1)]; % For DAEAPI till we get the ordering
        %right
        sol = [sol, feval(QSSObj.getSolution,QSSObj)];
        initGuess = feval(QSSObj.getSolution,QSSObj);
    end
    Ivds =[Ivds;Ivds_oof];
end
disp(' ');
subplot(122)
plot(VGSs,-Ivds*1e6);
xlabel('Vgs (V)','FontSize',16);
ylabel('Ids (\mu A)','FontSize',16);
set(gcf,'Color','white');
%legend('Vds = 2V', 'Vds =  1V', 'Vds =  1V', 'Vds =  2V', 'Vds =  3V', 'Vds =  4V', 'Vds =  5V');




