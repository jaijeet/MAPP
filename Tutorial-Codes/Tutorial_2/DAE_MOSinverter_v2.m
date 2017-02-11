function DAE = DAE_MOSinverter_v2()
% function DAE = DAE_MOSinverter_v2()
% This function creates a DAE for a CMOS Inverter. MOSs are modeled
% using Shichman Hodges model.
% Author: A.Mohanty <mohanty@ieee.org> 
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Circuit Diagram: 
%
%{

   NMOS-PMOS INVERTER      +Vdd (0.8V)
                              | | <--- I_VDD
      +----------------------||||----------++ Node 3 (e_VDD)
      |                       | |+         ||       
      |                                    ||       A 
      |                                    || PMOS  |
      |                         || source  ||       | IDS_P
      |                  gate   |+---------+|       |
      |                +-------O|+----------+ bulk  |
      |                | ---->  |+---------+
      |     Vin        | IGS_P  || drain   |   
      |                |                   |   
      |       | | +    |                   |  
      +------||||------+ Node 1 (e_IN)     +---------O  (Vout)
      |       | | <--- |                   | Node 2 (e_OUT)
      |          I_VIN |                   |        |
      |                | ---->  || drain   |        |
      |                | IGS_N  |+---------+        | IDS_N
      |                +--------|+----------+ bulk  |
      |                  gate   |+---------+|       V
      |                         ||  source ||
      |                                    || NMOS
      |                                    ||
      +------------------------------------||
                                           ||
                                         --++--
                                          ----   Ground
                                           --

%}

% Circuit equations for the MOS inverter shown in above ascii art are
%
% KCL_IN  :: IGS_N(e_OUT,e_IN) + IGS_P(e_OUT-e_VDD,e_IN-e_VDD) + I_VIN = 0
% KCL_OUT :: IDS_N(e_OUT,e_IN) + IDS_P(e_OUT-e_VDD,e_IN-e_VDD)= 0
% KCL_VDD :: I_VDD + IDS_P(e_OUT-e_VDD,e_IN-e_VDD) + IGS_P(e_OUT-e_VDD,e_IN-e_VDD) = 0
% KVL_Vin :: e_IN - Vin = 0
% KVL_Vdd :: e_VDD - Vdd = 0

% Hence the DAE formulation of the circuit is given by
%           q(x) + f(x,u) = 0
% where
% x = [e_IN; e_VDD; e_OUT; I_VIN; I_VDD]
% u = [Vdd; Vin]
% f(x,u) = [ IGS_N(e_OUT,e_IN) + IGS_P(e_OUT-e_VDD,e_IN-e_VDD) + I_VIN; ...
%            IDS_N(e_OUT,e_IN) + IDS_P(e_OUT-e_VDD,e_IN-e_VDD); ...
%            I_VDD + IDS_P(e_OUT-e_VDD,e_IN-e_VDD) + IGS_P(e_OUT-e_VDD,e_IN-e_VDD); ...
%            e_IN - Vin; ... 
%            e_VDD - Vdd]
% q(x) = [0; 0; 0; 0; 0];



        % Define parameters for the DAE
        DAE.bet_N = 1e-3; % beta parameter for NMOS SH model
        DAE.VTH_N = 0.50; % VTH parameter for NMOS SH model
        DAE.bet_P = 1e-3; % beta parameter for PMOS SH model
        DAE.VTH_P = 0.50; % VTH parameter for PMOS SH model

        % Define f and q for the DAE
        DAE.f = @f; DAE.q = @q;

        % Input related functions nd fields
        DAE.uQSSvec = 'unassigned'; % field to store input vec
        DAE.set_uQSSvec = @set_uQSSvec; % function to set input vec
        DAE.uQSS = @uQSS; % function to access input vec

        % Define Jacobian matrix Jf 
        DAE.Jf = @Jf; 
end 

% ------------- FUNCTION DEFINITIONS -----------------
function outDAE = set_uQSSvec(qssvec,DAE)
        % This function sets various input values. In this particular
        % case, it sets up Vdd and Vin, i.e., qssvec=[Vdd;Vin]. 
        DAE.uQSSvec = qssvec;
        outDAE = DAE;
end

