function h = exp(u)
%VECVALDER (vv2 version) log() operator
%
%Author: Karthik Aadithya, 2014/06/14
%Updates: JR, 2014/06/16
%
    hval = exp(u.valder(:,1));

    % h = vv2(hval, repmat(hval, [1 num_indeps]).*u.valder(:,2:end));
    %       repmat is extremely slow
    h = u; % copy existing vecvalder => avoid calling constructor (efficiency)
    % h.valder = [hval, (hval*ones(1, num_indeps)).*u.valder(:,2:end)];
    h.valder = [hval, diag(hval)*u.valder(:,2:end)];
    % sparse version, may be more efficient for bigger vectors
    % n = length(hval);
    % h.valder = [hval, spdiags(hval, 0, n, )*u.valder(:,2:end)];
end
