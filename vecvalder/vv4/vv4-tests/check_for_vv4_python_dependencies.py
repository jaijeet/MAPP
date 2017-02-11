
import sys

try:

    # check for Python version >= 3.4
    major_reqd, minor_reqd = 3, 4
    ver_reqd = '%d.%d' % (major_reqd, minor_reqd)
    ver_info = sys.version_info
    major, minor, micro = ver_info.major, ver_info.minor, ver_info.micro
    ver = '%d.%d.%d' % (major, minor, micro)
    if major < major_reqd or (major == major_reqd and minor < minor_reqd):
        raise Exception('ERROR: vv4 requires python version >= %s, found %s instead' % (ver_reqd, ver))

    # check for prettytable
    try:
        import prettytable
    except:
        raise Exception('ERROR: vv4 requires prettytable, but unable to import it')

    # check for jinja2
    try:
        import jinja2
    except:
        raise Exception('ERROR: vv4 requires jinja2, but unable to import it')

    # print('Yay! Found a suitable python version with all the necessary libraries!')

except:

    sys.exit(1)

