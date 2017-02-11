function DAE = BSIM3_ringosc(uniqIDstr)
%function DAE = BSIM3_ringosc(uniqIDstr)
% A three stage ring oscillator with BSIM3 MOSFET
%author: J. Roychowdhury, 2012/07/18
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% The Circuit: 
%	a 3 stage ring oscillator made with BSIM3 MOSFETs
%	using 0.18u parameters, probably from MOSIS
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%
%see DAEAPIv6_doc.m for a description of the functions here.
%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Type "help MAPPlicense" at the MATLAB/Octave prompt to see the license      %
%% for this software.                                                          %
%% Copyright (C) 2008-2013 Jaijeet Roychowdhury <jr@berkeley.edu>. All rights  %
%% reserved.                                                                   %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%






	% ckt name
        if nargin <1
                cktname = 'BSIM3-ringosc';
        else 
                cktname = uniqIDstr;
        end

	% nodes (names)
	nodes = {'VDD', 'inv1', 'inv2', 'inv3'};
	ground = 'gnd';

	% list of elements 
	vddM = vsrcModSpec('VDD');
	iInj1M = isrcModSpec('iInj1');
	minv1pM = BSIM3v3_2_4_ModSpec('Minv1p'); 
	minv1nM = BSIM3v3_2_4_ModSpec('Minv1n'); 
	c1M = capModSpec('c1');
	minv2pM = BSIM3v3_2_4_ModSpec('Minv2p'); 
	minv2nM = BSIM3v3_2_4_ModSpec('Minv2n'); 
	minv3pM = BSIM3v3_2_4_ModSpec('Minv3p'); 
	minv3nM = BSIM3v3_2_4_ModSpec('Minv3n'); 

	% element node connectivities
	vddNodes = {'VDD', ground}; % p, n
	iInj1Nodes = {'inv1', ground}; % p, n
	%mp1 inv1 inv3 VDD VDD mypmos
	minv1pNodes = {'inv1', 'inv3', 'VDD', 'VDD'};  % d g s b
	%mn1 inv1 inv3 0 0 mynmos
	minv1nNodes = {'inv1', 'inv3', ground, ground};  % d g s b
	%c1  inv1 0 1e-19
	c1Nodes = {'inv1', ground};  % d g s b

	%mp2 inv2 inv1 VDD VDD mypmos
	minv2pNodes = {'inv2', 'inv1', 'VDD', 'VDD'};  % d g s b
	%mn2 inv2 inv1 0 0 mynmos
	minv2nNodes = {'inv2', 'inv1', ground, ground};  % d g s b

	%mp3 inv3 inv2 VDD VDD mypmos
	minv3pNodes = {'inv3', 'inv2', 'VDD', 'VDD'};  % d g s b
	%mn3 inv3 inv2 0 0 mynmos
	minv3nNodes = {'inv3', 'inv2', ground, ground};  % d g s b

	vddElement.name = 'vdd'; vddElement.model = vddM; 
		vddElement.nodes = vddNodes; vddElement.parms = {};

	iInj1Element.name = 'iInj1'; iInj1Element.model = iInj1M; 
		iInj1Element.nodes = iInj1Nodes; iInj1Element.parms = {};

	% 0.18u BSIM3 model - probably MOSIS - from old SPP's
	% bsim3ADMS_inv5_osc_subckt.sp
	%
	% .model mynmos bsim3a type=1 W=0.18e-6 L=0.18e-6 Toxm=4.1E-9
	% +TNOM    = 27             TOX     = 4.1E-9
	% +XJ      = 1E-7           NCH     = 2.3549E17      VTH0    = 0.3696986
	% +K1      = 0.6064385      K2      = 1.63871E-3     K3      = 1E-3
	% +K3B     = 2.763267       W0      = 1E-7           NLX     = 1.71872E-7
	% +DVT0W   = 0              DVT1W   = 0              DVT2W   = 0
	% +DVT0    = 1.3330881      DVT1    = 0.3683763      DVT2    = 0.0540199
	% +U0      = 258.9066683    UA      = -1.504141E-9   UB      = 2.428646E-18
	% +UC      = 5.105195E-11   VSAT    = 9.896282E4     A0      = 1.8904342
	% +AGS     = 0.4044483      B0      = -4.706134E-8   B1      = 1.294942E-6
	% +KETA    = -2.730673E-3   A1      = 5.916677E-4    A2      = 0.9069159
	% +RDSW    = 105            PRWG    = 0.5            PRWB    = -0.2
	% +WR      = 1              WINT    = 0              LINT    = 1.69494E-8
	% +DWG     = -3.773529E-9
	% +DWB     = 5.239518E-9    VOFF    = -0.0883818     NFACTOR = 2.1821266
	% +CIT     = 0              CDSC    = 2.4E-4         CDSCD   = 0
	% +CDSCB   = 0              ETA0    = 2.470369E-3    ETAB    = 1.047744E-5
	% +DSUB    = 0.0167866      PCLM    = 0.7326932      PDIBLC1 = 0.1823102
	% +PDIBLC2 = 3.38377E-3     PDIBLCB = -0.1           DROUT   = 0.7469045
	% +PSCBE1  = 8E10           PSCBE2  = 1.254966E-9    PVAG    = 0
	% +DELTA   = 0.01           RSH     = 6.5            MOBMOD  = 1
	% +PRT     = 0              UTE     = -1.5           KT1     = -0.11
	% +KT1L    = 0              KT2     = 0.022          UA1     = 4.31E-9
	% +UB1     = -7.61E-18      UC1     = -5.6E-11       AT      = 3.3E4
	% +WL      = 0              WLN     = 1              WW      = 0
	% +WWN     = 1              WWL     = 0              LL      = 0
	% +LLN     = 1              LW      = 0              LWN     = 1
	% +LWL     = 0              CAPMOD  = 2              XPART   = 0.5
	% +CGDO    = 7.9E-10        CGSO    = 7.9E-10        CGBO    = 1E-12
	% +CJ      = 9.539798E-4    PB      = 0.8            MJ      = 0.380768
	% +CJSW    = 2.53972E-10    PBSW    = 0.8            MJSW    = 0.1061193
	% +CJSWG   = 3.3E-10        PBSWG   = 0.8            MJSWG   = 0.1061193
	% +CF      = 0              PVTH0   = 7.505753E-4    PRDSW   = -2.7650517
	% +PK2     = -4.42044E-4    WKETA   = 3.100384E-3    LKETA   = -0.0104103
	% +PU0     = 10.8203648     PUA     = 2.896652E-11   PUB     = 1.684125E-23
	% +PVSAT   = 1.388017E3     PETA0   = 8.758549E-5    PKETA   = 1.549791E-3

	pnames = { ...
		'Type', ... %	= 1 
		'w', ... %	= 0.18e-6 
		'l', ... %	= 0.18e-6 
		'toxm', ... %	= 4.1e-9
		'tnom', ... %    = 27           
		'xj', ... %      = 1e-7         
		'k1', ... %      = 0.6064385    
		'k3b', ... %     = 2.763267     
		'dvt0w', ... %   = 0            
		'dvt0', ... %    = 1.3330881    
		'u0', ... %      = 258.9066683  
		'uc', ... %      = 5.105195e-11 
		'ags', ... %     = 0.4044483    
		'keta', ... %    = -2.730673e-3 
		'rdsw', ... %    = 105          
		'wr', ... %      = 1            
		'dwg', ... %     = -3.773529e-9
		'dwb', ... %     = 5.239518e-9  
		'cit', ... %     = 0            
		'cdscb', ... %   = 0            
		'dsub', ... %    = 0.0167866    
		'pdiblc2', ... % = 3.38377e-3   
		'pscbe1', ... %  = 8e10         
		'delta', ... %   = 0.01         
		'prt', ... %     = 0            
		'kt1l', ... %    = 0            
		'ub1', ... %     = -7.61e-18    
		'wl', ... %      = 0            
		'wwn', ... %     = 1            
		'lln', ... %     = 1            
		'lwl', ... %     = 0            
		'cgdo', ... %    = 7.9e-10      
		'cj', ... %      = 9.539798e-4  
		'cjsw', ... %    = 2.53972e-10  
		'cjswg', ... %   = 3.3e-10      
		'cf', ... %      = 0            
		'pk2', ... %     = -4.42044e-4  
		'pu0', ... %     = 10.8203648   
		'pvsat', ... %   = 1.388017e3   
		'tox', ... %     = 4.1e-9
		'nch', ... %     = 2.3549e17   
		'k2', ... %      = 1.63871e-3  
		'w0', ... %      = 1e-7        
		'dvt1w', ... %   = 0           
		'dvt1', ... %    = 0.3683763   
		'ua', ... %      = -1.504141e-9
		'vsat', ... %    = 9.896282e4  
		'b0', ... %      = -4.706134e-8
		'a1', ... %      = 5.916677e-4 
		'prwg', ... %    = 0.5         
		'wint', ... %    = 0           
		'voff', ... %    = -0.0883818  
		'cdsc', ... %    = 2.4e-4      
		'eta0', ... %    = 2.470369e-3 
		'pclm', ... %    = 0.7326932   
		'pdiblcb', ... % = -0.1        
		'pscbe2', ... %  = 1.254966e-9 
		'rsh', ... %     = 6.5         
		'ute', ... %     = -1.5        
		'kt2', ... %     = 0.022       
		'uc1', ... %     = -5.6e-11    
		'wln', ... %     = 1           
		'wwl', ... %     = 0           
		'lw', ... %      = 0           
		'capmod', ... %  = 2           
		'cgso', ... %    = 7.9e-10     
		'pb', ... %      = 0.8         
		'pbsw', ... %    = 0.8         
		'pbswg', ... %   = 0.8         
		'pvth0', ... %   = 7.505753e-4 
		'wketa', ... %   = 3.100384e-3 
		'pua', ... %     = 2.896652e-11
		'peta0', ... %   = 8.758549e-5 
		'vth0', ... %    = 0.3696986
		'k3', ... %      = 1e-3
		'nlx', ... %     = 1.71872e-7
		'dvt2w', ... %   = 0
		'dvt2', ... %    = 0.0540199
		'ub', ... %      = 2.428646e-18
		'a0', ... %      = 1.8904342
		'b1', ... %      = 1.294942e-6
		'a2', ... %      = 0.9069159
		'prwb', ... %    = -0.2
		'lint', ... %    = 1.69494e-8
		'nfactor', ... % = 2.1821266
		'cdscd', ... %   = 0
		'etab', ... %    = 1.047744e-5
		'pdiblc1', ... % = 0.1823102
		'drout', ... %   = 0.7469045
		'pvag', ... %    = 0
		'mobmod', ... %  = 1
		'kt1', ... %     = -0.11
		'ua1', ... %     = 4.31e-9
		'at', ... %      = 3.3e4
		'ww', ... %      = 0
		'll', ... %      = 0
		'lwn', ... %     = 1
		'xpart', ... %   = 0.5
		'cgbo', ... %    = 1e-12
		'mj', ... %      = 0.380768
		'mjsw', ... %    = 0.1061193
		'mjswg', ... %   = 0.1061193
		'prdsw', ... %   = -2.7650517
		'lketa', ... %   = -0.0104103
		'pub', ... %     = 1.684125e-23
		'pketa' ... %   = 1.549791e-3
	};
	pvals = { ...
		1 , ... % Type
		0.18e-6 , ... % w
		0.18e-6 , ... % l
		4.1e-9, ... % toxm
		27           , ... % tnom
		1e-7         , ... % xj
		0.6064385    , ... % k1
		2.763267     , ... % k3b
		0            , ... % dvt0w
		1.3330881    , ... % dvt0
		258.9066683  , ... % u0
		5.105195e-11 , ... % uc
		0.4044483    , ... % ags
		-2.730673e-3 , ... % keta
		105          , ... % rdsw
		1            , ... % wr
		-3.773529e-9, ... % dwg
		5.239518e-9  , ... % dwb
		0            , ... % cit
		0            , ... % cdscb
		0.0167866    , ... % dsub
		3.38377e-3   , ... % pdiblc2
		8e10         , ... % pscbe1
		0.01         , ... % delta
		0            , ... % prt
		0            , ... % kt1l
		-7.61e-18    , ... % ub1
		0            , ... % wl
		1            , ... % wwn
		1            , ... % lln
		0            , ... % lwl
		7.9e-10      , ... % cgdo
		9.539798e-4  , ... % cj
		2.53972e-10  , ... % cjsw
		3.3e-10      , ... % cjswg
		0            , ... % cf
		-4.42044e-4  , ... % pk2
		10.8203648   , ... % pu0
		1.388017e3   , ... % pvsat
		4.1e-9, ... % tox
		2.3549e17   , ... % nch
		1.63871e-3  , ... % k2
		1e-7        , ... % w0
		0           , ... % dvt1w
		0.3683763   , ... % dvt1
		-1.504141e-9, ... % ua
		9.896282e4  , ... % vsat
		-4.706134e-8, ... % b0
		5.916677e-4 , ... % a1
		0.5         , ... % prwg
		0           , ... % wint
		-0.0883818  , ... % voff
		2.4e-4      , ... % cdsc
		2.470369e-3 , ... % eta0
		0.7326932   , ... % pclm
		-0.1        , ... % pdiblcb
		1.254966e-9 , ... % pscbe2
		6.5         , ... % rsh
		-1.5        , ... % ute
		0.022       , ... % kt2
		-5.6e-11    , ... % uc1
		1           , ... % wln
		0           , ... % wwl
		0           , ... % lw
		2           , ... % capmod
		7.9e-10     , ... % cgso
		0.8         , ... % pb
		0.8         , ... % pbsw
		0.8         , ... % pbswg
		7.505753e-4 , ... % pvth0
		3.100384e-3 , ... % wketa
		2.896652e-11, ... % pua
		8.758549e-5 , ... % peta0
		0.3696986, ... % vth0
		1e-3, ... % k3
		1.71872e-7, ... % nlx
		0, ... % dvt2w
		0.0540199, ... % dvt2
		2.428646e-18, ... % ub
		1.8904342, ... % a0
		1.294942e-6, ... % b1
		0.9069159, ... % a2
		-0.2, ... % prwb
		1.69494e-8, ... % lint
		2.1821266, ... % nfactor
		0, ... % cdscd
		1.047744e-5, ... % etab
		0.1823102, ... % pdiblc1
		0.7469045, ... % drout
		0, ... % pvag
		1, ... % mobmod
		-0.11, ... % kt1
		4.31e-9, ... % ua1
		3.3e4, ... % at
		0, ... % ww
		0, ... % ll
		1, ... % lwn
		0.5, ... % xpart
		1e-12, ... % cgbo
		0.380768, ... % mj
		0.1061193, ... % mjsw
		0.1061193, ... % mjswg
		-2.7650517, ... % prdsw
		-0.0104103, ... % lketa
		1.684125e-23, ... % pub
		1.549791e-3, ... % pketa
	};

	minv1nM = feval(minv1nM.setparms, pnames, pvals, minv1nM);
	n_parms = feval(minv1nM.getparms, minv1nM);

	minv1nElement.name = 'mn1'; minv1nElement.model = minv1nM; 
		minv1nElement.nodes = minv1nNodes; 
		minv1nElement.parms = n_parms;

	minv2nElement.name = 'mn2'; minv2nElement.model = minv2nM; 
		minv2nElement.nodes = minv2nNodes; 
		minv2nElement.parms = n_parms;

	minv3nElement.name = 'mn3'; minv3nElement.model = minv3nM; 
		minv3nElement.nodes = minv3nNodes; 
		minv3nElement.parms = n_parms;


	% .model mypmos bsim3a type=-1 		   
	% +w=0.54e-6                l=0.18e-6                Toxm=4.1E-9
	% +TNOM=27                  TOX=4.1E-9               XJ=1E-7 
	% +NCH=4.1589E17            VTH0=-0.3835898          K1=0.59111 
	% +K2=0.0258663             K3=0                     K3B=7.9143108 
	% +W0=1E-6                  NLX=1.20187E-7           DVT0W=0 
	% +DVT1W=0                  DVT2W=0                                         
	% +DVT0    = 0.6117215      DVT1    = 0.2286816      DVT2    = 0.1
	% +U0      = 106.5280265    UA      = 1.125454E-9    UB      = 1E-21
	% +UC      = -1E-10         VSAT    = 1.593712E5     A0      = 1.6904754
	% +AGS     = 0.3667554      B0      = 5.263128E-7    B1      = 1.496707E-6
	% +KETA    = 0.0237092      A1      = 0.2276342      A2      = 0.6915706
	% +RDSW    = 304.9893888    PRWG    = 0.5            PRWB    = 0.2553725
	% +WR      = 1              WINT    = 0              LINT    = 3.217673E-8
	% +DWG     = -2.44019E-8                                                    
	% +DWB     = -9.06003E-10   VOFF    = -0.0878287     NFACTOR = 1.8560303
	% +CIT     = 0              CDSC    = 2.4E-4         CDSCD   = 0
	% +CDSCB   = 0              ETA0    = 0.1672562      ETAB    = -0.1249603
	% +DSUB    = 1.0998181      PCLM    = 2.2249148      PDIBLC1 = 8.275696E-4
	% +PDIBLC2 = 0.0420477      PDIBLCB = -1E-3          DROUT   = 0
	% +PSCBE1  = 1.073111E10    PSCBE2  = 3.099395E-9    PVAG    = 15
	% +DELTA   = 0.01           RSH     = 7.4            MOBMOD  = 1
	% +PRT     = 0              UTE     = -1.5           KT1     = -0.11
	% +KT1L    = 0              KT2     = 0.022          UA1     = 4.31E-9
	% +UB1     = -7.61E-18      UC1     = -5.6E-11       AT      = 3.3E4
	% +WL      = 0              WLN     = 1              WW      = 0
	% +WWN     = 1              WWL     = 0              LL      = 0
	% +LLN     = 1              LW      = 0              LWN     = 1
	% +LWL     = 0              CAPMOD  = 2              XPART   = 0.5
	% +CGDO    = 6.41E-10       CGSO    = 6.41E-10       CGBO    = 1E-12
	% +CJ      = 1.200422E-3    PB      = 0.8478616      MJ      = 0.4105254
	% +CJSW    = 2.001802E-10   PBSW    = 0.8483594      MJSW    = 0.3400571
	% +CJSWG   = 4.22E-10       PBSWG   = 0.8483594      MJSWG   = 0.3400571
	% +CF      = 0              PVTH0   = 2.098588E-3    PRDSW   = 4.4771801
	% +PK2     = 1.799383E-3    WKETA   = 0.0295614      LKETA   = -1.935751E-3
	% +PU0     = -1.3399122     PUA     = -5.27759E-11   PUB     = 1E-21
	% +PVSAT   = -50            PETA0   = 1.003159E-4    PKETA   = -3.434535E-3

	pnames = { ...
		'Type', ... % = -1
		'w', ... %=0.54e-6             
		'tnom', ... %=27               
		'nch', ... %=4.1589e17         
		'k2', ... %=0.0258663          
		'w0', ... %=1e-6               
		'dvt1w', ... %=0               
		'dvt0', ... %    = 0.6117215   
		'u0', ... %      = 106.5280265 
		'uc', ... %      = -1e-10      
		'ags', ... %     = 0.3667554   
		'keta', ... %    = 0.0237092   
		'rdsw', ... %    = 304.9893888 
		'wr', ... %      = 1           
		'dwg', ... %     = -2.44019e-8
		'dwb', ... %     = -9.06003e-10
		'cit', ... %     = 0           
		'cdscb', ... %   = 0           
		'dsub', ... %    = 1.0998181   
		'pdiblc2', ... % = 0.0420477   
		'pscbe1', ... %  = 1.073111e10 
		'delta', ... %   = 0.01        
		'prt', ... %     = 0           
		'kt1l', ... %    = 0           
		'ub1', ... %     = -7.61e-18   
		'wl', ... %      = 0           
		'wwn', ... %     = 1           
		'lln', ... %     = 1           
		'lwl', ... %     = 0           
		'cgdo', ... %    = 6.41e-10    
		'cj', ... %      = 1.200422e-3 
		'cjsw', ... %    = 2.001802e-10
		'cjswg', ... %   = 4.22e-10    
		'cf', ... %      = 0           
		'pk2', ... %     = 1.799383e-3 
		'pu0', ... %     = -1.3399122  
		'pvsat', ... %   = -50         
		'l', ... %=0.18e-6             
		'tox', ... %=4.1e-9            
		'vth0', ... %=-0.3835898       
		'k3', ... %=0                  
		'nlx', ... %=1.20187e-7        
		'dvt2w', ... %=0
		'dvt1', ... %    = 0.2286816   
		'ua', ... %      = 1.125454e-9 
		'vsat', ... %    = 1.593712e5  
		'b0', ... %      = 5.263128e-7 
		'a1', ... %      = 0.2276342   
		'prwg', ... %    = 0.5         
		'wint', ... %    = 0           
		'voff', ... %    = -0.0878287  
		'cdsc', ... %    = 2.4e-4      
		'eta0', ... %    = 0.1672562   
		'pclm', ... %    = 2.2249148   
		'pdiblcb', ... % = -1e-3       
		'pscbe2', ... %  = 3.099395e-9 
		'rsh', ... %     = 7.4         
		'ute', ... %     = -1.5        
		'kt2', ... %     = 0.022       
		'uc1', ... %     = -5.6e-11    
		'wln', ... %     = 1           
		'wwl', ... %     = 0           
		'lw', ... %      = 0           
		'capmod', ... %  = 2           
		'cgso', ... %    = 6.41e-10    
		'pb', ... %      = 0.8478616   
		'pbsw', ... %    = 0.8483594   
		'pbswg', ... %   = 0.8483594   
		'pvth0', ... %   = 2.098588e-3 
		'wketa', ... %   = 0.0295614   
		'pua', ... %     = -5.27759e-11
		'peta0', ... %   = 1.003159e-4 
		'toxm', ... %=4.1e-9
		'xj', ... %=1e-7 
		'k1', ... %=0.59111 
		'k3b', ... %=7.9143108 
		'dvt0w', ... %=0 
		'dvt2', ... %    = 0.1
		'ub', ... %      = 1e-21
		'a0', ... %      = 1.6904754
		'b1', ... %      = 1.496707e-6
		'a2', ... %      = 0.6915706
		'prwb', ... %    = 0.2553725
		'lint', ... %    = 3.217673e-8
		'nfactor', ... % = 1.8560303
		'cdscd', ... %   = 0
		'etab', ... %    = -0.1249603
		'pdiblc1', ... % = 8.275696e-4
		'drout', ... %   = 0
		'pvag', ... %    = 15
		'mobmod', ... %  = 1
		'kt1', ... %     = -0.11
		'ua1', ... %     = 4.31e-9
		'at', ... %      = 3.3e4
		'ww', ... %      = 0
		'll', ... %      = 0
		'lwn', ... %     = 1
		'xpart', ... %   = 0.5
		'cgbo', ... %    = 1e-12
		'mj', ... %      = 0.4105254
		'mjsw', ... %    = 0.3400571
		'mjswg', ... %   = 0.3400571
		'prdsw', ... %   = 4.4771801
		'lketa', ... %   = -1.935751e-3
		'pub', ... %     = 1e-21
		'pketa' ... %   = -3.434535e-3
	};


	pvals = { ...
		-1, ... % Type
		0.54e-6             , ... % w
		27               , ... % tnom
		4.1589e17         , ... % nch
		0.0258663          , ... % k2
		1e-6               , ... % w0
		0               , ... % dvt1w
		0.6117215   , ... % dvt0
		106.5280265 , ... % u0
		-1e-10      , ... % uc
		0.3667554   , ... % ags
		0.0237092   , ... % keta
		304.9893888 , ... % rdsw
		1           , ... % wr
		-2.44019e-8, ... % dwg
		-9.06003e-10, ... % dwb
		0           , ... % cit
		0           , ... % cdscb
		1.0998181   , ... % dsub
		0.0420477   , ... % pdiblc2
		1.073111e10 , ... % pscbe1
		0.01        , ... % delta
		0           , ... % prt
		0           , ... % kt1l
		-7.61e-18   , ... % ub1
		0           , ... % wl
		1           , ... % wwn
		1           , ... % lln
		0           , ... % lwl
		6.41e-10    , ... % cgdo
		1.200422e-3 , ... % cj
		2.001802e-10, ... % cjsw
		4.22e-10    , ... % cjswg
		0           , ... % cf
		1.799383e-3 , ... % pk2
		-1.3399122  , ... % pu0
		-50         , ... % pvsat
		0.18e-6             , ... % l
		4.1e-9            , ... % tox
		-0.3835898       , ... % vth0
		0                  , ... % k3
		1.20187e-7        , ... % nlx
		0, ... % dvt2w
		0.2286816   , ... % dvt1
		1.125454e-9 , ... % ua
		1.593712e5  , ... % vsat
		5.263128e-7 , ... % b0
		0.2276342   , ... % a1
		0.5         , ... % prwg
		0           , ... % wint
		-0.0878287  , ... % voff
		2.4e-4      , ... % cdsc
		0.1672562   , ... % eta0
		2.2249148   , ... % pclm
		-1e-3       , ... % pdiblcb
		3.099395e-9 , ... % pscbe2
		7.4         , ... % rsh
		-1.5        , ... % ute
		0.022       , ... % kt2
		-5.6e-11    , ... % uc1
		1           , ... % wln
		0           , ... % wwl
		0           , ... % lw
		2           , ... % capmod
		6.41e-10    , ... % cgso
		0.8478616   , ... % pb
		0.8483594   , ... % pbsw
		0.8483594   , ... % pbswg
		2.098588e-3 , ... % pvth0
		0.0295614   , ... % wketa
		-5.27759e-11, ... % pua
		1.003159e-4 , ... % peta0
		4.1e-9, ... % toxm
		1e-7 , ... % xj
		0.59111 , ... % k1
		7.9143108 , ... % k3b
		0 , ... % dvt0w
		0.1, ... % dvt2
		1e-21, ... % ub
		1.6904754, ... % a0
		1.496707e-6, ... % b1
		0.6915706, ... % a2
		0.2553725, ... % prwb
		3.217673e-8, ... % lint
		1.8560303, ... % nfactor
		0, ... % cdscd
		-0.1249603, ... % etab
		8.275696e-4, ... % pdiblc1
		0, ... % drout
		15, ... % pvag
		1, ... % mobmod
		-0.11, ... % kt1
		4.31e-9, ... % ua1
		3.3e4, ... % at
		0, ... % ww
		0, ... % ll
		1, ... % lwn
		0.5, ... % xpart
		1e-12, ... % cgbo
		0.4105254, ... % mj
		0.3400571, ... % mjsw
		0.3400571, ... % mjswg
		4.4771801, ... % prdsw
		-1.935751e-3, ... % lketa
		1e-21, ... % pub
		-3.434535e-3 ... % pketa
	};

	minv1pM = feval(minv1pM.setparms, pnames, pvals, minv1pM);
	p_parms = feval(minv1pM.getparms, minv1pM);

	minv1pElement.name = 'mp1'; minv1pElement.model = minv1pM; 
		minv1pElement.nodes = minv1pNodes; 
		minv1pElement.parms = p_parms;

	minv2pElement.name = 'mp2'; minv2pElement.model = minv2pM; 
		minv2pElement.nodes = minv2pNodes; 
		minv2pElement.parms = p_parms;

	minv3pElement.name = 'mp3'; minv3pElement.model = minv3pM; 
		minv3pElement.nodes = minv3pNodes; 
		minv3pElement.parms = p_parms;


	% set up circuitdata structure containing all the above
	% contains: nodenames, groundnodename(s), elements
	% each element contains: name, ModSpecModel, nodes, parms
	circuitdata.cktname = cktname; 
	circuitdata.nodenames = nodes; % all non-ground nodes
	circuitdata.groundnodename = ground;
	circuitdata.elements = {vddElement, iInj1Element, ...
				minv1nElement, minv1pElement, ...
				minv2nElement, minv2pElement, ...
				minv3nElement, minv3pElement};

	% set up and return a DAE of the MNA equations for the circuit
	DAE = MNA_EqnEngine(cktname, circuitdata);
end
