function out = vv4_trinary (u, v, w, op)

    global vv4_global_array;

    if ~isa (u, 'vv4')
        u = vv4('CONST', u);
    end

    if ~isa(v, 'vv4')
        v = vv4('CONST', v);
    end

    if ~isa(w, 'vv4')
        w = vv4('CONST', w);
    end

    out = vv4('FUNC', op, [u.idx, v.idx, w.idx]);

end