function qssvec = uQSS(DAE)
        % This function accesses the inputs of the DAE.
        qssvec = DAE.uQSSvec;
end

function fout = f(x,u,DAE)
        % f(x,u) of the DAE
        % Unknowns: x = [e_IN; e_VDD; e_OUT; I_VIN; I_VDD]
        e_IN = x(1); 
        e_VDD = x(2); 
        e_OUT = x(3); 
        I_VIN = x(4); 
        I_VDD = x(5); 
        % Inputs: u = [Vdd,Vin]
        Vdd = u(1); Vin = u(2);
        % Parameters: bet_N = DAE.bet_N; VTH_N = DAE.VTH_N;
        %             bet_P = DAE.bet_P; VTH_P = DAE.VTH_P;
        bet_N = DAE.bet_N; VTH_N = DAE.VTH_N;
        bet_P = DAE.bet_P; VTH_P = DAE.VTH_P;

        % f(x,u) = [ IGS_N(e_OUT,e_IN) + IGS_P(e_OUT-e_VDD,e_IN-e_VDD) + I_VIN; ...
        %            IDS_N(e_OUT,e_IN) + IDS_P(e_OUT-e_VDD,e_IN-e_VDD); ...
        %            I_VDD + IDS_P(e_OUT-e_VDD,e_IN-e_VDD) + IGS_P(e_OUT-e_VDD,e_IN-e_VDD); ...
        %            e_IN - Vin; ... 
        %            e_VDD - Vdd]
        [IDS_N,IGS_N] = Shichman_Hodges_Model(e_OUT,e_IN,bet_N,VTH_N,'N');
        [IDS_P,IGS_P] = Shichman_Hodges_Model(e_OUT-e_VDD,e_IN-e_VDD,bet_P,VTH_P,'P');

        fout(1,1) = IGS_N + IGS_P + I_VIN;
        fout(2,1) = IDS_N + IDS_P;
        fout(3,1) = I_VDD + IDS_P + IGS_P;
        fout(4,1) = e_IN - Vin;
        fout(5,1) = e_VDD - Vdd;
end

function qout = q(x,DAE)
        % q(x) of the DAE
        qout = [0;0;0;0;0];
end

