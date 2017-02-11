dotran = 0;
doDC = 1;
doDCSweep = 0;

DAE = MNA_EqnEngine(OTA_ckt());

%%%%%%%% DC Sweep %%%%%%%%%%%
if doDCSweep == 1
	numSweep = 100;
	swp = dcsweep(DAE,[],'Vinp:::E',-0.5e-4:1e-6:0.5e-4);
	% plot the sweep
	%feval(swp.plot, swp);
	vin = linspace(-1e-6, 1e-6, numSweep);
	figure,plot(vin,swp.solutions(12,:)-swp.solutions(14,:));
end

%%%%%%% run DC %%%%%%%%%%%
if doDC == 1
	NRparms = defaultNRparms();
	%NRparms.limiting = 0;
	NRparms.maxiter = 100;
	qss = QSS(DAE, NRparms);
	Xinit = [ 0.3000    0.3000    1.1000    1.1000    0.7000    0.9000    0.5000    0.7000    1.6000    1.6000    1.6000    1.2000    0.4000 ...
			  1.2000    0.4000    1.2000    1.2000    0.8000    1.2000         0         0    -0.00666667    0         0         0         0     ...
			  0 	    0		  0.00333334   		0.00166667]';

	% qss = feval(qss.solve, swp.solutions(:,floor(numSweep/2)),qss);
	qss = feval(qss.solve, Xinit, qss);
	feval(qss.print, qss);
	DCsol = feval(qss.getsolution, qss);

end
%%%% Transient %%%%%%%% 

if dotran == 1
	tstart = 0;
	tstep = 1e-9;
	tstop = 1e-7;
	
	args.f = 2e7;
	args.A = 1e-6;
	args.phi = 0;
	
	sinfunc = @(t, args) args.A*sin(2*pi*args.f*t+args.phi);
	DAE = feval(DAE.set_utransient, 'Vinp:::E', sinfunc, args, DAE);

	LMSObj = dot_tran(DAE,DCsol, tstart, tstep, tstop);
	% feval(LMSObj.plot,LMSObj);
	
	figure,plot(LMSObj.tpts,LMSObj.vals(1,:)-LMSObj.vals(2,:),LMSObj.tpts,LMSObj.vals(12,:)-LMSObj.vals(14,:));
	set(gca,'FontName','Times New Roman','FontSize',15,'FontWeight','bold');
	legend('Input','Output');
	xlabel('Time (s)','FontName','Times New Roman','FontSize',18,'FontWeight','bold');
	ylabel('V (v)','FontName','Times New Roman','FontSize',18,'FontWeight','bold');
	title(['current mirror tran: Vinput vs Voutput'],'FontName','Times New Roman','FontSize',18,'FontWeight','bold');
	set(gcf,'color','white');
	
	%figure,plot(LMSObj.tpts,(LMSObj.vals(11,:)-LMSObj.vals(13,:))./(LMSObj.vals(1,:)-LMSObj.vals(2,:)));
	%}
end
