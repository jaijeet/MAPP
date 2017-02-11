function out = sign2(in)
%function out = sign2(in)
%like sign(in) except that sign2(0)=1 (not 0).
%JR, 2014/05/06
    out = 2*(in >= 0) - 1;
end
