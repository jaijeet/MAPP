% add ModSpec paths
% add ModSpec paths
% add ModSpec paths
MODSPECDIR='/home/jr/local/pkgs/ModSpec/lib/ModSpec/';
MODSPECUTILS=sprintf('%s/utils', MODSPECDIR);
MODSPECTESTS=sprintf('%s/test-scripts', MODSPECDIR);
SMOOTHINGFUNCS=sprintf('%s/smoothingfuncs', MODSPECDIR);
addpath(MODSPECDIR);
addpath(MODSPECTESTS);
addpath(MODSPECUTILS);
addpath(SMOOTHINGFUNCS);

global NETLISTPARSERPATH;
NETLISTPARSERPATH='/home/jr/local/pkgs/NetlistParser-for-DAEAPI';
global NETLISTPARSERBINPATH;
NETLISTPARSERBINPATH=sprintf('%s/bin', NETLISTPARSERPATH);
global NETLISTPARSER;
NETLISTPARSER=sprintf('%s/run_parser.sh', NETLISTPARSERBINPATH);
%addpath(NETLISTPARSERBINPATH);
global CYGWINPREFIX;

%DO_NOT_INCLUDE_IN_HELP
