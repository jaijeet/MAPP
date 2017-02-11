
function out = test_DSAwareSHMOSWithParasitics_ModSpec_wrapper()

    % plotDSAwareMOSCharacteristics ('P');
    plotDSAwareMOSCharacteristics ('N');

end

function plotDSAwareMOSCharacteristics (Type)

    CktEqns_DSUnaware = SHMOSWithParasitics_CktEqns (Type);
    ids_idx_DSUnaware = find(strcmp(CktEqns_DSUnaware.unknames(CktEqns_DSUnaware), 'vds:::ipn'));

    CktEqns_DSAware = DSAwareSHMOSWithParasitics_CktEqns (Type);
    ids_idx_DSAware = find(strcmp(CktEqns_DSAware.unknames(CktEqns_DSAware), 'vds:::ipn'));

    if strcmp(Type, 'N')
        vgs_min = 0; vgs_max = 2.5; nvgss = 8;
        vds_min = -2.5; vds_max = 2.5; nvdss = 50;
    else
        vgs_min = -2.5; vgs_max = 0; nvgss = 8;
        vds_min = -2.5; vds_max = 2.5; nvdss = 50;
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
        
        CktEqns_DSUnaware = CktEqns_DSUnaware.set_uQSS ('vgs:::E', vgss(1,row_idx), CktEqns_DSUnaware);
        CktEqns_DSAware = CktEqns_DSAware.set_uQSS ('vgs:::E', vgss(1,row_idx), CktEqns_DSAware);

        DCSwpObj = dot_dcsweep (CktEqns_DSUnaware, [], 'vds:::E', vds_min:(vds_max-vds_min)/nvdss:vds_max);
        idss_DSUnaware = -DCSwpObj.solutions (ids_idx_DSUnaware, :) * 1e3;
        DCSwpObj = dot_dcsweep (CktEqns_DSAware, [], 'vds:::E', vds_min:(vds_max-vds_min)/nvdss:vds_max);
        idss_DSAware = -DCSwpObj.solutions (ids_idx_DSAware, :) * 1e3;
       
        h1 = plot(vdss, idss_DSUnaware, 'LineWidth', 1.5);
        hold all;
        h2 = plot(vdss, idss_DSAware, 's', 'LineWidth', 1.5);
        plots = [plots, h1];
        legend_strs = [legend_strs, sprintf('vgs=%0.2g', vgss(1,row_idx))];
        xlim ([vds_min, vds_max]);

        if strcmp(Type, 'N')
            ylim ([-2.4, 2.4]);
        else
            ylim ([-2.4, 2.4]);
        end

        xlabel ('vds (V)', 'FontName', 'Times New Roman', 'FontSize', 15);
        ylabel ('id (mA)', 'FontName', 'Times New Roman', 'FontSize', 15);
        title (['DS aware vs unaware SH ', Type, 'MOS models: id vs vds at const vgs'], 'FontName', 'Times New Roman', 'FontSize', 15);
        pause(pause_interval);

    end

    legend (plots, legend_strs, 'location', 'North', 'orientation', 'horizontal', 'FontName', 'Times New Roman', 'FontSize', 15);

end

function CktEqns = DSAwareSHMOSWithParasitics_CktEqns (Type)
    
    ckt.cktname = 'DSAwareSHMOSWithParasitics_Ckt';

    ckt.nodenames = {'g', 'd'};
    ckt.groundnodename = 's';

    ckt = add_element (ckt, DSAwareSHMOSWithParasitics_ModSpec_wrapper(), 'M', {'d', 'g', 's'}, {{'Type', Type}});

    ckt = add_element (ckt, vsrc_ModSpec_wrapper(), 'vgs', {'g', 's'}, {}, {{'E', {'DC', 0}}});
    ckt = add_element (ckt, vsrc_ModSpec_wrapper(), 'vds', {'d', 's'}, {}, {{'E', {'DC', 0}}});
    
    CktEqns = MNA_EqnEngine (ckt);

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

