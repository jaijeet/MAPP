Model file:
daa_mosfet.m: MVS model file (Check model documentation for details).

Parameter extraction file:
Run extract_main.m file to extract the seven parameters (Rs0, Rd0, delta, n0, nd, vxo, mu, Vt0). The extraction routine was already run for 32 nm and 45 nm data sets and the results are provided in coeff_op_final_32nm.txt and coeff_op_final_45nm.txt
Also check model documentation for optimization routine.

Results from each iteration step of extraction routine:
The parameter extraction routine is run for N steps (N is chosen to be 10, but can be decreased to increase speed. But make sure N > =3). The results from each step of the iteration are stored in files labeled "output_text_32nm.txt" or "output_text_45nm.txt".

***In order to run the extractor, please download "Experimental Data from Intel 32 nm and 45 nm N-type devices" and put them in the SAME folder.