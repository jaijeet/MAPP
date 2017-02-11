% ckt name
cktdata.cktname = 'Double Balanced Diode Mixer with VCVS';

% nodes (names)
cktdata.nodenames = {'10', '1', '20', '4', '2', '3', '5', '6', '7'};
cktdata.groundnodename = '0';

% elements
cktdata.elements = {};

% vpElem
vpElem.name = 'vp';
vpElem.model = vsrcModSpec('vp');
vpElem.nodes = {'10', '0'};
vpElem.parms = feval(vpElem.model.getparms, vpElem.model);
	v_udata1.uname = 'E';
	v_udata1.QSSval = 2;
	vpElem.udata = {v_udata1};

cktdata.elements = {cktdata.elements{:}, vpElem};

% rpElem
rpElem.name = 'rp';
rpElem.model = resModSpec('rp');
rpElem.nodes = {'10', '1'};
rpElem.model = feval(rpElem.model.setparms, 'R', .01, rpElem.model);
rpElem.parms = feval(rpElem.model.getparms, rpElem.model);

cktdata.elements = {cktdata.elements{:}, rpElem};

% rrfElem
rrfElem.name = 'rrf';
rrfElem.model = resModSpec('rrf');
rrfElem.nodes = {'20', '4'};
rrfElem.model = feval(rrfElem.model.setparms, 'R', .01, rrfElem.model);
rrfElem.parms = feval(rrfElem.model.getparms, rrfElem.model);

cktdata.elements = {cktdata.elements{:}, rrfElem};

% vrfElem
vrfElem.name = 'vrf';
vrfElem.model = vsrcModSpec('vrf');
vrfElem.nodes = {'20', '0'};
vrfElem.parms = feval(vrfElem.model.getparms, vrfElem.model);
	v_udata2.uname = 'E';
	v_udata2.QSSval = -2;
	vrfElem.udata = {v_udata2};

cktdata.elements = {cktdata.elements{:}, vrfElem};

% ep1Elem
ep1Elem.name = 'ep1';
ep1Elem.model = vcvsModSpec('ep1');
ep1Elem.nodes = {'2', '0', '1', '0'};
ep1Elem.model = feval(ep1Elem.model.setparms, 'gain', 0.5, ep1Elem.model);
ep1Elem.parms = feval(ep1Elem.model.getparms, ep1Elem.model);

cktdata.elements = {cktdata.elements{:}, ep1Elem};

% ep2Elem
ep2Elem.name = 'ep2';
ep2Elem.model = vcvsModSpec('ep2');
ep2Elem.nodes = {'0', '3', '1', '0'};
ep2Elem.model = feval(ep2Elem.model.setparms, 'gain', 0.5, ep2Elem.model);
ep2Elem.parms = feval(ep2Elem.model.getparms, ep2Elem.model);

cktdata.elements = {cktdata.elements{:}, ep2Elem};

% er1Elem
er1Elem.name = 'er1';
er1Elem.model = vcvsModSpec('er1');
er1Elem.nodes = {'5', '6', '4', '0'};
er1Elem.model = feval(er1Elem.model.setparms, 'gain', 0.5, er1Elem.model);
er1Elem.parms = feval(er1Elem.model.getparms, er1Elem.model);

cktdata.elements = {cktdata.elements{:}, er1Elem};

% er2Elem
er2Elem.name = 'er2';
er2Elem.model = vcvsModSpec('er2');
er2Elem.nodes = {'6', '7', '4', '0'};
er2Elem.model = feval(er2Elem.model.setparms, 'gain', 0.5, er2Elem.model);
er2Elem.parms = feval(er2Elem.model.getparms, er2Elem.model);

cktdata.elements = {cktdata.elements{:}, er2Elem};

% d1Elem
d1Elem.name = 'd1';
d1Elem.model = diodeModSpec('d1');
d1Elem.nodes = {'2', '7'};
d1Elem.parms = feval(d1Elem.model.getparms, d1Elem.model);

cktdata.elements = {cktdata.elements{:}, d1Elem};

% d2Elem
d2Elem.name = 'd2';
d2Elem.model = diodeModSpec('d2');
d2Elem.nodes = {'5', '2'};
d2Elem.parms = feval(d2Elem.model.getparms, d2Elem.model);

cktdata.elements = {cktdata.elements{:}, d2Elem};

% d3Elem
d3Elem.name = 'd3';
d3Elem.model = diodeModSpec('d3');
d3Elem.nodes = {'7', '3'};
d3Elem.parms = feval(d3Elem.model.getparms, d3Elem.model);

cktdata.elements = {cktdata.elements{:}, d3Elem};

% d4Elem
d4Elem.name = 'd4';
d4Elem.model = diodeModSpec('d4');
d4Elem.nodes = {'3', '5'};
d4Elem.parms = feval(d4Elem.model.getparms, d4Elem.model);

cktdata.elements = {cktdata.elements{:}, d4Elem};

% rlifElem
rlifElem.name = 'rlif';
rlifElem.model = resModSpec('rlif');
rlifElem.nodes = {'6', '0'};
rlifElem.model = feval(rlifElem.model.setparms, 'R', 50, rlifElem.model);
rlifElem.parms = feval(rlifElem.model.getparms, rlifElem.model);

cktdata.elements = {cktdata.elements{:}, rlifElem};

DAE = MNA_EqnEngine(cktdata);
