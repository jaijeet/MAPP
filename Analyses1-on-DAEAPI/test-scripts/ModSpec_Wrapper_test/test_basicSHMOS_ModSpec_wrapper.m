
function out = test_basicSHMOS_ModSpec_wrapper()

    S.Beta = 1e-3;
    S.vth = 0.5;
    
    MOD = basicSHMOS_ModSpec_wrapper();
    MOD = MOD.setparms({'Beta', 'vth'}, {S.Beta, S.vth}, MOD);
    
    vgs_min = 0; vgs_max = 2.5; vgs_step = 0.4;
    vds_min = 0; vds_max = 2.52; vds_step = 0.06;

    vgss = vgs_min : vgs_step : vgs_max;
    vdss = vds_min : vds_step : vds_max;

    nvgss = size(vgss,2);
    nvdss = size(vdss,2);

    pause_interval = 0.5;

    % produce characteristic curves: id vs vds at constant vgs

    figure();
	set(gcf,'color','white');
    set (gca, 'FontName', 'Times New Roman', 'FontSize', 15);

    plots = [];
    legend_strs = {};

    for row_idx = 1 : 1 : nvgss
        
        S.vgs = vgss(1, row_idx);
        idss = zeros(1, nvdss);

        for col_idx = 1:1:nvdss
            
            S.vds = vdss(1, col_idx);
            currents = MOD.fe_of_S (S);
            idss(1, col_idx) = currents(2,1) * 1e3;

        end

        h = plot(vdss, idss, '.-', 'LineWidth', 1.5);
        hold all;
        plots = [plots, h];
        legend_strs = [legend_strs, sprintf('vgs=%0.2g', S.vgs)];
        xlim ([0, vds_max]);
        ylim ([0, 2]);
        xlabel ('vds (V)', 'FontName', 'Times New Roman', 'FontSize', 15);
        ylabel ('id (mA)', 'FontName', 'Times New Roman', 'FontSize', 15);
        title ('SH NMOS model: ids vs vds at const vgs', 'FontName', 'Times New Roman', 'FontSize', 15);

        pause(pause_interval);

    end

    legend (plots, legend_strs, 'location', 'North', 'orientation', 'horizontal', 'FontName', 'Times New Roman', 'FontSize', 15);

end

