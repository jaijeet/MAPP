function out = vertcat(varargin)
    global isOctave;
    if ~isOctave
        out = builtin('vertcat', varargin{:});
    else
        out = vertcat_octave(varargin{:});
    end
end

function out = vertcat_octave(varargin)

    if isa(varargin{1}, 'vv4')
        out = varargin{1};
        count = length(out);
        start_at = 2;
    else
        count = 0;
        start_at = 1;
    end

    for i = start_at:1:nargin
        vec_i = varargin{i};
        for j = 1:1:length(vec_i)
            count = count + 1;
            if isa(vec_i(j), 'vv4')
                out(count, 1) = vec_i(j);
            else
                out(count, 1) = vv4('CONST', vec_i(j));
            end
        end
    end

end

