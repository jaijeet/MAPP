
from glob import glob
from vv4.ModSpec_EE_Model import ModSpec_EE_Model

DAG_files_basedir = '/home/aadithya'
DAG_files_extension = '.dag'
ite = False

DAG_file_paths = glob(DAG_files_basedir + '/' + '*' + DAG_files_extension)
for idx, path in enumerate(DAG_file_paths):
    if idx > 0:
        print('')
    print('Importing model from %s ...' % path)
    MOD = ModSpec_EE_Model(path)
    print('Imported model with the following parameters: ')
    MOD.print_lengths()
    base_name = path.lstrip(DAG_files_basedir + '/').rstrip(DAG_files_extension) + '_vv4_' + ('ITE' if ite else 'if_else')
    out_dir = DAG_files_basedir
    print('Exporting optimized MATLAB code ...')
    MOD.export_optimized_MATLAB_code(out_dir, base_name, ite)
    print('Exported optimized MATLAB code: please see %s' % (out_dir + '/' + base_name + '.m'))

