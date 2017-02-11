function out = optget(varargin)
% function value = optget(opts, name, def)
% function outopts = optget(opts,  defopts)
%author: Tianshi Wang <tianshi@berkeley.edu> 2013/01/08
%
% Inputs & Outputs: 
% 1) value = optget(opts, name, def)
%    opts: options
%    name: opts.name
%    def: default value
%    value: opts.name's value, if not a field, use default
%
% 2) outopts = optget(opts,  defopts)
%    opts: input option's name
%    defopts: default option's name
%    outopts: output options
%
if 3 == nargin 
	opts = varargin{1};
	name = varargin{2};
	def = varargin{3};
	% value = optget(opts, name, def)
	if ~isa(opts,'struct')
	    value = def;
	    return;
	end

	if isfield(opts,name)
	    value=opts.(name);
	else
	    value=def;
	end
	out = value;
elseif 2 == nargin 
	opts = varargin{1};
	defopts = varargin{2};
	% outopts = optget(opts,  defopts)
	if ~isa(opts,'struct')
	    outopts = defopts;
	    return;
	end
	
	names = fieldnames(defopts);
	outopts = defopts;
	for c = 1 : length(names)
		if ~isa(defopts.(names{c}), 'struct')
		    outopts.(names{c}) = optget(opts, names{c}, defopts.(names{c}));
	        else
		    if isfield(opts, names{c}) && isa(opts.(names{c}), 'struct')
		    outopts.(names{c}) = optget(opts.(names{c}), defopts.(names{c}));
		    else
		    outopts.(names{c}) = defopts.(names{c});
		    end
	        end
	end
	out = outopts;
else
	fprintf('optget usage: function value = optget(opts, name, def)\n');
	fprintf('         or   function outopts = optget(opts,  defopts)\n');
	error('illegel input for optget: check usage above\n');
end
