*** Test-bench for generting transient response of an inverter with two loading scenarios:
*** scenario 1: You can choose either c1=3.5pF or c2=1pf (constant loading)
*** scenario 2: You can simulate a fan-out of FOUR.
*** Test on Hspice E-2010.12-SP2

*** load verilog-a files
.hdl "mvs_si.va"

*** Creat sub-circuit for the inverter
.subckt inverter Vin Vout Vvdd Vgnd

X1 Vvdd Vin Vout Vvdd daa_mosfet tipe=-1 W=1.0e-4 Lgdr=32e-7 dLg=8e-7 Cg=2.57e-6 beta=1.8 alpha=3.5 Cif = 1.38e-12 Cof=1.47e-12 phib=1.2 gamma=0.1 mc=0.2 CTM_select=1  Rs0=100 Rd0 = 100 n0=1.68 nd=0.1 vxo=7542204 mu=165 Vt0=0.5535 delta=0.15 

X0 Vout Vin Vgnd Vgnd daa_mosfet tipe=1 W=1e-4 Lgdr=32e-7 	dLg=9e-7 Cg=2.57e-6 beta=1.8 alpha=3.5 	Cif=1.38e-12 Cof=1.47e-12 phib=1.2 gamma=0.1 mc=0.2 CTM_select=1 	Rs0=100 Rd0=100 n0=1.68 nd=0.1 vxo=1.2e7 mu=200 Vt0=0.4 delta=0.15

.ends

*** circuit layout

Vsup sup 0 1
Vin in 0 pulse(0 1 0 1p 1p 50p 100p) 
Vsource source 0 0
X2  in out sup 0 inverter
***X3  out out1 sup 0 inverter
***X4  out out2 sup 0 inverter
***X5  out out3 sup 0 inverter
***X6  out out4 sup 0 inverter
c1 out 0 3e-15
***c2 out 0 1e-12

*** simulation
.tran 1p 1n 
.print tran V(out)
.option post

*** END
.end


