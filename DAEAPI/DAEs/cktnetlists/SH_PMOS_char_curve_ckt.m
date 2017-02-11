clear all;

cktnetlist.cktname = 'test_PMOS';
cktnetlist.nodenames = {'dd', 'ss'};
cktnetlist.groundnodename = 'gg';

Vd = 2;
Vs = 1;
k = 8e-6;

cktnetlist = add_element(cktnetlist, vsrcModSpec(), 'VD', {'dd', 'gg'}, {}, {{'E', {'DC', Vd}}});
cktnetlist = add_element(cktnetlist, vsrcModSpec(), 'VS', {'ss', 'gg'}, {}, {{'E', {'DC', Vs}}});

cktnetlist = add_element(cktnetlist, SH_MOS_ModSpec(), 'M1', {'dd', 'gg', 'ss'}, {{'Type', 'P'}, {'Beta', k*270/180}, {'VT', 0.3}}, {});

DAE = MNA_EqnEngine(cktnetlist);

% run DC
NRparms = defaultNRparms();
NRparms.limiting = 0;
qss = QSS(DAE, NRparms);
qss = feval(qss.solve, qss);
feval(qss.print, qss);
DCsol = feval(qss.getsolution, qss);
