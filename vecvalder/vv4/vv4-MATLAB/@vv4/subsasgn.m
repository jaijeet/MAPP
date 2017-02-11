function out = subsasgn(lhs, S, rhs)

    if (strcmp(S.type, '{}') || strcmp(S.type, '.'))
        error('vv4 subasgn does not support {} and . yet.');
    end

    lhs_is_vv4 = isa(lhs, 'vv4');
    rhs_is_vv4 = isa(rhs, 'vv4');

    if (lhs_is_vv4 && ~rhs_is_vv4)
        rhs_vv4 = const_array_to_vv4(rhs);
        out = subsasgn(lhs, S, rhs_vv4);
    elseif (~lhs_is_vv4 && rhs_is_vv4)
        lhs_padded_with_zeros_if_necessary = subsasgn(lhs, S, 0);
        lhs_vv4 = const_array_to_vv4(lhs_padded_with_zeros_if_necessary);
        out = subsasgn(lhs_vv4, S, rhs);
    else
        out = builtin('subsasgn', lhs, S, rhs);
    end

end

function out = const_array_to_vv4(A)
    [num_rows, num_cols] = size(A);
    for row_idx = 1:1:num_rows
        for col_idx = 1:1:num_cols
            out(row_idx, col_idx) = vv4('CONST', A(row_idx, col_idx));
        end
    end
end

