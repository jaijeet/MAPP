clear ntlst;

ntlst.cktname = 'circuit to test mutualInductor element';
ntlst.nodenames = {'e1', 'pL1', 'pL2', 'e2'};
ntlst.groundnodename = 'nL1L2';

vM = vsrcModSpec();
ntlst = add_element(ntlst, vM, 'v1', {'e1', 'nL1L2'});
ntlst = add_element(ntlst, vM, 'v2', {'e2', 'nL1L2'});
ntlst = add_element(ntlst, resModSpec(), 'r1', {'e1', 'pL1'}, 1e3);
ntlst = add_element(ntlst, resModSpec(), 'r2', {'e2', 'pL2'}, 1e3);
ntlst = add_element(ntlst, mutualInductor_ModSpec_wrapper(), 'L1L2M', {'pL1', 'nL1L2', 'pL2', 'nL1L2'}, {{'L1', 1e-4}, {'L2', 1e-4}, {'K', 0.0}} );
ntlst = add_output(ntlst, 'e1', 'pL1');
ntlst = add_output(ntlst, 'e2', 'pL2');

DAE = MNA_EqnEngine(ntlst);

inputvoltage1 = @(t, args) pulse(t/1e-6);
inputvoltage2 = @(t, args) -pulse(t/1e-6);

DAE = DAE.set_utransient('v1:::E', inputvoltage1, [], DAE);
DAE = DAE.set_utransient('v2:::E', inputvoltage2, [], DAE);

TR1 = transient(DAE, [], 0, 1e-8, 2e-6);
[figh, legends, colindex] = TR1.plot(TR1);

DAE = DAE.setparms('L1L2M:::K', 0.5, DAE);
TR2 = transient(DAE, [], 0, 1e-8, 2e-6);
[figh, legends, colindex] = TR2.plot(TR2, [], 'K=0.5', 'x-', figh, legends, colindex);

DAE = DAE.setparms('L1L2M:::K', -0.5, DAE);
TR3 = transient(DAE, [], 0, 1e-8, 2e-6);
[figh, legends, colindex] = TR3.plot(TR3, [], 'K=-0.5', 'o-', figh, legends, colindex);

DAE = DAE.setparms('L1L2M:::K', 1, DAE);
TR4 = transient(DAE, [], 0, 1e-8, 2e-6);
[figh, legends, colindex] = TR4.plot(TR4, [], 'K=1', 'o-', figh, legends, colindex);

DAE = DAE.setparms('L1L2M:::K', -1, DAE);
TR5 = transient(DAE, [], 0, 1e-8, 2e-6);
[figh, legends, colindex] = TR5.plot(TR5, [], 'K=-1', 'o-', figh, legends, colindex);
