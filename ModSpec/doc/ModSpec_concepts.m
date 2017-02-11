%{
The device API: THIS WILL BECOME THE API DOCUMENTATION
 ---- ModSpec: the basic notions ----
 - the basic idea of a device is something that has n inputs
   and n outputs. You specify the inputs (eg, n branch voltages); the
   device gives you values for the outputs (eg, n branch currents), or
   equivalently, supplies n equations that take the inputs and produce
   the outputs.
   - because we are dealing with differential equations, each output
     has an f component and a q component. The actual output is
     dq/dt + f, but the device supplies q and f separately.

 - but in many situations, it is not clear which should be called the
   inputs and which the outputs. Moreover, even if it is clear which
   ones are the inputs and which the outputs, and values for the inputs
   are given, the outputs may not be calculable explicitly in terms of 
   the inputs; the equations involved may be implicit in the outputs.
   Therefore, we generalize the above concept of a device to something
   that has: 
   - 2n IOs
   - supplies n equations (each with an f and a q component) involving the 2n IOs

 - we want to support the feature that some of the outputs may be
   specified explicitly by the equations. Suppose l outputs (0 <= l <= n)
   are specified explicitly; then we have:
   - l explicit outputs (we will call them ExplicitOutputs)
     - they will be stored in an l-length vector, called vecZ
       - it has f and q components: vecZf and vecZq, with vecZ = d/dt vecZq + vecZf

   - 2n-l remaining IOs - we will these otherIOs
     - stored in a vector we will call vecX

   - the n equations can be split into two parts:
     - l explicit equations, evaluating which provides the ExplicitOutputs
       - each with with f and q components, ie,
	 - vecZ = d/dt[qe(vecX)] + fe(vecX)
     - n-l implicit equations, each with f and q components
       - 0 = d/dt[qi(vecX)] + fi(vecX)
	 - we denote the RHS by vecW - ie,
	   - vecW = d/dt[qi(vecX)] + fi(vecX), 
	     and the equations are satisfied if vecW = 0.

 - in addition to the above, we also want to support internal unknowns
   within the device, ie, that are not part of the IOs. We will allow m >= 0
   internal unknowns, stored in a vector called vecY. For each internal
   unknown the device supplies, it should also supply an equation, using
   which it should be possible in principle to compute the internal unknowns.
   These equations can, without loss of generality, be implicit equations - 
   because if explicit equations are available for an internal unknown, the
   unknown can be eliminated easily. So we have m more implicit equations.
   We will include these into the implicit equations we already have above.

   Taking into account the m internal unknowns and the corresponding equations,
   our model equations become:

   - l ExplicitOutputs, stored in vecZ

   - 2n-l otherIOs, stored in vecX

   - m InternalUnks, stored in vecY

   - we now have a total of n+m equations, split into two parts:
     - l explicit equations for the ExplicitOutputs; they can depend
       not only on the OtherIOs vecX but also on the InternalUnks vecY
	 - vecZ = d/dt[qe(vecX, vecY)] + fe(vecX, vecY)

     - n-l+m implicit equations, incorporating the m equations corresponding
       to the Internal Unknowns:
       - 0 = vecW = d/dt[qi(vecX, vecY)] + fi(vecX, vecY)

 - finally, we also want to support time-varying behaviour in the equations
   (that does not come from the IOs or the internal unknowns). For this,
   we can make fe and fi to also have a t argument (in principle, qe and qi
   should also have t arguments, but we haven't felt a great need for that
   yet in applications). 
   
   For ease in specifying the time variations, we assume that they are all
   encapsulated in a vector u(t), stored in a vector vecU at any specified
   time t. This is supplied as an argument to fi/fe, ie, they become 
   fi(vecX, vecY, vecU) and fe(vecX, vecY, vecU). Incorporating this into
   the above, we get:

   -------------------------------------------------------------------------
   - 2n IOs, split into:
     - l ExplicitOutputs, stored in vecZ
     - 2n-l otherIOs, stored in vecX

   - m InternalUnks, stored in vecY

   - ni Us (time-varying functions used in the equations) for u(t),
     stored (for a given timepoint) in vecU.

   - a total of n+m equations, split into:

     - l explicit equations for the ExplicitOutputs; they can depend
       not only on the OtherIOs vecX but also on the InternalUnks vecY
	 - vecZ = d/dt[qe(vecX, vecY)] + fe(vecX, vecY, vecU)

     - n-l+m implicit equations, incorporating the m equations corresponding
       to the InternalUnks:
       - 0 = vecW = d/dt[qi(vecX, vecY)] + fi(vecX, vecY, vecU)
   -------------------------------------------------------------------------

 ---- device inputs and outputs ----
   - to call the device, the network needs to supply it with:
     a) vecX: a vector of size 2n-l (= nOtherIOs), representing all IOs that are not
	 explicit outputs. 
     b) vecY: a vector of size m (= nInternalUnksEqns), representing the device's internal unknowns
	This is vecY.

   - once the device is called, it returns to the network:
     a) vecZ: l (= nExplicitOutputs) explicit output values
	- in 2 separate parts: an f part and a q part
     b) vecW: n+m-l (= nImplicitEquations) values for the implicit equations
	- f and q parts

 ---- Field names in ModSpec ----
   - the names of the IOs are provided in IOnames
   - l of the IOs are explicit outputs; their names are specified in ExplicitOutputNames
     - the order of ExplicitOutputNames specifies the order of vecZ
     - ExplicitOutputNames are taken out (in place) from IOnames to produce OtherIONames, 
       which specifies the order of vecX
   - there are m internal unknowns, given by InternalUnkNames. Their order specifies vecY
   - ImplicitEquationNames contains names of the implicit equations qi/fi.
     - names for the fe/qe equations are the same as ExplicitOutputNames

 ---- Network Interface Layer for electrical devices ----
 - the device's view of the network it connects to is implemented through a
   Network Interface Layer (NIL) - these contain additional domain-specific functions/data. Each domain
   will have its own NIL. For electrical devices, the NIL has the following data:
   - NIL.NodeNames: internal names of the n+1 nodes the device connects to. Eg, {'d', 'g', 's', 'b'} for a MOSFET.
   - NIL.RefNodeName: an internal reference node name, used to define branch quantities. Eg, 'b' for a MOSFET.
   - note: for electrical devices, IOnames is determined using NIL.NodeNames and NIL.RefNodeName.
     The IOs are n branch voltages and n branch currents, in the order:
		{ {v_NodeName_RefNodeName}, {i_NodeName_RefNodeName}}. For example, if NIL.NodeNames = {'d', 'g', 's', 'b'}
		and NIL.RefNodeName = 'b', then IOnames = {'vdb', 'vgb', 'vsb', 'idb', 'igb', 'isb'};
   - NIL.IOnodenames is used to map back from IOnames to NIL.NodeNames; ie, given an IO, to find the node
     the branch starts from. Eg, with IOnames as above, NIL.IOnodenames = {'d', 'g', 's', 'd', 'g', 's'}.
     (The second node for the branch is always NIL.RefNodeName).
     - this is generated from NIL.NodeNames and NIL.RefNodeName at the same time as IOnames.
   - NIL.IOtypes is used to figure out what the type (voltage or current branch) of each IO in IOnames is.
     (These types are needed during system equation formulation, eg to determine whether a KVL or a KCL
      should be written).  If IOnames(idx) is an IO, NIL.IOtypes(idx) returns 'v' or 
     'i', telling you whether it is the branch voltage or branch current.
 ---- End network Interface Layer for electrical devices ----

 -  Newton-Raphson initialization support:
	The device can support initialization process of NR by specifying initial guesses vecX and vecY
	 wrt time-varying part u. 
	So initGuess should be a function of u.
		[vecX,vecY] = MOD.initGuess(u, MOD);
	The default value is all zeros. 

 - Newton-Raphson limiting support:
	At a given u, updates in vecX and vecY can be limited according to vecX, vecY and
	vecXold, vecYold from the last NR iteration.
		[vecXnew, vecYnew] = MOD.limiting(vecX,vecY,vecXold,vecYold, u, MOD);
	The default limiting is no limiting : vecXYnew = vecXY.

%}
%author: J. Roychowdhury.
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Author: J. Roychowdhury.
% Copyright (C) 2011-2012 Jaijeet Roychowdhury <jr@berkeley.edu>. All rights reserved.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
