*** Test-bench for silicon MVS model
*** Test on Hspice E-2010.12-SP2

*** load verilog-a files
.hdl "mvs_si.va"

*** MOSFET
X1 drain gate source body daa_mosfet

*** DC voltage sources
Vdrain drain 0 1
Vgate gate 0 0.1
Vsource source 0 0
Vbody body 0 0

*** simulation
.dc Vdrain -1 1 0.2
.print dc I(Vdrain)
.option post

*** END
.end


