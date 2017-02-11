% add path to ModSpec dir
MODSPECDIR='/home/jr/unison/code/DAEAPI-NetlistParser-ModSpec-vecvalder-Analyses/ModSpec-SVN/trunk/ModSpec-MATLAB-API';
MODSPECUTILS=sprintf('%s/utils', MODSPECDIR);
SMOOTHINGFUNCS=sprintf('%s/smoothingfuncs', MODSPECDIR);
addpath(MODSPECDIR);
addpath(MODSPECUTILS);
addpath(SMOOTHINGFUNCS);

global PARSERSRCPATH;
PARSERSRCPATH='/home/jr/unison/code/DAEAPI-NetlistParser-ModSpec-vecvalder-Analyses/NetlistParser-for-DAEAPI-SVN/trunk/';
global PARSERBINPATH;
PARSERBINPATH=sprintf('%s/C++', PARSERSRCPATH);
global PARSER;
PARSER=sprintf('%s/run_parser.sh', PARSERBINPATH);
%addpath(PARSERBINPATH);
global CYGWINPREFIX;