% Jacobian matrix for f 
function Jfout=Jf(x,u,DAE)
        % Unknowns: x = [e_IN; e_VDD; e_OUT; I_VIN; I_VDD]
        e_IN = x(1); 
        e_VDD = x(2); 
        e_OUT = x(3); 
        I_VIN = x(4); 
        I_VDD = x(5); 
        % Inputs: u = [Vdd,Vin]
        Vdd = u(1); Vin = u(2);
        % Parameters: bet_N = DAE.bet_N; VTH_N = DAE.VTH_N;
        %             bet_P = DAE.bet_P; VTH_P = DAE.VTH_P;
        bet_N = DAE.bet_N; VTH_N = DAE.VTH_N;
        bet_P = DAE.bet_P; VTH_P = DAE.VTH_P;

        % Jfout(x,u) = df_dx
        % The following derivatives are "partial derivatives" for IGS_P,
        % IGS_N, IDS_N and IDS_P w.r.t. VDS (first argument) and
        % VGS(second argument).

        % [dIDS_N_dVDS, dIDS_N_dVGS, dIGS_N_dVDS, dIGS_N_dVGS] = ...
        %       dShichman_Hodges_Model(e_OUT,e_IN,bet_N,VTH_N,'N');
         [dIDS_N_dVDS, dIDS_N_dVGS, dIGS_N_dVDS, dIGS_N_dVGS] = ...
               dShichman_Hodges_Model(e_OUT,e_IN,bet_N,VTH_N,'N');

        % [dIDS_P_dVDS, dIDS_P_dVGS, dIGS_P_dVDS, dIGS_P_dVGS] = ...
        %       dShichman_Hodges_Model(e_OUT,e_IN,bet_N,VTH_N,'N');
         [dIDS_P_dVDS, dIDS_P_dVGS, dIGS_P_dVDS, dIGS_P_dVGS] = ...
               dShichman_Hodges_Model(e_OUT,e_IN,bet_P,VTH_P,'P');




        % Jfout(1,1) =  df(1,1)_de_IN
        %         =  dIGS_N_dVGS(e_OUT,e_IN) + dIGS_P_dVGS(e_OUT-e_VDD,e_IN-e_VDD);
        Jfout(1,1) = dIGS_N_dVGS + dIGS_P_dVGS;

        % Jfout(1,2) =  df(1,1)_de_VDD 
        %         =  [dIGS_P_dVGS(e_OUT-e_VDD,e_IN-e_VDD)*(-1) + dIGS_P_dVDS(e_OUT-e_VDD,e_IN-e_VDD)*(-1)];
        % Note: Why multiplication with (-1)?
        % df(y-x)_dx = df(y-x)_d(y-x) * d(y-x)_dx= (-1)*df(x)_dx|_(x=y-x)
        Jfout(1,2) = dIGS_P_dVGS*(-1) + dIGS_P_dVDS*(-1);

        % Jfout(1,3) =  df(1,1)_de_OUT
        %         =  dIGS_N_dVDS(e_OUT,e_IN) + dIGS_P_dVDS(e_OUT-e_VDD,e_IN-e_VDD);
        Jfout(1,3)= dIGS_N_dVDS + dIGS_P_dVDS;

        % Jfout(1,4) =  df(1,1)_dI_VIN = 1
        Jfout(1,4)   = 1;
         
        % Jfout(1,5) =  df(1,1)_dI_VDD = 0;
        Jfout(1,5)   = 0;


        % f(2,1)  =  IDS_N(e_OUT,e_IN) + IDS_P(e_OUT-e_VDD,e_IN-e_VDD); ...
        % Jfout(2,1) =  df(2,1)_de_IN
        %         =  dIDS_N_dVGS(e_OUT,e_IN) + dIDS_P_dVGS(e_OUT-e_VDD,e_IN-e_VDD);
        Jfout(2,1)   =  dIDS_N_dVGS + dIDS_P_dVGS;

        % Jfout(1,2) =  df(2,1)_de_VDD 
        %         =  dIDS_P_dVDS(e_OUT-e_VDD,e_IN-e_VDD)*(-1)+dIDS_P_dVGS(e_OUT-e_VDD,e_IN-e_VDD)*(-1);
        Jfout(2,2)   =  dIDS_P_dVDS * (-1) + dIDS_P_dVGS * (-1);

        % Jfout(2,3) =  df(2,1)_de_OUT
        %         =  dIDS_N_dVDS(e_OUT,e_IN) + dIDS_P_dVDS(e_OUT-e_VDD,e_IN-e_VDD);
        Jfout(2,3)   =  dIDS_N_dVDS + dIDS_P_dVDS;

        % Jfout(1,4) =  df(2,1)_dI_VIN =0 
        Jfout(2,4)   = 0;

        % Jfout(2,5) =  df(2,1)_dI_VDD = 0;
        Jfout(2,5) = 0;

        % f(3,1)  =  I_VDD + IDS_P(e_OUT-e_VDD,e_IN-e_VDD) + IGS_P(e_OUT-e_VDD,e_IN-e_VDD); ...
        % Jfout(3,1) =  df(3,1)_de_IN
        %         =  dIDS_P_dVGS(e_OUT-e_VDD,e_IN-e_VDD) + dIGS_P_dVGS(e_OUT-e_VDD,e_IN-e_VDD);
        Jfout(3,1)   =  dIGS_P_dVGS + dIDS_P_dVGS;

        % Jfout(3,2) =  df(3,1)_de_VDD 
        %         =  dIDS_P_dVDS(e_OUT-e_VDD,e_IN-e_VDD)*(-1)+dIDS_P_dVGS(e_OUT-e_VDD,e_IN-e_VDD)*(-1);
        Jfout(3,2)   =  dIDS_P_dVDS * (-1) + dIDS_P_dVGS * (-1) + dIGS_P_dVDS * (-1) + dIGS_P_dVGS * (-1);

        % Jfout(3,3) =  df(3,1)_de_OUT
        %         =  dIDS_P_dVDS(e_OUT-e_VDD,e_IN-e_IN) + dIGS_P_dVGS(e_OUT-e_VDD,e_IN-e_VDD);
        Jfout(3,3)   =  dIDS_P_dVDS + dIGS_P_dVDS;

        % Jfout(3,4) =  df(3,1)_dI_VIN =0 
        Jfout(3,4)   = 0;

        % Jfout(3,5) =  df(3,1)_dI_VDD = 1;
        Jfout(3,5) = 1;


        % f(4,1)  =  e_IN - Vin; 
        % Jfout(4,1) =  df(4,1)_de_IN=1;
        Jfout(4,1)   =  1;

        % Jfout(4,2) =  df(4,1)_de_VDD =0;
        Jfout(4,2)   =  0;

        % Jfout(4,3) =  df(4,1)_de_OUT =0;
        Jfout(4,3)   =  0;

        % Jfout(4,4) =  df(4,1)_dI_VIN = 0;
        Jfout(4,4)   = 0;

        % Jfout(4,5) =  df(4,1)_dI_VDD = 0;
        Jfout(4,5) = 0;
        
        % f(5,1) =  e_VDD - Vdd
        % Jfout(5,1) =  df(5,1)_de_IN=0;
        Jfout(5,1)   =  0;

        % Jfout(5,2) =  df(5,1)_de_VDD =1;
        Jfout(5,2)   =  1;

        % Jfout(5,3) =  df(5,1)_de_OUT =0;
        Jfout(5,3)   =  0;

        % Jfout(5,4) =  df(5,1)_dI_VIN = 0;
        Jfout(5,4)   = 0;

        % Jfout(5,5) =  df(5,1)_dI_VDD = 0;
        Jfout(5,5) = 0;
