function h = exp(u)
    
    num_indeps = size(u.valder, 2)-1;
    hval = exp(u.valder(:,1));

    % h = vv2(hval, repmat(hval, [1 num_indeps]).*u.valder(:,2:end));
    h = vv2(hval, hval*ones(1, num_indeps).*u.valder(:,2:end));

end

