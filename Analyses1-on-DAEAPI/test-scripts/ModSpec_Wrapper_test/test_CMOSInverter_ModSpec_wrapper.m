
function out = test_CMOSInverter_ModSpec_wrapper()

    CktEqns = CMOSInverter_CktEqns();
    
    xinit = zeros(CktEqns.nunks(CktEqns),1);
    tstart = 0;
    tstep = 1e-11;
    tstop = 4e-9;
    
    % TRmethods = LMSmethods();
    % TRmethod = TRmethods.BE;
    % tranparms = defaultTranParms();

    % TransObj = LMS (CktEqns, TRmethod, tranparms);
    % TransObj = feval ( TransObj.solve, TransObj, xinit, tstart, tstep, tstop );
    TransObj = dot_tran (CktEqns, xinit, tstart, tstep, tstop);
    
    in_idx = find(strcmp(CktEqns.unknames(CktEqns),'e_in'));
    out_idx = find(strcmp(CktEqns.unknames(CktEqns),'e_out'));

    ts = TransObj.tpts;
    vin = TransObj.vals(in_idx,:);
    vout = TransObj.vals(out_idx,:);

    figure();

    set (gca, 'FontName', 'Times New Roman', 'FontSize', 15);
    set (gcf, 'Color', 'white');
    
    h1 = plot(ts*1e9, vin, 'k.-', 'LineWidth', 1.5);
    hold all;
    h2 = plot(ts*1e9, vout, 'b.-', 'LineWidth', 1.5);
    xlim ([tstart*1e9, tstop*1e9]);
    ylim ([-0.5, 3]);
    xlabel ('Time (ns)', 'FontName', 'Times New Roman', 'FontSize', 15);
    ylabel ('Voltages (V)', 'FontName', 'Times New Roman', 'FontSize', 15);
    legend ([h1, h2], {'Vin', 'Vout'}, 'location', 'North', 'Orientation', 'horizontal');
    title ('CMOS Inverter: Transient simulation', 'FontName', 'Times New Roman', 'FontSize', 18);
 
end

function CktEqns = CMOSInverter_CktEqns()
    
    vdd = 2.5;

    ckt.cktname = 'CMOSInverter_Ckt';

    ckt.nodenames = {'dd', 'in', 'out'};
    ckt.groundnodename = 'gnd';

    ckt = add_element (ckt, DSAwareSHMOSWithParasitics_ModSpec_wrapper(), 'M1', {'out', 'in', 'dd'}, {{'Type', 'P'}});
    ckt = add_element (ckt, DSAwareSHMOSWithParasitics_ModSpec_wrapper(), 'M2', {'out', 'in', 'gnd'}, {{'Type', 'N'}});

    ckt = add_element (ckt, vsrc_ModSpec_wrapper(), 'vdd', {'dd', 'gnd'}, {}, {{'E', {'DC', vdd}}});
    vin_tranfunc = @(t, args) (bitsequence(t, args));
    vin_tranargs.low = 0;
    vin_tranargs.high = vdd;
    vin_tranargs.T = 1e-9;
    vin_tranargs.trf = 0.05e-9;
    vin_tranargs.bits = [1, 0, 1, 0];
    ckt = add_element (ckt, vsrc_ModSpec_wrapper(), 'vin', {'in', 'gnd'}, {}, {{'E', {'TRAN', vin_tranfunc, vin_tranargs}}});

    ckt = add_element (ckt, capacitor_ModSpec_wrapper(), 'C1', {'out', 'gnd'}, 5e-14);
    CktEqns = MNA_EqnEngine (ckt);

end

function out = bitsequence (t, args)
    
    if isfield(args, 'tstart')
        tstart = args.tstart;
    else
        tstart = 0;
    end

    num_periods_over = floor(t/args.T);
    time_left = t - num_periods_over * args.T;

    if num_periods_over >= size(args.bits, 2)
        out = ite(args.bits(1,end), args.low, args.high);
        return;
    elseif num_periods_over == 0
        out = ite(args.bits(1,1), args.low, args.high);
        return;
    end

    if time_left < args.trf
        v1 = ite(args.bits(1,num_periods_over), args.low, args.high);
        v2 = ite(args.bits(1,num_periods_over+1), args.low, args.high);
        out = v1 + (v2 - v1)*(time_left/args.trf);
    else
        out = ite(args.bits(1,num_periods_over+1), args.low, args.high);
    end 

end

function out = ite (bit, low, high)
    out = bit*high + (1-bit)*low;
end


