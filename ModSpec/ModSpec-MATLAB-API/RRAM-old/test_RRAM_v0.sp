* circuit with one voltage source and one RRAM
.OPTION POST
.hdl RRAM_v0.va
Vin in 0 DC -1 pulse(-1 1 1u 4m 4m 1u 8m)
X1 in 0 RRAM_v0
.dc Vin -1 1 0.01
.tran 1e-6 8m 
.end
