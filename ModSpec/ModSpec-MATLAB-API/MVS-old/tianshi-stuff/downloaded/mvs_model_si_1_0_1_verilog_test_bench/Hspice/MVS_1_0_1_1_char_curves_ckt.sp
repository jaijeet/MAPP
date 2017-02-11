*** Test-bench for silicon MVS model
*** Test on Hspice E-2010.12-SP2

*** load verilog-a files
.hdl "mvs_si_1_0_1.va"

*** MOSFET
X1 drain gate source body mvs_si_1_0_1 

*** DC voltage sources
Vdrain drain 0 1
Vgate gate 0 0.1
Vsource source 0 0
Vbody body 0 0

*** simulation
.dc Vdrain -1 1 0.1
.print dc I(Vdrain)
.option post

*** END
.end


