%The complete code of MAPP is organized in four directories: Ao1DAEAPI, DAEAPI,
%ModSpec and vecvalder.
%
%MAPP
%  |
%  L-> A1oDAEAPI                       - Basic analyses (DC, AC, and transient)
%  |      |                              on circuits described by DAEAPI (for
%  |      |                              more, type "help A1oDAEAPI")
%  |      |
%  |      |---> analyses-algorithms    - Algorithms for doing different analyses
%  |      |                              (for more, "help analyses-algorithms")
%  |      |
%  |      |---> test-scripts           - Scripts for doing different analyses on
%  |      |                              various circuits DAEs (for  getting a
%  |      |                              complete list of available test scripts,
%  |      |                              type "help analyses-test-scripts")
%  |      |
%  |      |---> usability-helpers      - Usability helper functions for MATLAB 
%  |      |                              DAEAPI (for getting the complete list of
%  |      |                              available usability helper functions, 
%  |      |                              type "help analyses-usability-helpers")
%  |      |
%  |      |---> utils                  - Utility functions for basis analyses on
%  |                                     circuit DAEs (for getting the complete
%  |                                     list of available utility functions, 
%  |                                     type "help analyses-utils")
%  | 
%  | 
%  L-> DAEAPI                          - MATLAB API to describe circuits as
%  |      |                              nonlinear DAEs (for more, type "help DAEAPI")
%  |      |
%  |      |---> DAEs                   - Various circuits represented in MATLAB 
%  |      |                              DAEAPI (to get a complete list, type
%  |      |                              "help DAEs")
%  |      |
%  |      |---> test-scripts           - Various test scripts to check correct
%  |      |                              implementation of various DAEAPI
%  |      |                              functions. (to get a complete list,
%  |      |                              type "help DAEAPI-test-scripts"
%  |      |
%  |      |---> device-model           - <TODO> NOT SURE IF THIS IS NEEDED
%  |      |
%  |      |---> utils                  - Utility functions for creating DAEs (for
%  |                                     getting the complete list of available
%  |                                     utility functions, type "help DAEAPI-utils")
%  |       
%  L-> ModSpec                         - MATLAB API to describe compact models
%  |      |                              (for more, type "help ModSpec")
%  |      |
%  |      |---> device-models          - Various simulation-ready compact device
%  |      |                              models represented in MATLAB DAEAPI 
%  |      |                              (to get a complete list, type "help
%  |      |                              ModSpec-device-models")
%  |      |
%  |      |---> smoothingfuncs         - Various smoothing function to smooth 
%  |      |                              model discontinuities (for a complete
%  |      |                              list of smoothing functions, type "help
%  |      |                              smoothingfuncs")
%  |      |
%  |      |---> test-scripts           - MATLAB scripts to run tests on various
%  |      |                              ModSpec model and compare the output 
%  |      |                              results with previously stored test data
%  |      |                              (*.mat files) in /test-data directory
%  |      |
%  |      |---> test-data              - Directory with stored output data (*.mat
%  |      |                              files) for different tests on various
%  |      |                              ModSpec models
%  |      |
%  |      |---> utils                  - External utility functions used in 
%  |                                     creating a standard ModSpec model (for
%  |                                     complete list, type "help ModSpec-utils")
%  | 
%  | 
%  L-> vecvalder                       - Package to perform automatic 
%         |                              differentiation in MATLAB/Ocatave
%         |
%         |---> @vecvalder             - Various overloaded functions implemented
%         |                              in vecvalder package. This directory 
%         |                              also includes the class definition file
%         |                              vevvalder.m. (for complete list of
%         |                              functions, type "help vecvalder-functions")
%         |
%         |---> tests                  - Various test scripts to compare
%         |                              derivative of different functions
%         |                              computed using  vecvalder package
%         |                              (automatic differentiation) and symbolic
%         |                              differentiation for different functions.
%         |                              (for complete list, type "help
%         |                              vecvalder-tests")
%         |
%         |---> utils                  - Utility functions for vecvalder package
%                                        (For more, type "help vecvalder-utils"


      
