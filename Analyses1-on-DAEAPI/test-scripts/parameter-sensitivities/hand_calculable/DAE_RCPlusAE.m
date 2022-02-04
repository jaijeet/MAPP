function DAE = DAE_RCPlusAE()
    DAE = DAEAPI_common_skeleton();
    DAE.nameStr = sprintf('First-order RC circuit + Algebraic Eqn');
    DAE.unknameList = {'vC', 'x2'};
    DAE.eqnnameList = {'C_NA', 'AE'};
    DAE.inputnameList = {'Vin', 't'};
    DAE.outputnameList = {'DAEout'};
    DAE.parmnameList = {'R', 'C'};
    DAE.parms = parmdefaults(DAE);

    DAE.parmdefaults = @parmdefaults;

    DAE.f = @f;
    DAE.q = @q;
    DAE.df_dx = @df_dx;
    DAE.dq_dx = @dq_dx;
    DAE.df_du = @df_du;
    DAE.f_takes_inputs = 1;
    DAE.C = @C;

    function out = parmdefaults(DAE)
        % Default R, C
        out = {1e3, 1e-6};
    % end parmdefaults

    function out = f(x, u, DAE)
        R = DAE.parms{1};
        C = DAE.parms{2};
        x1 = x(1, 1);
        x2 = x(2, 1);
        Vin = u(1, 1);
        t = u(2, 1);
        out = [(x1 - Vin) / (R * C); x2 - t / (R * C)];
    % end f

    function out = q(x, DAE)
        out = [x(1, 1); 0];
    % end q
    
    function out = df_dx(x, u, DAE)
        R = DAE.parms{1};
        C = DAE.parms{2};
        x1 = x(1, 1);
        x2 = x(2, 1);
        Vin = u(1, 1);
        out = [1 /(R * C), 0; 0, 1];
    % end df_dx

    function out = dq_dx(x, DAE)
        x1 = x(1, 1);
        out = [1, 0; 0, 0];
    % end dq_dx

    function out = df_du(x, u, DAE)
        R = DAE.parms{1};
        C = DAE.parms{2};
        x1 = x(1, 1);
        out = [-1 / (R * C), 0; 0, -1 / (R*C)];
    % end df_du

    function out = C(DAE)
        out = [2, 0.1];
    % end C