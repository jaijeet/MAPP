function n = numel(varargin)
  %VECVALDER/numel overloads numel for a list of vecvalders
  %crucial for subsref and subsasgn to work right with vv{1:5} style indexing
  % see this thread:
  % http://www.mathworks.com/matlabcentral/newsreader/view_thread/107308

  %n = builtin('numel', varargin{2});
  n=1;
end
