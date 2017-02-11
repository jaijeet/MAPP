function varargout = subsref(obj, S)
    [varargout{1:nargout}] = builtin('subsref', obj, S);
end
