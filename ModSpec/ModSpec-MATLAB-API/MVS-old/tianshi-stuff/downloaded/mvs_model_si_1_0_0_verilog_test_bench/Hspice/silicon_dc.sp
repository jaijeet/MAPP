*** Test-bench for silicon MVS model
*** Test on Hspice E-2010.12-SP2

*** load verilog-a files
.hdl "mvs_si.va"

*** MOSFET
X1 drain gate source body daa_mosfet tipe=1 W=1e-4 Lgdr=32e-7 dLg=9e-7 Cg=2.57e-6 beta=1.8 alpha=3.5 etov=1.3e-3 Cif=0 Cof=0 phib=1.2 gamma=0 mc=0.2 CTM_select=1 Rs0=100 Rd0=100 n0=1.68 nd=0.1 vxo=1.2e7 mu=200 Vt0=0.4 delta=0.15

*** DC voltage sources
Vdrain drain 0 1
Vgate gate 0 0.4
Vsource source 0 0
Vbody body 0 0

*** simulation
.dc Vdrain -1 1 0.01
.option post

*** END
.end


