function out = plotGV_tunnelDiode_ModSpec_wrapper()
    MOD = tunnelDiode_ModSpec_wrapper();

    vs = -0.05:0.001:0.4;
    gs = zeros(size(vs));

    for idx = 1:1:size(gs,2)
        gs(1,idx) = MOD.dfe_dvecX(vs(idx), [], [], [], MOD);
    end

    figure();

    plot([min(vs), max(vs)], [0, 0], 'Color', 'red', 'LineWidth', 1.25, 'LineStyle', '--');
    hold on;
    plot([0, 0], [min(gs), max(gs)], 'Color', 'red', 'LineWidth', 1.25, 'LineStyle', '--');
    h = plot(vs, gs, 'Color', 'blue', 'LineWidth', 1.75);
	
	axis tight;
	box on;
	grid on;
	set(gca,'FontName','Times New Roman','FontSize',15,'FontWeight','bold');
	xlabel('vpn (V)','FontName','Times New Roman','FontSize',18,'FontWeight','bold');
	ylabel('transconductance G (S)','FontName','Times New Roman','FontSize',18,'FontWeight','bold');
	title(['G/V curve of a tunnel diode'],'FontName','Times New Roman','FontSize',18,'FontWeight','bold');

	set(gcf,'color','white');

end

