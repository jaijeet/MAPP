DAE =  MNA_EqnEngine(BJTdiffpair_ckt());

% list all unknown names
DAE.unknames(DAE) % equivalent to feval(DAE.unknames, DAE)

% list all output names
DAE.outputnames(DAE) % equivalent to feval(DAE.outputnames, DAE)

% set up state outputs "manually"
souts = StateOutputs(DAE);
souts = souts.DeleteAll(souts);
souts = souts.Add({'e_nCL', 'e_nCR', 'e_Vin', 'e_nE'}, souts);

% run a DC operating point analysis
dcop = dot_op(DAE);
% print DC operating point
feval(dcop.print, dcop);

qssSol = feval(dcop.getsolution, dcop);
uDC = dcop.getDCinputs(dcop);

inobj = Inputs(DAE);
outs = StateOutputs(DAE);
outs = outs.DeleteAll(outs);
outs = outs.Add({'e_nE', 'e_nCL', 'e_nCR'}, outs);

SENS = QSSsens(DAE, qssSol, uDC, inobj, 'input');
% direct
adjoint = 0;
SENS = feval(SENS.solve, outs, adjoint, SENS);
SENS.print(SENS);
SENS.plot(SENS);
% adjoint
adjoint = 1;
SENS = feval(SENS.solve, outs, adjoint, SENS);
SENS.print(SENS);
SENS.plot(SENS);

% parameter sensitivity
pobj = Parameters(DAE);
pobj = feval(pobj.Delete, {'QL:::tipe', 'QR:::tipe'}, pobj); % remove unrelated parms

SENS = QSSsens(DAE, qssSol, uDC, pobj);

% Direct sensitivity computation
adjoint = 0;
SENS = feval(SENS.solve, outs, adjoint, SENS);
SENS.print(SENS);
SENS.plot(SENS);

