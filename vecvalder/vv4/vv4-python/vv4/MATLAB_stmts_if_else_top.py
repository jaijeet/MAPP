
from vv4_python.BDD_utils import BDD

def scopify(zi):

    def zj(indent_level, tabstop, scope, context, B):

        key = zi.__name__
        available_context = scope.get(key, None)

        if available_context is context:
            return

        if available_context is not None and B.AND(context, available_context) is context:
            return

        if available_context is None or B.is_False(B.AND(context, available_context)):
            yield from zi(indent_level, tabstop, scope, context, B)
        else:
            not_available_context = B.NOT(available_context)
            new_context = B.AND(context, not_available_context)
            indent = (indent_level*tabstop)*' '
            expr = B.to_MATLAB_expression(not_available_context)
            if len(expr) < 80:
                yield '%sif (%s)\n' % (indent, B.to_MATLAB_expression(not_available_context))
                yield from zi(indent_level + 1, tabstop, scope, new_context, B)
                yield '%send\n' % indent
            else:
                yield from zi(indent_level, tabstop, scope, context, B)

        if available_context is None:
            scope[key] = context
        else:
            scope[key] = B.OR(available_context, context)

    return zj


def yield_indent(indent_level, tabstop, s):
    yield ((indent_level * tabstop) * ' ' + s + '\n')


