function DAE = bounded_growth_smooth_DAEwrapper()
%function DAE = bounded_growth_smooth_DAEwrapper()
%
%TODO: update descriptions:
%
%Examples
%--------
%
%DAE = bounded_growth_smooth_DAEwrapper();
%tranObj = tr(DAE, [1e-3], 0, 1e-3, 2); tranObj.plot(tranObj);
%
    DAE = init_DAE();

    DAE = add_to_DAE(DAE, 'name', 'bounded variable x');
    DAE = add_to_DAE(DAE, 'unkname(s)', {'x'});
    DAE = add_to_DAE(DAE, 'eqnname(s)', {'eqn1'});

    DAE = add_to_DAE(DAE, 'parm(s)', {'smoothing', 1e-5});

    DAE = add_to_DAE(DAE, 'f', @f);
    DAE = add_to_DAE(DAE, 'q', @q);

    DAE = finish_DAE(DAE);
end

function fout = f(S)
    v2struct(S);

    % if x < 1 && x > 0
	% 	fout = 1;
    % elseif x <= 0
	% 	fout = x;
    % else % x >= 1
	% 	fout = x-1;
    % end
    clip_ge1 = smoothstep(x-1, smoothing);
    clip_le0 = 1 - smoothstep(x, smoothing);
    clip_01 = 1 - clip_le0 - clip_ge1;

    fout = 1 * clip_01 + x * clip_le0 + (x-1) * clip_ge1;
end % f(...)

function qout = q(S)
    v2struct(S);
    % if x < 1 && x > 0
	% 	qout = -x;
    % elseif x <= 0
	% 	qout = 0;
    % else % x >= 1
	% 	qout = 0;
    % end

    clip_ge1 = smoothstep(x-1, smoothing);
    clip_le0 = 1 - smoothstep(x, smoothing);
    clip_01 = 1 - clip_le0 - clip_ge1;

    qout = -x * clip_01;
end % q(...)
