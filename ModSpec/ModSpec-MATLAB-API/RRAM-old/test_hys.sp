* test hys.va in DC, and TRAN
.OPTION POST
.hdl hys.va
V1 1 0 1 sin(0 0.7 1k)
X1 1 0 hys

* DC analysis
.dc V1 -1 +1 0.01

* transient simulation
.tran 1u 2m
.end
