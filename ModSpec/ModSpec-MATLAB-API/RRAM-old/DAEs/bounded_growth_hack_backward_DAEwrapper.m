function DAE = bounded_growth_hack_backward_DAEwrapper()
%function DAE = bounded_growth_hack_backward_DAEwrapper()
%
%TODO: update descriptions:
%
%Examples
%--------
%
%DAE = bounded_growth_hack_backward_DAEwrapper();
%tranObj = tr(DAE, [0.99], 0, 1e-3, 2); tranObj.plot(tranObj);
%
    DAE = init_DAE();

    DAE = add_to_DAE(DAE, 'name', 'bounded variable x');
    DAE = add_to_DAE(DAE, 'unkname(s)', {'x'});
    DAE = add_to_DAE(DAE, 'eqnname(s)', {'eqn1'});

    DAE = add_to_DAE(DAE, 'parm(s)', {'smoothing', 1e-10});

    DAE = add_to_DAE(DAE, 'f', @f);
    DAE = add_to_DAE(DAE, 'q', @q);

    DAE = finish_DAE(DAE);
end

function fout = f(S)
    v2struct(S);

    clip_ge1 = smoothstep(x-1, smoothing);
    clip_le0 = 1 - smoothstep(x, smoothing);
    clip_01 = 1 - clip_le0 - clip_ge1;

    % fout = 1 * clip_01 + (1-exp(10*x)) * clip_ge1 + (exp(-10*x)) * clip_le0;
    fout = -exp(x) * clip_01 + (1-exp(10*x)) * clip_ge1 + (exp(-10*x)) * clip_le0;
end % f(...)

function qout = q(S)
    v2struct(S);
    qout = -x;
end % q(...)
