clear all;
set(0,'DefaultAxesFontSize',30);
set(0,'DefaultTextFontSize',30);

DAE = MNA_EqnEngine(optocoupler_ckt());

doDCsweep = 1;
doTran = 1;

if 1 == doDCsweep
	swp = dot_dcsweep(DAE, [], 'Vin:::E', 0.5:4.5/200:5);
	figure,semilogx(swp.solutions(16,:)*1e3,swp.solutions(13,:)./swp.solutions(16,:));
	%figure,semilogx(swp.solutions(16,:)*1e3,swp.solutions(13,:));
	%figure,semilogx(swp.solutions(16,:)*1e3,swp.solutions(13,:));

	grid on;
	xlabel('IF (mA)','FontName','Times New Roman','FontSize',25,'FontWeight','bold');
	ylabel('Current Transfer Ratio (IC/IF)','FontName','Times New Roman','FontSize',25,'FontWeight','bold');
	title(['CTR'],'FontName','Times New Roman','FontSize',25,'FontWeight','bold');
	set(gcf,'color','white');
end

if 1 == doTran
	tstart=0;tstep=1e-6;tstop=5e-5;
	DAE = feval(DAE.set_uQSS,'Vin:::E',0.4,DAE);
	QSSobj = dot_op(DAE); 
	[sol, iters, success] = feval(QSSobj.getsolution, QSSobj);
	TransObj = dot_transient(DAE, sol, tstart,tstep,tstop);
	outputs = StateOutputs(DAE); %to plot all state vars
	outputs = feval(outputs.DeleteAll, outputs);
	outputs = feval(outputs.Add, {'X:::Vsense:::ipcnc', 'out:::ipn'}, outputs);
	feval(TransObj.plot, TransObj, outputs);
	xlabel('Time (s)','FontName','Times New Roman','FontSize',25,'FontWeight','bold');
	ylabel('Current (A)','FontName','Times New Roman','FontSize',25,'FontWeight','bold');
	title(['Switch Simulation'],'FontName','Times New Roman','FontSize',25,'FontWeight','bold');
	set(gcf,'color','white');
end

