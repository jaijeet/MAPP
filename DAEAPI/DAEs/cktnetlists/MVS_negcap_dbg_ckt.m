function cktnetlist = MVSnegcap_dbg_ckt()
%function cktnetlist = MVSnegcap_dbg_ckt()
% This produces a netlist for the following circuit, suggested by Dimitri
% Antoniadis, to explore whether the negative differential capacitances in
% the MVS model are "physical" or not:
% - Voltage source VGG (at node gate) connected to the gate of an MVS MOSFET,
%   - VGG is either fixed at 1VDC, or has the same waveform as VDD.
% - Voltage source VDD (at node vdd) connected to a resistor R (nominal value 
%   10K).
%    - VDD is ramped in transient from 0 to 1 in 10ps.
% - The other end of the resistor R is connected to the drain of the MOSFET.
%
%The IDS terms in the MVS model are set to zero by setting vxo=0, leaving only
%the charge terms.  The parasitic cap Cif is also set to 0; Cof is left at its
%default value 0.2pF.
%
%The transient tstep is about 10fs, with tstop about 10ps.
% 
%Experiments
%-----------
%
% %%%%% set up the DAE
% DAE = MNA_EqnEngine(MVS_negcap_dbg_ckt());
% vddfunc = @(t, args) 1.0; % 0.00 + pulse(t/20e-12, 0, 0.1, 0.5, 0.6);
% zerofunc = @(t, args) 0.0;
% stupidfunc = @(t, args) -(0==t) + 1; % what happens if you use zero ICs in transient
% gatefunc = @(t, args) 0.00 + pulse(t/1e-12, 0.05, 0.1, 0.5, 0.6); % switch the gate on and off
% % change VDD's transient waveform if you like
% DAE = feval(DAE.set_utransient, 'VDD:::E', vddfunc, [], DAE);
% % set VGG to be the same as VDD in transient, or to zero, or to a switching on one
% DAE = feval(DAE.set_utransient, 'VGG:::E', gatefunc, [], DAE);
%
% % change DAE parameters, if desired. The circuit uses default MVS parameters.
% DAE = feval(DAE.setparms, 'NMOS:::vxo', 0.0, DAE);
% % DAE = feval(DAE.setparms, 'NMOS:::Cif', 0.0, DAE);
% % DAE = feval(DAE.setparms, 'NMOS:::Cof', 0.0, DAE);
% 
% %%%%% compute the QSS (DC) operating point
% DC = dc(DAE); feval(DC.print, DC);
% % there is a DC current of 1e-12 going through VDD - why? Is this numerical
% % convergence error, or a part of the model? It was due to gmin - now zeroed
% % in the netlist.
%
% %% Do a DC sweep
% %feval(DAE.inputnames, DAE) % will show the name VDD:::E, the source to sweep
% %initguess = [];
% %DCswp = dcsweep(DAE, initguess, 'VDD:::E', 0:0.1:2);
% %feval(DCswp.plot, DCswp);
% %% there is a linear variation of the current with VDD. It looks like gmin.
% %% gmin is now set to zero
%
% %%%%% run a transient with zero IC
% tstart = 0; tstep = 1e-14; tstop = 1e-12;
% profile on; tic;
% TR = tr(DAE, 'DC', tstart, tstep, tstop); % xinit is the DC op pt with t=0 input
% toc
% profile viewer
% % TR = tr(DAE, [], tstart, tstep, tstop); % xinit is all zeros => unphysical results!
% feval(TR.plot, TR);
% Cif = feval(DAE.getparms, 'NMOS:::Cif', DAE);
% Cof = feval(DAE.getparms, 'NMOS:::Cof', DAE);
% vxo = feval(DAE.getparms, 'NMOS:::vxo', DAE);
% title(sprintf('MVS common-source amp (vxo=%g, Cif=%g, Cof=%g): transient (Vgs pulsed)', vxo, Cif, Cof));
% % The drain voltage reaches O(100V), and then becomes negative and
% % stabilizes. It would seem something might be "non-physical" about the
% % capacitance model.
%
% % To explore this further, we plot Qg at the internal drain node vs Vdib
% % directly from the ModSpec model:
%
% MVSMOD = MVS_1_0_1_ModSpec_wrapper();
% MVSMOD = feval(MVSMOD.setparms, 'vxo', 0.0, MVSMOD);
% MVSMOD = feval(MVSMOD.setparms, 'Cif', 0.0, MVSMOD);
% % MVSMOD = feval(MVSMOD.setparms, 'Cof', 0.0, MVSMOD);
% % MVSMOD = feval(MVSMOD.setparms, 'Cif', 1e-10, MVSMOD);
% % MVSMOD = feval(MVSMOD.setparms, 'Cof', 1e-10, MVSMOD);
% MVSMOD = feval(MVSMOD.setparms, 'gmin', 0.0, MVSMOD);
% feval(MVSMOD.ImplicitEquationNames, MVSMOD) % names of implicit equations
%                                             % KCL-di and KCL-si
% % we are interested in the charge terms at di, so we want to evaluate
% % qi
% help ModSpec_skeleton_core % tells you what the arguments of qi are:
%                            % vecX, vecY, MOD
% feval(MVSMOD.OtherIONames, MVSMOD) % names of vecX entries: vdb, vgb, vsb
% feval(MVSMOD.InternalUnkNames, MVSMOD) % names of vecY entries: vdib, vsib
% vgb = 1.0; vsb = 0.0; vsib = 0.0;
% vdibs = -1:0.01:2; Qds = []; dQd_dVds = [];
% profile on; tic; 
% for i=1:length(vdibs)
%   vdib = vecvalder(vdibs(i), 'indep'); vdb = vdib;
%   vecX = [vdb; vgb; vsb]; vecY = [vdib; vsib];
%   % have to have vecLim because qi is not backward-compatible yet
%   % vecLim = [vdblim, vgblim, vsblim]
%   vecLim = vecX;
%   vecW = feval(MVSMOD.qi, vecX, vecY, vecLim, MVSMOD); 
%          %vecW = [KCL-di; KCL-si], hence the first entry is Qdi
%   Qd = vecW(1);
%   Qds(i) = val2mat(Qd);
%   dQd_dVds(i) = der2mat(Qd);
% end
% toc
% profile viewer; % the execution profile is interesting - vecvalder mtimes,
%                 % plus and minus take most of the time, followed by eval
%                 % statements for parameters etc. in various places. v2struct
%                 % also takes quite some time. It may be possible to reduce
%                 % these substantially.
% figure; plot(vdibs, Qds, 'b.-');
% xlabel 'Vds'; ylabel 'Qdi/dQdi\_dVds'; 
% Cif = feval(MVSMOD.getparms, 'Cif', MVSMOD);
% Cof = feval(MVSMOD.getparms, 'Cof', MVSMOD);
% title(sprintf('MVS with vxo=0, Cif=%g, Cof=%g: Qdi and Cdsi vs Vds', ...
%       Cif, Cof));
% grid on;
% hold on; plot(vdibs, dQd_dVds, 'r.-');
% legend({'Qdi', 'dQdi\_dVds'});
% % Problems: there's a large and weird discontinuity in the derivative at 
% % 0 - looks like there are three expressions, one for -ve values, one at 0,
% % one for +ve values.  Plus, the capacitance becomes negative around Vds=1.1
% % even when Cof is at its default nonzero value. It becomes negative earlier
% % if Cof=0.
%
% % To try to explain the fact that switching the gate leads to voltages
% % much greater than the VDD supply (as seen by the transient simulation
% % above), we hypothesize that, roughly, Cds is lowered as Vgs increases
% % from 0. To understand this better, we make a 3D plot of Qdi and dQdi_dVds
% % vs Vds and Vgs:
% tic; profile on;
% vsb = 0.0; vsib = 0.0;
% vdibs = -1:0.01:2;
% %vdibs = 0.9:0.01:1.1;
% vgbs = (0:0.02:1).';;
% Qds = []; dQd_dVds = [];
% for j=1:length(vgbs)
%   vgb = vgbs(j);
%   for i=1:length(vdibs)
%     vdib = vecvalder(vdibs(i), 'indep'); vdb = vdib;
%     vecX = [vdb; vgb; vsb]; vecY = [vdib; vsib];
%     % have to have vecLim because qi is not backward-compatible yet
%     % vecLim = [vdblim, vgblim, vsblim]
%     vecLim = vecX;
%     vecW = feval(MVSMOD.qi, vecX, vecY, vecLim, MVSMOD); 
%            %vecW = [KCL-di; KCL-si], hence the first entry is Qdi
%     Qd = vecW(1);
%     Qds(j,i) = val2mat(Qd);
%     dQd_dVds(j,i) = der2mat(Qd);
%   end
% end
% toc
% profile viewer;
% figure; 
% VgbMat = vgbs * ones(1, length(vdibs));
% VdibMat = ones(length(vgbs),1) * vdibs;
% surf(VgbMat, VdibMat, Qds);
% ylabel 'Vds'; xlabel 'Vgs';  zlabel('Qdi');
% Cif = feval(MVSMOD.getparms, 'Cif', MVSMOD);
% Cof = feval(MVSMOD.getparms, 'Cof', MVSMOD);
% vxo = feval(MVSMOD.getparms, 'vxo', MVSMOD);
% title(sprintf('MVS with vxo=%g, Cif=%g, Cof=%g: Qdi vs Vdis and Vgs', ...
%       vxo, Cif, Cof));
% figure; 
% surf(VgbMat, VdibMat, dQd_dVds);
% ylabel 'Vds'; xlabel 'Vgs';  zlabel('dQdi\_dVdis');
% title(sprintf('MVS with vxo=%g, Cif=%g, Cof=%g: Cdsi vs Vdis and Vgs', ...
%       vxo, Cif, Cof));

