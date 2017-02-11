DAE = STA_EqnEngine(current_mirror_ckt());

% run DC
NRparms = defaultNRparms();
NRparms.limiting = 0;
qss = QSS(DAE, NRparms);
qss = feval(qss.solve, qss);
feval(qss.print, qss);
DCsol = feval(qss.getsolution, qss);
tstart = 0;
tstep = 1e-9;
tstop = 1e-7;

LMSObj = dot_tran(DAE,DCsol, tstart, tstep, tstop);
% feval(LMSObj.plot,LMSObj);
figure,plot(LMSObj.tpts,LMSObj.vals(5,:),LMSObj.tpts,LMSObj.vals(6,:));
set(gca,'FontName','Times New Roman','FontSize',15,'FontWeight','bold');
legend('Input','Output');
xlabel('Time (s)','FontName','Times New Roman','FontSize',18,'FontWeight','bold');
ylabel('V (v)','FontName','Times New Roman','FontSize',18,'FontWeight','bold');
title(['current mirror tran: Vinput vs Voutput'],'FontName','Times New Roman','FontSize',18,'FontWeight','bold');
set(gcf,'color','white');
