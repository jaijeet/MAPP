%In this help topic, we illustrate how to add your own device model to MAPP's
%library of models, by defining it in a MATLAB-based format called ModSpec.
%
%The demo in this help topic uses a tunnel diode model as an example. It first
%writes down the IO properties and equations of the device before coding. Then
%the device is coded in ModSpec format and its I/G-V curves are plotted using
%ModSpec's API functions. Finally, we build a simple circuit using this
%newly-added device and run analyses to test the performances of it.
%
%To start the demo, run:
%
% >> ModSpec_demo;
%
%To see more general descriptions on how to add devices to MAPP, run:
%
% >> help MAPPdevices;
%
%Note: if you are new to writing EE device models in MAPP/ModSpec, we 
%recommend that you use MAPP's Model Starter. The Model Starter is an 
%interactive MATLAB script. It helps you quickly define EE models in MAPP by 
%eliminating the need for you to write boilerplate code (to get your model to 
%conform to the ModSpec API). Instead, the Model Starter creates all this 
%boilerplate code automatically for you, thereby letting you focus purely on 
%getting your model equations right. It does this by first asking you various 
%questions about your EE model (for instance, how many terminals the model has, 
%which currents/voltages are explicitly available in terms of the others, etc.). 
%Then, based on the information that you provided, it automatically creates an 
%.m file for your device model that has everything in it except the model's 
%parameters and equations. You fill in these, and your model is good to go. To 
%run the Model Starter, type "model_starter()" (without the quotes) at the 
%MATLAB prompt.
%
%See also
%--------
%MAPPquickstart, MAPPdevices, model_starter

help MAPPquickstart_ModSpec;
