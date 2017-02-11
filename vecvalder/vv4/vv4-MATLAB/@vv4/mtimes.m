function out = mtimes (u, v)
    if size(u,1) == 1 && size(u,2) == 1 && size(v,1) == 1 && size(v,2) == 1
        out = scalar_mtimes(u, v);
    elseif isempty(u) || isempty(v)
        % hack
        out = vv4('CONST', 'EMPTY_MATRIX');
    else
        nrows_u = size(u, 1);
        ncols_v = size(v, 2);
        for r = 1:1:nrows_u
            for c = 1:1:ncols_v
                S = 0.0;
                for k = 1:1:size(u,2)
                    if isnumeric(u(r,k)) && u(r,k) == 0
                        continue;
                    elseif isnumeric(v(k,c)) && v(k,c) == 0
                        continue;
                    else
                        S = S + scalar_mtimes(u(r,k), v(k,c));
                    end
                end
                if isnumeric(S)
                    S = vv4('CONST', S);
                end
                out(r,c) = S;
            end
        end
    end
end

function out = scalar_mtimes(u, v)
    if isa(u, 'vv4') && isa(v, 'vv4') && strcmp(u.Type, 'CONST') && strcmp(v.Type, 'CONST')
        out = vv4('CONST', u.val*v.val);
    elseif isa(u, 'vv4') && strcmp(u.Type, 'CONST') && u.val == 1.0
        out = v;
    elseif isa(v, 'vv4') && strcmp(v.Type, 'CONST') && v.val == 1.0
        out = u;
    else
        out = vv4_binary(u, v, 'MTIMES');
    end
end

