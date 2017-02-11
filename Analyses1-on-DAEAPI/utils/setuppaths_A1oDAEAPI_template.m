% TODO: DAEAPIDIR should be picked up from autoconf/.configure
% TODO: DAEAPIDIR should be picked up from autoconf/.configure
% add paths to DAEAPI dirs and then call DAEAPI's setuppaths_DAEAPI
DAEAPIINSTALLDIR='__DAEAPIINSTALLDIR__';
DAEAPI_UTILS=sprintf('%s/lib/DAEAPI/utils', DAEAPIINSTALLDIR);
addpath(DAEAPI_UTILS);
setuppaths_DAEAPI();

% add paths for AoDAEPAI
% TODO: DAEAPIDIR should be picked up from autoconf/.configure
A1oDAEAPIINSTALLDIR='__A1oDAEAPIINSTALLDIR__';
A1oDAEAPIDIR='__A1oDAEAPIINSTALLDIRLIB__';
A1oDAEAPI_UTILS=sprintf('%s/utils', A1oDAEAPIDIR);
A1oDAEAPI_TESTSCRIPTS=sprintf('%s/test-scripts', A1oDAEAPIDIR);
A1oDAEAPI_USABILITYHELPERS=sprintf('%s/usability-helpers', A1oDAEAPIDIR);
A1oDAEAPI_DOC=sprintf('%s/doc', A1oDAEAPIDIR);
A1oDAEAPI_ANALYSESALGORITHMS=sprintf('%s/analyses-algorithms', A1oDAEAPIDIR);
A1oDAEAPI_HB=sprintf('%s/analyses-algorithms/HB', A1oDAEAPIDIR);
A1oDAEAPI_HBUTILS=sprintf('%s/analyses-algorithms/HB/utils', A1oDAEAPIDIR);
A1oDAEAPI_HBTESTSCRIPTS=sprintf('%s/analyses-algorithms/HB/testscripts', A1oDAEAPIDIR);

addpath(A1oDAEAPI_UTILS);
addpath(A1oDAEAPI_TESTSCRIPTS);
addpath(A1oDAEAPI_USABILITYHELPERS);
addpath(A1oDAEAPI_DOC);
addpath(A1oDAEAPI_ANALYSESALGORITHMS);
addpath(A1oDAEAPI_HB);
addpath(A1oDAEAPI_HBUTILS);
addpath(A1oDAEAPI_HBTESTSCRIPTS);
