function DAE = DAE_MOSinverter_v1()
% function DAE = DAE_MOSinverter_v1()
% This function creates a DAE for a CMOS Inverter. MOSs are modeled
% using Shichman Hodges model.
% Author: A.Mohanty <mohanty@ieee.org> 
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Circuit Diagram: 
%
%{

   NMOS-PMOS INVERTER      +Vdd (0.8V)
                              | |
      +----------------------||||----------++ Node 3
      |                       | |+         ||       
      |                                    ||       A 
      |                                    || PMOS  |
      |                         || source  ||       | IDS_P
      |                  gate   |+---------+|       |
      |                +-------O|+----------+ bulk  |
      |                |        |+---------+
      |     Vin        |        || drain   |  
      |                |                   | 
      |       | | +    |                   |  
      +------||||------+ Node 1            +---------O  (Vout)
      |       | |      |                   | Node 2
      |                |                   |        |
      |                |        || drain   |        |
      |                |        |+---------+        | IDS_N
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

% Recall that Ig = 0 (for bothe NMOS and PMOS), so we can eliminate KCL
% at Node 1 and afte some more algebraic simplifications to MNA
% formulation we finally left with the following  DAE for the given
% circuit is given by following equation
% (KCL at Node 2): IDS_P(Vin-Vdd,Vout-Vdd)+IDS_N(Vout,Vin) = 0 
% ==>  f(x,u) = IDS_P(VIn-Vdd,Vout-Vdd)+IDS_N(Vout,Vin) with x=Vout


        % Define parameters for the DAE
        DAE.bet_N = 1e-1; % beta parameter for NMOS SH model
        DAE.VTH_N = 0.50; % VTH parameter for NMOS SH model
        DAE.bet_P = 1e-1; % beta parameter for PMOS SH model
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

        % Unknowns: x = [Vout]
        Vout = x(1); 
        % Inputs: u = [Vdd,Vin]
        Vdd = u(1); Vin = u(2);
        % Parameters: bet_N = DAE.bet_N; VTH_N = DAE.VTH_N;
        %             bet_P = DAE.bet_P; VTH_P = DAE.VTH_P;
        bet_N = DAE.bet_N; VTH_N = DAE.VTH_N;
        bet_P = DAE.bet_P; VTH_P = DAE.VTH_P;

        % KCL at Node 2: 
        % IDS_P(VIn-Vdd,Vout-Vdd)+IDS_N(Vout,Vin) = 0
        % ==> f(x,u) = IDS_P(VIn-Vdd,Vout-Vdd)+IDS_N(Vout,Vin) with
        % x=Vout
        fout(1,1)=Shichman_Hodges_Model(Vout,Vin,bet_N,VTH_N,'N')...
                        +Shichman_Hodges_Model(Vout-Vdd,Vin-Vdd,bet_P,VTH_P,'P');
end

function qout = q(x,DAE)
        % q(x) of the DAE

        % Unknowns: x = [Vout]
        Vout = x(1); 
        % Inputs: u = [Vdd,Vin]
        Vdd = u(1); Vin = u(2);

        % Parameters: bet_N = DAE.bet_N; VTH_N = DAE.VTH_N;
        %             bet_P = DAE.bet_P; VTH_P = DAE.VTH_P;
        bet_N = DAE.bet_N; VTH_N = DAE.VTH_N;
        bet_P = DAE.bet_P; VTH_P = DAE.VTH_P;

        qout = [0];
end

% Jacobian matrix for f 
function Jfout=Jf(x,u,DAE)
        % Unknowns: x = [Vout]
        Vout = x(1); 
        % Inputs: u = [Vdd,Vin]
        Vdd = u(1); Vin = u(2);

        % Parameters: bet_N = DAE.bet_N; VTH_N = DAE.VTH_N;
        %             bet_P = DAE.bet_P; VTH_P = DAE.VTH_P;
        bet_N = DAE.bet_N; VTH_N = DAE.VTH_N;
        bet_P = DAE.bet_P; VTH_P = DAE.VTH_P;

        % For NMOS, dIDS_dVout
        dIDdVout_N = dIDdV_Shichman_Hodges_Model(Vout,Vin,bet_N,VTH_N,'N');
        % For PMOS, dIDS_dVout
        dIDdVout_P = dIDdV_Shichman_Hodges_Model(Vout-Vdd,Vin-Vdd,bet_P,VTH_P,'P');
        % df_dx for the DAE
        Jfout(1,1) = dIDdVout_N+dIDdVout_P;
end

% ------FUNCTIONS NOT STRICTLY PART OF GENERAL DAE STRUCTURE----------------------

% Start of the function Shichman_Hodges_Model
function ID = Shichman_Hodges_Model(VDS,VGS,bet,VTH,TIPE)
% function ID= Shichman_Hodges_Model(VDS,VGS,bet,VTH,TIPE)        

        % For NMOS
        if strcmp(TIPE,'N')
                if VDS>=0
                        if (VDS<VGS-VTH) && (VGS>VTH)
                                % (on) linear region for VDS>0 and NMOS
                                ID=bet*VDS*(VGS-0.5*VDS-VTH);
                        elseif (VDS>=VGS-VTH) && (VGS>VTH)
                                % (on) saturation region for VDS>0 and NMOS
                                ID=0.5*bet*(VGS-VTH)^2;
                        elseif VGS<=VTH  
                                % off condition for VDS>0 and NMOS
                                ID=0;
                        end 
                else
                        if (-VDS<VGS-VDS-VTH) && (VGS-VDS>VTH)
                        % Due to symmetry, D and S are interchanged
                                % (on) linear region for -VDS>0 and NMOS
                                ID=-bet*(-VDS)*(VGS-VDS+0.5*VDS-VTH);
                        elseif (-VDS>=VGS-VDS-VTH) && (VGS-VDS>VTH)
                                % (on) saturation region for -VDS>0 and NMOS
                                ID=-0.5*bet*(VGS-VDS-VTH)^2;
                        else
                                % off condition for -VDS>0 and NMOS
                                ID=0;
                        end 

                end 

        % For PMOS
        elseif strcmp(TIPE,'P')
                if -VDS>=0
                        if (-VDS<-VGS-VTH) && (-VGS>VTH)
                                % (on) linear region for -VDS>0 and PMOS
                                ID=-bet*(-VDS)*(-VGS-VTH-0.5*(-VDS));
                        elseif (-VDS>=-VGS-VTH) && (-VGS>VTH)
                                % (on) saturation region for -VDS>0 and PMOS
                                ID=-0.5*bet*(-VGS-VTH)^2;
                        elseif -VGS<=VTH
                                % off condition for -VDS>0 and PMOS
                                ID=0;
                        end 
                else
                        if (-(-VDS)<-VGS-(-VDS)-VTH) && (-VGS-(-VDS)>VTH)
                        % Due to symmetry, D and S are interchanged
                                % (on) linear region for VDS>0 and PMOS
                                ID=-(-bet)*(-(-VDS))*(-VGS-(-VDS)+0.5*(-VDS)-VTH);
                        elseif (-(-VDS)>=-VGS-(-VDS)-VTH) && (-VGS-(-VDS)>VTH)
                                % (on) saturation region for VDS>0 and PMOS
                                ID=-(-0.5)*bet*(-VGS-(-VDS)-VTH)^2;
                        else
                                % off condition for VDS>0 and PMOS
                                ID=0;
                        end 

                end 
        end 
end 
% End of the function Shichman_Hodges_Model

% -----------------Jacobian function -------------------------
function [dID_dVds, dID_dVgs] = dIDdV_Shichman_Hodges_Model(VDS,VGS,bet,VTH,TIPE)
        if strcmp(TIPE,'N')
                if VDS>=0
                        if (VDS<VGS-VTH) && (VGS>VTH)
                                % ID=bet*VDS*(VGS-0.5*VDS-VTH);
                                dID_dVds=bet*(VGS-VDS-VTH);
                                dID_dVgs=bet*VDS;
                        elseif (VDS>=VGS-VTH) && (VGS>VTH)
                                %ID=0.5*bet*(VGS-VTH)^2;
                                dID_dVds=0;
                                dID_dVgs=bet*(VGS-VTH);
                        elseif VGS<=VTH
                                %ID=0;
                                dID_dVds=0;
                                dID_dVgs=0;
                        end 
                else
                        if (-VDS<VGS-VDS-VTH) && (VGS-VDS>VTH)
                                %ID=-bet*(-VDS)*(VGS-VDS+0.5*VDS-VTH);
                                dID_dVds=bet*(VGS-VDS-VTH);
                                dID_dVgs=-bet*(-VDS);
                        elseif (-VDS>=VGS-VDS-VTH) && (VGS-VDS>VTH)
                                %ID=-0.5*bet*(VGS-VDS-VTH)^2;
                                dID_dVds=bet*(VGS-VDS-VTH);
                                dID_dVgs=-bet*(VGS-VDS-VTH);
                        else
                                %ID=0;
                                dID_dVds=0;
                                dID_dVgs=0;
                        end 

                end 

        else
                if -VDS>=0
                        if (-VDS<-VGS-VTH) && (-VGS>VTH)
                                %ID=bet*(-VDS)*(-VGS-0.5*(-VDS)-VTH);
                                dID_dVds=-bet*(VGS+(-VDS)+VTH);
                                dID_dVgs=bet*(-VDS);
                        elseif (-VDS>=-VGS-VTH) && (-VGS>VTH)
                                %ID=0.5*bet*(-VGS-VTH)^2;
                                dID_dVds=0;
                                dID_dVgs=bet*(-VGS-VTH);
                        elseif -VGS<=VTH
                                %ID=0;
                                dID_dVds=0;
                                dID_dVgs=0;
                        end 
                else
                        if (-(-VDS)<-VGS-(-VDS)-VTH) && (-VGS-(-VDS)>VTH)
                                %ID=(-bet)*(-(-VDS))*(-VGS-(-VDS)+0.5*(-VDS)-VTH);
                                dID_dVds=(bet)*(-VGS+VDS-VTH);
                                dID_dVgs=-(bet)*(VDS);
                        elseif (-(-VDS)>=-VGS-(-VDS)-VTH) && (-VGS-(-VDS)>VTH)
                                %ID=(-0.5)*bet*(-VGS-(-VDS)-VTH)^2;
                                dID_dVds=bet*(-VGS+VDS-VTH);
                                dID_dVgs=-bet*(-VGS-(-VDS)+VTH);
                        else
                                %ID=0;
                                dID_dVds=0;
                                dID_dVgs=0;
                        end 

                end 
        end 
end % fBCR


