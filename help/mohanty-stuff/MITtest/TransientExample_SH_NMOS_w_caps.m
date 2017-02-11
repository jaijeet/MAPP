%DAE = SH_NMOS_cap_DAEAPI('my NMOS');
DAE = MNAEqnEngine_SH_NMOS_w_caps(); %SH_NMOS_cap_DAEAPI('my NMOS');
LMStranparms = defaultTranParms(); 

utfunc = @bitPattern;
constFunc = @(t,args) 2;
utargs.A = 2; utargs.f=1e9; utargs.phi=0; 
%utfunc = @(t, args) (0.3+args.A*sin(2*pi*args.f*t + args.phi));


DAE = feval(DAE.set_utransient,'Vg:::E', utfunc, utargs, DAE); 
DAE = feval(DAE.set_utransient,'Vd:::E', constFunc, utargs, DAE); 
DAE = feval(DAE.set_uQSS,'Vd:::E',[2],DAE); 
DAE = feval(DAE.set_uQSS,'Vg:::E',[2],DAE);

%{
%For DAEAPI
DAE = feval(DAE.set_utransient,'Vgs', utfunc, utargs, DAE); 
DAE = feval(DAE.set_utransient,'Vds', constFunc, utargs, DAE); 
DAE = feval(DAE.set_uQSS,'Vds',[2],DAE); % constFunc, utargs, DAE); 
DAE = feval(DAE.set_uQSS,'Vgs',[2],DAE); % constFunc, utargs, DAE); 
%}

%xinit = [-2e-6; 0; 2; 2; 1]; % Initial condition
xinit = [2; 2; 0.3; 0; 0]; % Initial condition
tstart = 0;           % Start time
tstep = 1e-12;        % Time step
tstop = 15e-9;         % Stop time

tranparms = LMStranparms; % Transient simulation
tranparms.trandbglvl = -1; % Only errors 
TRmethods = LMSmethods();
TRmethod = TRmethods.GEAR2;
TransObj = LMS(DAE,TRmethod,tranparms);
TransObj = feval ( TransObj.solve, TransObj, xinit, tstart, tstep, tstop );

figure(1010)
title('Transient analysis : (Vds = 2V)');
subplot(211)
plot(TransObj.tpts(1:end),-TransObj.vals(4,1:end)*1e6,'--','LineWidth',2)
ylabel('Ids (\mu A)','FontSize',16);
subplot(212)
plot(TransObj.tpts(1:end),TransObj.vals(3,1:end),'r--','LineWidth',2)
hold on
plot(TransObj.tpts(1:end),TransObj.vals(1,1:end),'b-.','LineWidth',2)
legend_h = legend('Vg','Vd');
set(legend_h,'Fontsize',16);
ylabel('(V)','FontSize',16);
xlabel('time (sec)','FontSize',16);
set(gcf,'Color','white');
