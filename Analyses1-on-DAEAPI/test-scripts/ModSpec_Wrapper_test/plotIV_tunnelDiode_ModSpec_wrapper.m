function plotIV_tunnelDiode_ModSpec_wrapper()
    MOD = tunnelDiode_ModSpec_wrapper();

    vs = -0.05:0.001:0.4;
    is = zeros(size(vs));

    S = ee_model_parm2struct(MOD);
    for idx = 1:1:size(is,2)
        S.vpn = vs(1,idx);
        is(1,idx) = MOD.fe_of_S(S);
    end

    figure();

    plot([min(vs), max(vs)], [0, 0], 'Color', 'red', 'LineWidth', 1.25, 'LineStyle', '--');
    hold on;
    plot([0, 0], [min(is), max(is)]*1e6, 'Color', 'red', 'LineWidth', 1.25, 'LineStyle', '--');
    h = plot(vs, is*1e6, 'Color', 'blue', 'LineWidth', 1.75);
	
	axis tight;
	box on;
	grid on;
	set(gca,'FontName','Times New Roman','FontSize',15,'FontWeight','bold');
	xlabel('vpn (V)','FontName','Times New Roman','FontSize',18,'FontWeight','bold');
	ylabel('ipn (uA)','FontName','Times New Roman','FontSize',18,'FontWeight','bold');
	title(['I/V curve of a tunnel diode'],'FontName','Times New Roman','FontSize',18,'FontWeight','bold');

	set(gcf,'color','white');

end

