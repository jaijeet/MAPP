
function out = test_SHMOSWithParasitics_ModSpec_wrapper()

    % plotMOSCharacteristics ('P');
    plotMOSCharacteristics ('N');

end

function plotMOSCharacteristics (Type)

    CktEqns = SHMOSWithParasitics_CktEqns (Type);
    ids_idx = find(strcmp(CktEqns.unknames(CktEqns), 'vds:::ipn'));

    if strcmp(Type, 'N')
        vgs_min = 0; vgs_max = 2.5; nvgss = 8;
        vds_min = 0; vds_max = 2.52; nvdss = 30;
    else
        vgs_min = -2.5; vgs_max = 0; nvgss = 8;
        vds_min = -2.5; vds_max = 0; nvdss = 30;
    end

    vgs_step = (vgs_max - vgs_min)/(nvgss-1);
    vds_step = (vds_max - vds_min)/(nvdss-1);

    vgss = vgs_min : vgs_step : vgs_max;
    vdss = vds_min : vds_step : vds_max;

    pause_interval = 0.01;

    % produce characteristic curves: id vs vds at constant vgs

    figure();
	set(gcf,'color','white');
    set (gca, 'FontName', 'Times New Roman', 'FontSize', 15);
    
    plots = [];
    legend_strs = {};

    for row_idx = 1 : 1 : nvgss
        
        CktEqns = CktEqns.set_uQSS ('vgs:::E', vgss(1,row_idx), CktEqns);

        DCSwpObj = dot_dcsweep (CktEqns, [], 'vds:::E', vds_min:(vds_max-vds_min)/nvdss:vds_max);
        idss = -DCSwpObj.solutions (ids_idx, :) * 1e3;
       
        h = plot(vdss, idss, '.-', 'LineWidth', 1.5);
        hold all;
        plots = [plots, h];
        legend_strs = [legend_strs, sprintf('vgs=%0.2g', vgss(1,row_idx))];
        xlim ([vds_min, vds_max]);

        if strcmp(Type, 'N')
            ylim ([0, 2.2]);
        else
            ylim ([-2.2, 0.2]);
        end

        xlabel ('vds (V)', 'FontName', 'Times New Roman', 'FontSize', 15);
        ylabel ('id (mA)', 'FontName', 'Times New Roman', 'FontSize', 15);
        title (['SH ', Type, 'MOS model with parasitics: id vs vds at const vgs'], 'FontName', 'Times New Roman', 'FontSize', 15);
        pause(pause_interval);

    end

    legend (plots, legend_strs, 'location', 'North', 'orientation', 'horizontal', 'FontName', 'Times New Roman', 'FontSize', 15);

end

function CktEqns = SHMOSWithParasitics_CktEqns (Type)
    
    ckt.cktname = 'SHMOSWithParasitics_Ckt';

    ckt.nodenames = {'g', 'd'};
    ckt.groundnodename = 's';

    ckt = add_element (ckt, SHMOSWithParasitics_ModSpec_wrapper(), 'M', {'d', 'g', 's'}, {{'Type', Type}});

    ckt = add_element (ckt, vsrc_ModSpec_wrapper(), 'vgs', {'g', 's'}, {}, {{'E', {'DC', 0}}});
    ckt = add_element (ckt, vsrc_ModSpec_wrapper(), 'vds', {'d', 's'}, {}, {{'E', {'DC', 0}}});
    
    CktEqns = MNA_EqnEngine (ckt);

end

