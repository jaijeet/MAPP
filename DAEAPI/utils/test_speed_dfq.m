% Some results from this script:
% n = 2000;
% 
%  - original: 3.706756
%      doSpeedup = 1;
%      only_fq = 0;
% 
%  - commented out vecvalder checks in dfq_dxxlimu_auto: 2.453186
% 
%  - then commented out nargins checks in dfq_dxxlimu_auto: 2.439490
% 
%  - change to evaluate f/q/etc. separately
%          fq.f = DAE.f(x, u, DAE);
%          fq.q = DAE.q(x, DAE);
%          J.dfdx = DAE.df_dx(x, u, DAE);
%          J.dfdx = DAE.df_dx(x, u, DAE);
%          J.dqdx = DAE.dq_dx(x, DAE);
%     only 0.146133!!
%  
%   - restored everything
%   - commented out output assignment section:
%      Elapsed time is 3.131276 seconds.
%      Elapsed time is 3.308356 seconds.
%      Elapsed time is 3.131219 seconds.
%      Elapsed time is 3.166245 seconds.
%      Elapsed time is 3.134949 seconds.
%  
%   - restored everything
%  
%   - tried fq vs. f/q
%     fq:
%       Elapsed time is 0.174446 seconds.
%     f and q:
%       Elapsed time is 0.054434 seconds.
% 
  
    epsilon = -0.0001; % try this with utfunc2 to see continuous cycle
              % slipping
    epsilon = +100; % stable lock, solid/robust
    epsilon = 1e-10; % stable lock, but only just about (with utfunc2)
    %epsilon = 2e-11; % cycle slipping (with utfunc2)
    %epsilon = +0.0000; % cycle slipping with utfunc2
    f0 = 1e9; f1 = 0.9e9; f2 = 1.1e9;
    VCOgain = (2*pi+epsilon)*1e8; 
    %
    DAE =  UltraSimplePLL_DAEAPIv6('somename', f0, VCOgain);

    x = ones(DAE.nunks(DAE), 1);
    u = ones(DAE.ninputs(DAE), 1);

    n = 2000;

    doSpeedup = 1;
    only_fq = 0;

    if only_fq
        if doSpeedup
            flag.f = 1; flag.q = 1;
            tic;
            for c = 1:n
                [fout, qout] = DAE.fq(x, u, flag, DAE);
                % fprintf('.');
            end
            toc;
        else
            tic;
            for c = 1:n
                fout = DAE.f(x, u, DAE);
                qout = DAE.q(x, DAE);
                % fprintf('.');
            end
            toc;
        end
    else
        if doSpeedup
            tic;
            for c = 1:n
                [fq, J] = dfq_dxxlimu_auto(x, u, DAE);
                % fprintf('.');
            end
            toc;
        else
            tic;
            for c = 1:n
                fq.f = DAE.f(x, u, DAE);
                fq.q = DAE.q(x, DAE);
                J.dfdx = DAE.df_dx(x, u, DAE);
                J.dfdx = DAE.df_dx(x, u, DAE);
                J.dqdx = DAE.dq_dx(x, DAE);
                % fprintf('.');
            end
            toc;
        end
    end
