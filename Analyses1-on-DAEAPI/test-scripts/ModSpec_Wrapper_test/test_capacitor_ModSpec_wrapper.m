
function out = test_capacitor_ModSpec_wrapper()

    C = 2e-12;

    MOD = capacitor_ModSpec_wrapper();
    MOD = MOD.setparms({'C'}, {C}, MOD);

    vs = -2.5:0.001:2.5;
    qs = zeros(size(vs));

    S = ee_model_parm2struct(MOD);
    for idx = 1:1:size(qs,2)
        S.vpn = vs(1,idx);
        qs(1,idx) = MOD.qe_of_S(S);
    end

    figure();

    plot([-10, 10], [0, 0], 'Color', 'red', 'LineWidth', 1.25, 'LineStyle', '--');
    hold all;
    plot([0, 0], [-10, 10], 'Color', 'red', 'LineWidth', 1.25, 'LineStyle', '--');
    h = plot(vs, qs*1e12, 'Color', 'blue', 'LineWidth', 1.75);
	
	xlim([-2.50, 2.50]);
	ylim([-5, 5]);
	set(gca,'FontName','Times New Roman','FontSize',15,'FontWeight','bold');
	set(gca,'XTick',-2.5:0.5:2.5);
	set(gca,'YTick',-5:2.5:5);
	xlabel('vpn (V)','FontName','Times New Roman','FontSize',18,'FontWeight','bold');
	ylabel('q(vpn) (pico-Coulomb)','FontName','Times New Roman','FontSize',18,'FontWeight','bold');
	title(['Q/V curve of a capacitor'],'FontName','Times New Roman','FontSize',18,'FontWeight','bold');

	set(gcf,'color','white');

end

