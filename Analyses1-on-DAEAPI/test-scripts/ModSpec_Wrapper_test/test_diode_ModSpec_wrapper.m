
function out = test_diode_ModSpec_wrapper()

    S.Is = 1e-12;
    S.VT = 0.025;

    MOD = diode_ModSpec_wrapper();
    MOD = MOD.setparms({'Is', 'VT'}, {S.Is, S.VT}, MOD);

    vs = -0.14:0.001:0.14;
    is = zeros(size(vs));

    for idx = 1:1:size(is,2)
        S.vpn = vs(1,idx);
        S.vpnlim = vs(1,idx);
        is(1,idx) = MOD.fe_of_S(S);
    end

    figure();

    plot([-10, 10], [0, 0], 'Color', 'red', 'LineWidth', 1.25, 'LineStyle', '--');
    hold all;
    plot([0, 0], [-10, 10], 'Color', 'red', 'LineWidth', 1.25, 'LineStyle', '--');
    h = plot(vs, is*1e6, 'Color', 'blue', 'LineWidth', 1.75);
	
	xlim([-0.14, 0.14]);
	ylim([-1e-4, 3e-4]);
	set(gca,'FontName','Times New Roman','FontSize',15,'FontWeight','bold');
	xlabel('vpn (V)','FontName','Times New Roman','FontSize',18,'FontWeight','bold');
	ylabel('ipn (uA)','FontName','Times New Roman','FontSize',18,'FontWeight','bold');
	title(['I/V curve of a diode'],'FontName','Times New Roman','FontSize',18,'FontWeight','bold');

	set(gcf,'color','white');

end

