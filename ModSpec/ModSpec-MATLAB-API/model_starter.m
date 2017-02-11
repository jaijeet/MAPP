function model_starter()
%MAPP's Model Starter is an interactive utility that lets you quickly define 
%EE models in MAPP. Its main feature is that it eliminates the need for you 
%to write boilerplate code (for getting your model to conform to the ModSpec 
%or ModSpec wrapper APIs). Instead, the Model Starter creates such boilerplate 
%code automatically for you, thereby letting you focus purely on getting your 
%model equations right. 
%
%The Model Starter works as follows: it does this by first asking you various 
%questions about your EE model (for instance, how many terminals the model 
%has, which currents/voltages are explicitly available in terms of the others, 
%etc.). Then, based on the information that you provide, it automatically 
%creates a template (an .m file) for your device model. This .m file conforms 
%to the ModSpec wrapper API, i.e., it contains all the requisite ee_model, 
%add_to_ee_model, and finish_ee_model lines automatically written in for you, 
%so you don't have to type them in yourself. All you have to do is fill in 
%your model's parameters and equations into this .m file, and you will have a 
%working ModSpec model ready to be tested/used in a circuit.
%
%At the moment, Model Starter takes no arguments. Just run
%
%>> model_starter()
%
%at a MATLAB prompt to invoke it.
%
%Note: The Model Starter only supports electrical models right now. We plan to 
%add support for optical and opto-electronic models at a later date.
%
    fprintf('Note: model starter only supports electrical models right now.\n');
    start_ee_model();
end
