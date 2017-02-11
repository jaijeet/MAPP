% set up DAE %
DAE = vsrc_diode_r_DAEAPIv1;

NRparms.method = 0;
NRparms.dbglvl = 2;
NRparms.do_init = 0;
NRparms.do_limit = 1;
qss = QSS(DAE, NRparms); %TODO NRparms seems to be a function, find it out!

qss = feval(qss.solve, [0;0;0.7], qss);
% access/print outputs
xQSS = feval(qss.getSolution, qss); % get the entire state vector x
% outvals = feval(qss.getOutputs, qss); % get the DAE's defined outputs (C * x + D * u)
feval(qss.print, qss); % print the DAE's defined outputs (C * x + D * u)

