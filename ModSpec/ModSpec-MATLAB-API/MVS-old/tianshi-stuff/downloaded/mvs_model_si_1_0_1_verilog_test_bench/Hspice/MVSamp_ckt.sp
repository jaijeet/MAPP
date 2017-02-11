*** Test-bench for silicon MVS model

*** load verilog-a files
.hdl "mvs_si_1_0_1.va"

*** MOSFET
X1 drain gate 0 0 mvs_si_1_0_1 type=1 W=1e-4 Lgdr=32e-7 dLg=9e-7 Cg=2.57e-6 beta=1.8 alpha=3.5 etov=1.3e-3 Cif=0 Cof=0 phib=1.2 gamma=0 mc=0.2 CTM_select=1 Rs0=100 Rd0=100 n0=1.68 nd=0.1 vxo=1.2e7 mu=200 Vt0=0.4 delta=0.15

*** DC voltage sources
Vdd vdd 0 1
Vbias vbias 0 0.55
Vin gate vbias 0 AC 1

*** RL and CL
RL vdd drain 1k
CL drain 0 1p

*** simulation
*.dc Vin -0.1 0.1 0.01
*.print dc V(drain)
.ac DEC 10 1K 100MEG
.plot ac V(drain)
.option post

*** END
.end
