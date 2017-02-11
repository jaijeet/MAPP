function newstr = escape_special_characters(str)
%function newstr = escape_special_characters(str)
%Replaces the following in str (mainly for use in plots):
%1. _ and ^ replaced by \_ and \^, respectively.
%
%Author: J. Roychowdhury, 2015/05/31.
%
    newstr = regexprep(str, '([^\\])_', '$1\\_');
    newstr = regexprep(newstr, '([^\\])\^', '$1\\^');
end
