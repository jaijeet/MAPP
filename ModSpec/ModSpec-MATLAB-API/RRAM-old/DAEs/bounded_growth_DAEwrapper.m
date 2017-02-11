function DAE = bounded_growth_DAEwrapper()
%function DAE = bounded_growth_DAEwrapper()
%
%TODO: update descriptions:
%
%Examples
%--------
%
%DAE = bounded_growth_DAEwrapper();
%tranObj = tr(DAE, [1e-2], 0, 1e-3, 2); tranObj.plot(tranObj);
%
    DAE = init_DAE();

    DAE = add_to_DAE(DAE, 'name', 'bounded variable x');
    DAE = add_to_DAE(DAE, 'unkname(s)', {'x'});
    DAE = add_to_DAE(DAE, 'eqnname(s)', {'eqn1'});

    % DAE = add_to_DAE(DAE, 'parm(s)', {});

    DAE = add_to_DAE(DAE, 'f', @f);
    DAE = add_to_DAE(DAE, 'q', @q);

    DAE = finish_DAE(DAE);
end

function fout = f(S)
    v2struct(S);
    if x < 1 && x > 0
		fout = 1;
    elseif x <= 0
		fout = x;
    else % x >= 1
		fout = x-1;
    end
end % f(...)

function qout = q(S)
    v2struct(S);
    if x < 1 && x > 0
		qout = -x;
    elseif x <= 0
		qout = 0;
    else % x >= 1
		qout = 0;
    end
end % q(...)
