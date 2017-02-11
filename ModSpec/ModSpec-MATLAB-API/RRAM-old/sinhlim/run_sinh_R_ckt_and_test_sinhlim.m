fprintf('Creating circuit and DAE0 with sinhIV model...\n');
DAE0 = MNA_EqnEngine(sinh_R_ckt(0));
fprintf('Creating circuit and DAE1 with sinhIV_initlimiting model...\n');
DAE1 = MNA_EqnEngine(sinh_R_ckt(1));
fprintf('\n');

% test different input values
Vs = [1, 10, 100, 1000];
expectations = {'Both should run just fine at 1V.', 'Both should run, but DAE0 takes more iters.', ...
'Both should run, but DAE0 takes more iters.', 'DAE0 should fail, DAE1 converges easily.'};
for c = 1:length(Vs)
    fprintf('\n');
	fprintf('Press enter to run dot_op on DAE0 and DAE1 with %gV input.\n', Vs(c));
	fprintf('%s\n', expectations{c});
	pause;
	echo on; 
		DAE0 = DAE0.set_uQSS('V1:::E', Vs(c), DAE0);
		% DC operating point
		dcop0 = dot_op(DAE0);
		dcop0.print(dcop0);

		DAE1 = DAE1.set_uQSS('V1:::E', Vs(c), DAE1);
		% DC operating point
		dcop1 = dot_op(DAE1);
		dcop1.print(dcop1);
	echo off; 
end

DAE0 = DAE0.set_uQSS('V1:::E', 1, DAE0);
DAE1 = DAE1.set_uQSS('V1:::E', 1, DAE1);

% test different parameter values
fprintf('\n');
fprintf('Press enter to run dot_op on DAE0 and DAE1 with ''S1:::k'' = 1e3.\n');
pause;
echo on; 
	DAE0 = DAE0.setparms('S1:::k', 1e3, DAE0);
	% DC operating point
	dcop0 = dot_op(DAE0);
	dcop0.print(dcop0);

	DAE1 = DAE1.setparms('S1:::k', 1e3, DAE1);
	% DC operating point
	dcop1 = dot_op(DAE1);
	dcop1.print(dcop1);
echo off; 

fprintf('\n');
fprintf('Press enter to run dot_op on DAE0 and DAE1 with ''S1:::k'' = 1e9.\n');
pause;
echo on; 
	DAE0 = DAE0.setparms('S1:::k', 1e9, DAE0);
	% DC operating point
	dcop0 = dot_op(DAE0);
	dcop0.print(dcop0);

	DAE1 = DAE1.setparms('S1:::k', 1e9, DAE1);
	% DC operating point
	dcop1 = dot_op(DAE1);
	dcop1.print(dcop1);
echo off; 

DAE0 = DAE0.setparms('S1:::k', 1, DAE0);
DAE1 = DAE1.setparms('S1:::k', 1, DAE1);

fprintf('\n');
fprintf('Press enter to run dot_op on DAE0 and DAE1 with ''S1:::A'' = 1e-6.\n');
pause;
echo on; 
	DAE0 = DAE0.setparms('S1:::A', 1e-6, DAE0);
	% DC operating point
	dcop0 = dot_op(DAE0);
	dcop0.print(dcop0);

	DAE1 = DAE1.setparms('S1:::A', 1e-6, DAE1);
	% DC operating point
	dcop1 = dot_op(DAE1);
	dcop1.print(dcop1);
echo off; 

DAE0 = DAE0.setparms('S1:::A', 1, DAE0);
DAE1 = DAE1.setparms('S1:::A', 1, DAE1);

