
jinja2_filters = {}

def jinja2_filter(f):
    jinja2_filters[f.__name__] = f
    return f

@jinja2_filter
def as_string(s):
    return "'%s'" % s

@jinja2_filter
def as_cell_array(l, separate_lines_threshold=5, num_format='%1.12e'):
    if separate_lines_threshold is None or len(l) <= separate_lines_threshold:
        return '{%s}' % ', '.join(_str(x, num_format) for x in l)
    return '{ ...\n' + ''.join((4*' ' + _str(x, num_format) + ', ...\n') for x in l) + '}'

@jinja2_filter
def as_matrix(arr, num_format='%1.12e'):
    if not arr:
        return '[]'
    return '[ ...\n' + ''.join((4*' ' + ', '.join(num_format % ele for ele in row) + '; ...\n') for row in arr) + ']'

def _str(v, num_format):
    assert type(v) in [int, float, str, bool], ('ERROR: Unexpected data type %s' % str(type(v)))
    if type(v) is int:
        return str(v)
    if type(v) is float:
        return num_format % v
    if type(v) is str:
        return as_string(v)
    if type(v) is bool:
        return 'true' if v else 'false'

