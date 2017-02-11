[JR's notes on using MDE for compact model development, 2013/09/27]

- first, need a DAE tutorial and demo

- once that's gone through, here are the steps for making a compact model: 

  - writing the equations out on "paper" in the right format
    - write the equations
    - draw the network structure (identify external nodes + internal unks/nodes)
    - write the equations informally
      - check for smoothness and other problems
        - checklist: exp -> limexp, abs, sqrt, etc. types of functions
    - list the parms and their default values
    - identify variables
      - internal, external, etc.
      - branches voltages and currents
    - identify us
    - write out what vecX, vecY, vecU by hand
    - write out the equations in terms of vecX, vecY, vecU
    - split the equations up into fi/qi/fe/qe
    - etc.

  - writing the ModSpec model
    - using usability helper functions
      - eg: 
        - MOD = ee_model_skeleton();
        - MOD = add_ee_model_component(MOD, 'extnodes', {'g' 'd' 'b'})
        - MOD = add_ee_model_component(MOD, 'intunks', {'g' 'd' 'b'})
        - MOD = add_ee_model_component(MOD, 'parms', {{'parm1', 'default1'}, {'parm2', 'default2'}})
      - code up fi, qi, fe, qe
        - fistruc = add_eqn_to_fi(fistruc, 'a = b');
      - test them quickly
        - MOD = add_ee_model_component(MOD, 'fi', @myfi, args)
        - MOD = add_ee_model_component(MOD, 'qi', @myqi, args)

  - test, debug and refine the model
    1. basic tests run_ModSpec_functions(MOD). Fix your model and repeat till done.
    2. build a little "characteristic curve circuit" and run dot_dcsweep on it
       to see characteristic curves. Fix your model and repeat till done.
    3. build other little circuits with your model and run DC, AC, and transient analysis
       - eg, inverter, diffpair, ring oscillator

  - port manually to Verilog-A
    - later: provide usability helper functions in MATLAB to 
      help generate the Verilog-A file.
      - will involve first writing higher-level functions to auto-generate fi/qi
