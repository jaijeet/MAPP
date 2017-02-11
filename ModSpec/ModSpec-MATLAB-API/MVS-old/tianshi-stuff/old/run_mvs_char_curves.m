%This script sweeps Vds of an NMOS at different Vgs values.
%It then plots Ids-Vds curves at different Vgs values.
%
%SEE ALSO
%--------
%
%dot_dcsweep, SH_char_curves_ckt


% set up DAE
more off;
DAE =  MNA_EqnEngine(mvs_char_curves_ckt());

VGGs = -0.8:0.1:0.8;
nVGGs = length(VGGs);
nVDDs = 17;
IDs = zeros(nVGGs, nVDDs);

oidx = unkidx_DAEAPI('Vdd:::ipn', DAE);

i = 0;
for vgg = VGGs
    DAE = feval(DAE.set_uQSS, 'Vgg:::E', vgg, DAE);
    i = i+1;
    swp = dot_dcsweep(DAE, [], 'Vdd:::E', -0.4, 1.2, nVDDs);
    [VDDs, sol] = feval(swp.getsolution, swp);
    IDs(i,:) = sol(oidx,:);
end

figure;
hold on;
xlabel 'VDS';
ylabel 'ID';
title 'MVS characteristic curves';
hold on;
i = 0; legends = {};
for vgg = VGGs
    i = i+1;
    col = getcolorfromindex(gca(), i);
    marker = getmarkerfromindex(i);
    plot(VDDs, -IDs(i,:), sprintf('%s-', marker), 'Color', col);
    legends{i} = sprintf('VGS=%0.2g', vgg);
end
legend(legends, 'Location', 'SouthEast');

grid on; axis tight;
