% set up NetlistParser paths
global PARSERPATH;
% TODO: autoconf/configure should set up PARSERPATH
PARSERPATH='__NETLISTPARSERINSTALLDIR__';
global PARSERBINPATH;
PARSERBINPATH=sprintf('%s/bin', PARSERPATH);
global PARSER;
PARSER=sprintf('%s/run_parser.sh', PARSERBINPATH);
%addpath(PARSERBINPATH);
global PARSERLIBPATH;
PARSERLIBPATH=sprintf('%s/lib/NetlistParser-for-DAEAPI', PARSERPATH);
global CYGWINPREFIX;

% set up ModSpec paths
% TODO: autoconf/configure should set up MODSPECDIR
MODSPECINSTALLDIR='__MODSPECINSTALLDIR__';
MODSPECUTILS=sprintf('%s/lib/ModSpec/ModSpec-MATLAB-API/utils', MODSPECINSTALLDIR);
addpath(MODSPECUTILS);
setuppaths_ModSpec;

% set up vecvalder paths (should already by done by ModSpec, but still...)
VECVALDERINSTALLDIR='__VECVALDERINSTALLDIR__';
VVUTILS=sprintf('%s/lib/vecvalder/utils', VECVALDERINSTALLDIR);
addpath(VVUTILS);
setuppaths_vecvalder;

% set up DAEAPI paths
DAEAPIINSTALLDIR='__DAEAPIINSTALLDIR__';
DAEAPIDIR=sprintf('%s/lib/DAEAPI/', DAEAPIINSTALLDIR);
DAEAPI_UTILS=sprintf('%s/utils', DAEAPIDIR);
DAEAPI_DAEs=sprintf('%s/DAEs', DAEAPIDIR);
DAEAPI_devicemodels=sprintf('%s/device-models', DAEAPIDIR);
DAEAPI_testscripts=sprintf('%s/test-scripts', DAEAPIDIR);
DAEAPI_doc=sprintf('%s/doc', DAEAPIDIR);

addpath(DAEAPI_UTILS);
addpath(DAEAPI_DAEs);
addpath(DAEAPI_devicemodels);
addpath(DAEAPI_testscripts);
addpath(DAEAPI_doc);
