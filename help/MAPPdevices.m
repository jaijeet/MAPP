%Device models in MAPP are described in ModSpec format.
%
% 0. To quickly start writing an electrical device model in MAPP, you can try
%    MAPP's interactive "Model Starter".
%    >> model_starter();
%    It will ask you various questions about the model. Then it creates a
%    ModSpec template, where you can fill in model parameters and equations to
%    complete the model.
%
% 1. To understand the concepts behind the ModSpec format:
%    >> help ModSpec_concepts;
%
% 2. To implement a ModSpec device, there are currently two ways: a high-level
%    way and a low-level way. Beginners will probably want to use the
%    high-level way, ie, use the ModSpec wrapper. To understand better 
%    how ModSpec works, one can write a device directly at the low level
%    by defining the ModSpec Matlab struct.
%
%    (1) (high level) Using the ModSpec wrapper:
%
%        Electrical device models described using ModSpec wrappers start with
%            MOD = ee_model();
%        and end with
%            MOD = finish_ee_model(MOD);
%
%        In between, users can use the utility function add_to_ee_model() to
%        enter model information such as terminals, parms, functions, etc.
%        >> help add_to_ee_model;
%        describes its usage.
%
%        Examples of devices implemented using the ModSpec wrapper are
%        available via
%        >> help MAPPdeviceExamples;
%        please see the section entitled "More devices (described using
%        ee_ModSpec_wrapper)".
%
%        Note: MAPP now comes with an interactive "Model Starter" that lets 
%        you automatically create ModSpec wrapper compliant code (for EE 
%        devices) without having to type it in yourself. Just run:
%
%        >> model_starter();
%
%        You will be asked a number of questions about your device model 
%        (such as how many terminals it has, etc.), and once you supply these 
%        details, a model template (as an .m file) will be created for you. 
%        This template will already contain the requisite ee_model, 
%        add_to_ee_model, etc. lines for your model. All you have to do is 
%        fill in the model's parameters and equations into this template, and 
%        you will have a working ModSpec model ready to be tested/used in a 
%        circuit.
%
%    (2) (low level) Directly using the ModSpec API:
%  
%        a. For lower-level ModSpec API information: 
%           >> help ModSpecAPI;
%       
%        b. To build a ModSpec object, users need not write an
%           entire Matlab struct from scratch. Instead, they can copy an
%           existing one and modify the data and function fields.
%           For example, exampleModSpec.m creates an example ModSpec
%           object that describes a basic Shichman Hodges MOSFET model.
%
% 3. After creating a ModSpec object, before using it in netlists and
%    analyses, it is HIGHLY RECOMMENDED that it be CHECKED for ModSpec
%    API compliance, using the check_ModSpec routine. For example,
%    >> MOD = resistor_ModSpec_wrapper(); check_ModSpec(MOD);
%    or
%    >> MOD = exampleModSpec(); check_ModSpec(MOD);
%
% 4. After creating a ModSpec object, before using it in netlists, you can test
%    the model standalone by evaluating and plotting some model functions with
%    MAPP's model exerciser. For example,
%    >> MOD = SH_MOS_ModSpec; MEO = model_exerciser(MOD);
%    creates a model exerciser object MEO.
%    >> MEO.display(MEO);
%    lists the functions in this model exerciser, as well as some examples of
%    its usage.
% 
%    MAPP also has another model exerciser that can connect the device model
%    into a circuit and run DC sweep analysis on it. It can be useful for
%    models with internal variables, whose values can only be determined by
%    simulating the model in a circuit. For example,
%    >> MOD = SHMOSWithParasitics_ModSpec_wrapper; MEO = model_dc_exerciser(MOD);
%    will ask you to connect each model terminal with a voltage or current
%    source. Then similarly,
%    >> MEO.display(MEO);
%    displays the usage of MEO functions and examples.
%
%
%See also
%--------
% add_element, add_to_ee_model, model_starter, MAPPcktnetlists, 
% MAPPdeviceExamples, ModSpecAPI, ModSpec_concepts
%
