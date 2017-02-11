
function out = test_resistor_ModSpec_wrapper()

    R = 2e3;

    MOD = resistor_ModSpec_wrapper();
    MOD = MOD.setparms({'R'}, {R}, MOD);

    vs = -2.5:0.001:2.5;
    is = zeros(size(vs));

    S = ee_model_parm2struct(MOD);
    for idx = 1:1:size(is,2)
        S.vpn = vs(1,idx);
        is(1,idx) = MOD.fe_of_S(S);
    end

    figure();

    plot([-10, 10], [0, 0], 'Color', 'red', 'LineWidth', 1.25, 'LineStyle', '--');
    hold all;
    plot([0, 0], [-10, 10], 'Color', 'red', 'LineWidth', 1.25, 'LineStyle', '--');
    h = plot(vs, is*1e3, 'Color', 'blue', 'LineWidth', 1.75);
	
	xlim([-2.50, 2.50]);
	ylim([-1.25, 1.25]);
	set(gca,'FontName','Times New Roman','FontSize',15,'FontWeight','bold');
	set(gca,'XTick',-2.5:0.5:2.5);
	set(gca,'YTick',-1.25:0.25:1.25);
	xlabel('vpn (V)','FontName','Times New Roman','FontSize',18,'FontWeight','bold');
	ylabel('ipn (mA)','FontName','Times New Roman','FontSize',18,'FontWeight','bold');
	title(['I/V curve of a resistor'],'FontName','Times New Roman','FontSize',18,'FontWeight','bold');

	set(gcf,'color','white');

end

