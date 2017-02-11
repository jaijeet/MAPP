function varargout = flexOutput(varargin)
%function varargout = flexOutput(varargin)
%To define anonymous functions that behave like ordinary functions with
%respect to multiple output arguments, you could just define a utility
%function.
%
%See the user responses at:
% http://blogs.mathworks.com/loren/2007/01/31/multiple-outputs/
	varargout = varargin;
%once and for all. Then you can write
%
%fmeanVar = @(x) flexOutput(mean(x), var(x))
%
%and the following all work:
%
%[m,v] = fmeanVar(magic(3))
%m = fmeanVar(magic(3))
%fmeanVar(magic(3))
