% 
% 
% add paths to DAEAPI dirs and then call DAEAPI's setuppaths_DAEAPI
% 
DAEAPIDIR='/home/jr/local/pkgs/DAEAPI/lib/DAEAPI/';
DAEAPI_UTILS=sprintf('%s/utils', DAEAPIDIR);
addpath(DAEAPI_UTILS);

setuppaths_DAEAPI();
