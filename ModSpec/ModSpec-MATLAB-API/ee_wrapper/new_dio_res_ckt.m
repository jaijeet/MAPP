function netlist = new_dio_res_ckt()
%This script was hand-coded during NEEDS teleseminar:
%    Tianshi Wang; Jaijeet Roychowdhury (2014), "The Berkeley Model Development
%    Environment: A MATLAB-based Platform for Modeling and Analyzing Nanoscale
%    Devices and Circuits," https://nanohub.org/resources/20137.
    netlist.cktname = 'vsrc--dio--res';
    netlist.nodenames = {'n1', 'n2'};
    netlist.groundnodename = 'gnd';

    netlist=add_element(netlist, resistor_ModSpec_wrapper(), 'R1', {'n1', 'n2'}, 1000);
    netlist=add_element(netlist, diode_ModSpec_wrapper(), 'D1', {'n2', 'gnd'});
    netlist=add_element(netlist, capacitor_ModSpec_wrapper(), 'C1', {'n2', 'gnd'}, 1e-6);

    tranfunc = @(t, args) args.A * sin(2*pi * args.f * t);
    tranargs.A = 1; tranargs.f = 1e3;
    netlist=add_element(netlist, vsrcModSpec(), 'V1', {'n1', 'gnd'}, {},...
          {{'DC', 10}, {'TRAN', tranfunc, tranargs}});
end