end

% ------FUNCTIONS NOT STRICTLY PART OF GENERAL DAE STRUCTURE----------------------

% Start of the function Shichman_Hodges_Model
function [IDS,IGS] = Shichman_Hodges_Model(VDS,VGS,bet,VTH,TIPE)
% function [IDS, IGS]= Shichman_Hodges_Model(VDS,VGS,bet,VTH,TIPE)        
IGS=0;
        % For NMOS
        if strcmp(TIPE,'N')
                if VDS>=0
                        if (VDS<VGS-VTH) && (VGS>VTH)
                                % (on) linear region for VDS>0 and NMOS
                                IDS=bet*VDS*(VGS-0.5*VDS-VTH);
                        elseif (VDS>=VGS-VTH) && (VGS>VTH)
                                % (on) saturation region for VDS>0 and NMOS
                                IDS=0.5*bet*(VGS-VTH)^2;
                        elseif VGS<=VTH  
                                % off condition for VDS>0 and NMOS
                                IDS=0;
                        end 
                else
                        if (-VDS<VGS-VDS-VTH) && (VGS-VDS>VTH)
                        % Due to symmetry, D and S are interchanged
                                % (on) linear region for -VDS>0 and NMOS
                                IDS=-bet*(-VDS)*(VGS-VDS+0.5*VDS-VTH);
                        elseif (-VDS>=VGS-VDS-VTH) && (VGS-VDS>VTH)
                                % (on) saturation region for -VDS>0 and NMOS
                                IDS=-0.5*bet*(VGS-VDS-VTH)^2;
                        else
                                % off condition for -VDS>0 and NMOS
                                IDS=0;
                        end 

                end 

        % For PMOS
        elseif strcmp(TIPE,'P')
                if -VDS>=0
                        if (-VDS<-VGS-VTH) && (-VGS>VTH)
                                % (on) linear region for -VDS>0 and PMOS
                                IDS=-bet*(-VDS)*(-VGS-VTH-0.5*(-VDS));
                        elseif (-VDS>=-VGS-VTH) && (-VGS>VTH)
                                % (on) saturation region for -VDS>0 and PMOS
                                IDS=-0.5*bet*(-VGS-VTH)^2;
                        elseif -VGS<=VTH
                                % off condition for -VDS>0 and PMOS
                                IDS=0;
                        end 
                else
                        if (-(-VDS)<-VGS-(-VDS)-VTH) && (-VGS-(-VDS)>VTH)
                        % Due to symmetry, D and S are interchanged
                                % (on) linear region for VDS>0 and PMOS
                                IDS=-(-bet)*(-(-VDS))*(-VGS-(-VDS)+0.5*(-VDS)-VTH);
                        elseif (-(-VDS)>=-VGS-(-VDS)-VTH) && (-VGS-(-VDS)>VTH)
                                % (on) saturation region for VDS>0 and PMOS
                                IDS=-(-0.5)*bet*(-VGS-(-VDS)-VTH)^2;
                        else
                                % off condition for VDS>0 and PMOS
                                IDS=0;
                        end 

                end 
        end 
