function out = plus (u, v)
    if size(u,1) == 1 && size(u,2) == 1 && size(v,1) == 1 && size(v,2) == 1
        out = scalar_plus(u, v);
    else
        nrows = size(u, 1);
        ncols = size(u, 2);
        for r = 1:1:nrows
            for c = 1:1:ncols
                out(r,c) = scalar_plus(u(r,c), v(r,c));
            end
        end
    end
end

function out = scalar_plus(u, v)
    if isa(u, 'vv4') && isa(v, 'vv4') && strcmp(u.Type, 'CONST') && strcmp(v.Type, 'CONST')
        out = vv4('CONST', u.val+v.val);
    else
        out = vv4_binary(u, v, 'PLUS');
    end
end

