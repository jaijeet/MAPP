function h = log(u)

    f_handle = @log;
    df_handle = @(x) (1./x);

    num_indeps = size(u.valder, 2)-1;
    hval = f_handle(u.valder(:,1));
    dhval = df_handle(u.valder(:,1));

    h = vv3(hval, repmat(dhval, [1 num_indeps]).*u.valder(:,2:end));

end