end 
% End of the function Shichman_Hodges_Model

% -----------------Jacobian function -------------------------
function [dIDS_dVDS, dIDS_dVGS, dIGS_dVDS, dIGS_dVGS] = dShichman_Hodges_Model(VDS,VGS,bet,VTH,TIPE)
        % IGS = 0 always, hence its partial derivative with respect to
        % VGS as well as VDS is always zero.
        dIGS_dVGS = 0;
        dIGS_dVDS = 0;

        % Partials of IDS (Drain-to-Source current)
        if strcmp(TIPE,'N')
                if VDS>=0
                        if (VDS<VGS-VTH) && (VGS>VTH)
                                % ID=bet*VDS*(VGS-0.5*VDS-VTH);
                                dIDS_dVDS=bet*(VGS-VDS-VTH);
                                dIDS_dVGS=bet*VDS;
                        elseif (VDS>=VGS-VTH) && (VGS>VTH)
                                %ID=0.5*bet*(VGS-VTH)^2;
                                dIDS_dVDS=0;
                                dIDS_dVGS=bet*(VGS-VTH);
                        elseif VGS<=VTH
                                %ID=0;
                                dIDS_dVDS=0;
                                dIDS_dVGS=0;
                        end 
                else
                        if (-VDS<VGS-VDS-VTH) && (VGS-VDS>VTH)
                                %ID=-bet*(-VDS)*(VGS-VDS+0.5*VDS-VTH);
                                dIDS_dVDS=bet*(VGS-VDS-VTH);
                                dIDS_dVGS=-bet*(-VDS);
                        elseif (-VDS>=VGS-VDS-VTH) && (VGS-VDS>VTH)
                                %ID=-0.5*bet*(VGS-VDS-VTH)^2;
                                dIDS_dVDS=bet*(VGS-VDS-VTH);
                                dIDS_dVGS=-bet*(VGS-VDS-VTH);
                        else
                                %ID=0;
                                dIDS_dVDS=0;
                                dIDS_dVGS=0;
                        end 

                end 

        else
                if -VDS>=0
                        if (-VDS<-VGS-VTH) && (-VGS>VTH)
                                %ID=bet*(-VDS)*(-VGS-0.5*(-VDS)-VTH);
                                dIDS_dVDS=-bet*(VGS+(-VDS)+VTH);
                                dIDS_dVGS=bet*(-VDS);
                        elseif (-VDS>=-VGS-VTH) && (-VGS>VTH)
                                %ID=0.5*bet*(-VGS-VTH)^2;
                                dIDS_dVDS=0;
                                dIDS_dVGS=bet*(-VGS-VTH);
                        elseif -VGS<=VTH
                                %ID=0;
                                dIDS_dVDS=0;
                                dIDS_dVGS=0;
                        end 
                else
                        if (-(-VDS)<-VGS-(-VDS)-VTH) && (-VGS-(-VDS)>VTH)
                                %ID=(-bet)*(-(-VDS))*(-VGS-(-VDS)+0.5*(-VDS)-VTH);
                                dIDS_dVDS=(bet)*(-VGS+VDS-VTH);
                                dIDS_dVGS=-(bet)*(VDS);
                        elseif (-(-VDS)>=-VGS-(-VDS)-VTH) && (-VGS-(-VDS)>VTH)
                                %ID=(-0.5)*bet*(-VGS-(-VDS)-VTH)^2;
                                dIDS_dVDS=bet*(-VGS+VDS-VTH);
                                dIDS_dVGS=-bet*(-VGS-(-VDS)+VTH);
                        else
                                %ID=0;
                                dIDS_dVDS=0;
                                dIDS_dVGS=0;
                        end 

                end 
        end 
end % fBCR


