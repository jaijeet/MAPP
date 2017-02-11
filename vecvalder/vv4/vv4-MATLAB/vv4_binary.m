function out = vv4_binary (u, v, op)

    global vv4_global_array;

    if ~isa (u, 'vv4')
        u = vv4('CONST', u);
    end

    if ~isa(v, 'vv4')
        v = vv4('CONST', v);
    end

    out = vv4('FUNC', op, [u.idx, v.idx]);

end
