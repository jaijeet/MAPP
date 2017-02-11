%MAPP has some built-in features for compact model optimization. 
%
%Once you have debugged and are reasonably happy with your ModSpec model, you
%may wish to make your model more efficient, so that simulations involving your
%model run faster. This page tells you how to do so.
%
%To give you a point of reference, we found that by applying the techniques 
%suggested on this page, we were able to get the MVS transistor model to run 
%about 7x faster, and the BSIM model to run about 2x faster.
%
%System requirements: To use MAPP's features for compact model optimization, 
%you need to have Python 3.4 (or later) installed on your system. Apart from 
%the standard Python libraries, you will also need jinja2 and prettytable for 
%your Python version (which you can install via pip).
%
%The main feature of MAPP that enables compact model optimization is called 
%vv4. vv4 works in 2 stages: 
%
%Stage 1: vv4 takes your compact model (that is assumed to adhere to the ModSpec 
%         API format) and exports it to a format where the core functions of 
%         your ModSpec model (fe, qe, fi, qi, initGuess, and limiting) are 
%         expressed as DAGs (Directed Acyclic Graphs).
%
%         For this to work, the core functions of your model should not use if 
%         conditions. Instead, they should use the ITE operation, where 
%         ite(x, y, z) is equivalent to "if x, then y, else z". 
%         
%         For example, let us say that one of your core functions has in it a 
%         fragment that looks like the following:
%
%             if (vgs <= vth0)
%                 ids = 0;
%             else
%                 if (vds - vgs <= -vth0)
%                     ids = Beta * vds * (vgs - vth - 0.5*vds);
%                 else
%                     ids = 0.5 * Beta * (vgs - vth).^2;
%                 end
%             end
%
%         Then, before you can use vv4 to optimize your model, you should  
%         replace the code fragment above with something like:
%
%             cond1 = (vds <= vth0);
%             cond2 = (vds - vgs <= -vth0);
%
%             ids_1 = 0;
%             ids_2 = Beta * vds * (vgs - vth - 0.5*vds);
%             ids_3 = 0.5 * Beta * (vgs - vth).^2;
%
%             ite(cond1, ids_1, ite(cond2, ids_2, ids_3));
%
%         Once you have replaced all the if/else blocks in your model with 
%         equivalent ITE operations, here's how you run Stage 1 of vv4 at a 
%         MATLAB prompt:
%
%             >> addpath('path/to/vecvalder/vv4/vv4-MATLAB');
%             >> MOD = your_ITE_ModSpec_Model();
%             >> export_MOD_via_vv4(MOD, 'path/where/you/want/the/DAG');
%             >>
%
%         For example, to export the MVS model to DAG form:
%
%             >> addpath('path/to/vecvalder/vv4/vv4-MATLAB');
%             >> MOD = MVS_1_0_1_ModSpec_ITE();
%             >> export_MOD_via_vv4(MOD, '/tmp/MVS_1_0_1_ModSpec.dag');
%             >>
%
%Stage 2: In this stage, vv4 takes the DAG above and generates optimized MATLAB 
%         code for your ModSpec model. Here's how you run this stage in a 
%         Python 3.4 (or later) session:
%
%             >>> import sys
%             >>> sys.path.append('path/to/vecvalder/vv4/vv4-python')
%             >>> from vv4.ModSpec_EE_Model import ModSpec_EE_Model
%             >>> MOD = ModSpec_EE_Model('path/to/DAG/file/from/Stage/1')
%             >>> dir_name = 'path/to/dir/where/you/want/optimized/model'
%             >>> base_name = 'what/you/want/optimized/model/to/be/called'
%             >>> MOD.export_optimized_MATLAB_code(dir_name, base_name)
%             >>>
%
%         For example, here's how you run Stage 2 on the MVS DAG created above:
%
%             >>> import sys
%             >>> sys.path.append('path/to/vecvalder/vv4/vv4-python')
%             >>> from vv4.ModSpec_EE_Model import ModSpec_EE_Model
%             >>> MOD = ModSpec_EE_Model('/tmp/MVS_1_0_1_ModSpec.dag')
%             >>> dir_name = '/tmp'
%             >>> base_name = 'MVS_1_0_1_ModSpec_vv4'
%             >>> MOD.export_optimized_MATLAB_code(dir_name, base_name)
%             >>>
%
%         If everything worked right, you should be able to see an optimized 
%         version of your ModSpec model in the path that you specified. This 
%         model should be exactly equivalent to your original ModSpec model, 
%         but it should run much faster.
%
