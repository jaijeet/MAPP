function h = log(u)
%VECVALDER (vv2 version) - log() operator
%
%Author: Karthik Aadithya, 2014/06/14
%Updates: JR, 2014/06/16
%
    %num_indeps = size(u.valder, 2)-1;
    hval = log(u.valder(:,1)); % log
    dhval = 1./u.valder(:,1); % dlog_dx

    %h = vv2(hval, repmat(dhval, [1 num_indeps]).*u.valder(:,2:end));
    h = u; % copy for efficiency
    h.valder = [hval, diag(dhval)*u.valder(:,2:end)];
    %n = length(dhval);
    %h = vecvalder(hval, spdiags(dhval, 0, n, n)*u.valder(:,2:end));
end