% Author: J Roychowdhury, 2014/06/15 (copied from Tianshi's MVSamp_ckt.m and 
%         modified)


	MVSMOD = MVS_1_0_1_ModSpec_wrapper();
	% ckt name
	cktnetlist.cktname = 'MVS + drain resistor ckt for negcap dbg';

	% nodes (names)
	cktnetlist.nodenames = {'vdd', 'gate', 'drain'};
	cktnetlist.groundnodename = 'gnd';

    % pulse function with period 20ps
    trfunc = @(t, args) pulse(t/20e-12, 0, 0.1, 0.5, 0.6);

	% VGG
	cktnetlist = add_element(cktnetlist, vsrcModSpec(), 'VGG', ...
                                    {'gate', 'gnd'}, {}, {{'E', {'DC', 1.0}}});

	% VDD
	cktnetlist = add_element(cktnetlist, vsrcModSpec(), 'VDD', ...
                                    {'vdd', 'gnd'}, {}, ...
                                    {{'E', {'DC', 1.0}, {'tr', trfunc, []}}});
	% NMOS
	cktnetlist = add_element(cktnetlist, MVSMOD, 'NMOS', ...
                                    {'drain', 'gate', 'gnd', 'gnd'}); % default parms
	% R
	cktnetlist = add_element(cktnetlist, resModSpec(), 'R', ...
                                    {'vdd', 'drain'}, 10000.0);
end
