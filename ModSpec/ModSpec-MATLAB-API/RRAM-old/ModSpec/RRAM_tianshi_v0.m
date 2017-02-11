function MOD = RRAM_tianshi(uniqID)
%function MOD = RRAM_tianshi(uniqID)
%
% TODO: descriptions
%
% OBSOLETE COMMENTS BELOW
%



% This function creates a ModSpec model for a resistive random-access memory
% (RRAM) cell.
%
% An RRAM is a two-terminal device with two terminals p and n, two I/Os ipn and
% vpn. For a regular two-terminal resistor-like device, we should be able to
% write the model equation as:
% 
%    ipn = f(vpn).                (1)
% 
% But for RRAM, there is another variable that affects ipn: the length of the 
% filament in the dielectric (l).
% 
% Then the ipn equation becomes:
% 
%    ipn = f1(vpn, l).            (2)
% 
% And filament length satisfies a differential equation:
% 
%    d/dt l = f2(vpn, l).         (3)
% 
% If we figure out what f1 and f2 should be, the model is complete.
% 
% 1) f1 can be written as
% 
%    f1(vpn, l) = I0 * exp(-(h-l)/g0) * sinh(vpn/V0).   (4)
% 
%    source: Jiang, Z., Wong, H. (2014). Stanford University Resistive-Switching
%        Random Access Memory (RRAM) Verilog-A Model. nanoHUB.
%        doi:10.4231/D37H1DN48	
%
%    The closer l is to h, the closer exp(-(h-l)/g0) is to 1, the larger the
%    current.
%    The larger the voltage vpn, the larger the current.
%    I0, g0, V0 are fitting parameters.
% 
% 2) As for f2, let's first consider the condition for f2 = 0.
%    
%    Apparently, when l = 0 and vpn is small, d/dt l should be 0.
%    Similarly, when l = h and vpn is large, d/dt l should be 0.
%    Now we trace the curve f2(vpn, l) = 0 and look for all the points
%    (vpn, l) on it. We start from (-inf, 0) and increase vpn all the way to
%    Vset > 0, which is the voltage where the tip of the filament begins to
%    grow towards the opposite electrode. f2 becomes positive and l grows to h,
%    landing on another point (Vset, h) on the f2=0 curve. Similarly, if we
%    sweep vpn back, at (Vreset, h), the filament begins to break.
%    
%    Put in other words, when vpn>=Vset, f2=0 has only one solution with l=h;
%    when vpn<=Vreset, f2=0 has only one solution with l=0; in the middle, l is
%    bistable at 0 or h. For continuity, the f2=0 solutions should also contain
%    a curve connecting (Vreset, h) and (Vset, 0) with a negative slope.
%    
%    Therefore, we should find an f2(vpn, l) that satisfies the above condition.
%    f2 should be designed such that at vpn=Vset and vpn=Vreset, the growth or
%    breakdown of the filament is accurately modelled. We will model these once
%    we find concrete measurement data for the change of filament length.
%
%    For the moment, let's consider a simple function for f2.
%    We first model the negative slope of f2(vpn, l) = 0.
%    
%    0 = (1-l/h) * Vset + l/h * Vreset.   (5)
% 
%    Then we write f2 as    
%    
%    f2 = K * (vpn - (1-l/h) * Vset - l/h * Vreset),    (6)
%    
%    where K>0 is a fitting parameter, such that when vpn is on the right side
%    of the line with the negative slope, f2 > 0, and vice versa.
%    
%    Then we clip the curve to be between l=0 and l=h by adding two terms.    
%    
%    clip_ge_h = -exp(Kclip*(l-h)).   (7)
%    clip_le_0 = exp(Kclip*(-l)).     (8)
%    
%    f2 = K * (vpn - (1-l/h) * Vset - l/h * Vreset) + clip_ge_h + clip_le_0. (9)
%    



%Arguments:
% - uniqID: (optional) a unique identification string. Eg, 'RRAM1'
%
%Return values:
% - MOD:    a ModSpec object for the RRAM UMich model
%
%Model information
%-----------------
%
% - nodes and their names: 
%   - {'p', 'n'} (positive and negative terminals).
%

% - parameters:
% - 'I0'   (fitting parameter [A])
%           default: 1e-3
% - 'g0'   (fitting parameter [nm])
%           default: 0.25
% - 'V0'   (fitting parameter [V])
%           default: 0.25
% - 'h'    (film thickness [nm])
%           default: 5
% - 'Vset' (fitting parameter [V])
%           default: 1.5
% - 'Vreset' (fitting parameter [V])
%           default: -1.5
% - 'K'   (fitting parameter [nm/(s*V)])
%           default: 1e3 % TODO
% - 'Kclip' (clipping factor [none])
%           default: 1e3
% - 'maxslope' (maxmum slope in safeexp)
%           default: 1e15
% - 'GMIN' (SPICE GMIN)
%           default: 1e-12
%
%Lower-level Model information
%-----------------------------
%
% 1. variables:
% - IO names:                        vpn  ipn
% - explicit output name(s):         ipn
% - other IO name(s) (vecX):         vpn
%
% - implicit unknown name(s) (vecY): l (in nm)
% - input names (vecU):              {} % TODO: variation comes in here if needed
% - limited variable (vecLim):       {}
%
% 2. equations: %TODO
%
%
%Examples
%--------
%TODO
%
%See also
%--------
% 
% add_element, circuitdata[TODO], ModSpec, DAEAPI, DAE_concepts
%

    MOD = ee_model();

    MOD = add_to_ee_model(MOD, 'modelname', 'RRAM_ModSpec_wrapper');
    MOD = add_to_ee_model(MOD, 'description', 'TODO');

    MOD = add_to_ee_model(MOD, 'terminals', {'p', 'n'});
    MOD = add_to_ee_model(MOD, 'explicit_outs', {'ipn'});

    MOD = add_to_ee_model(MOD, 'internal_unks', {'l'}); % in nm

    MOD = add_to_ee_model(MOD, 'parms', {'I0', 1e-3});
    MOD = add_to_ee_model(MOD, 'parms', {'g0', 0.25});
    MOD = add_to_ee_model(MOD, 'parms', {'V0', 0.25});
    MOD = add_to_ee_model(MOD, 'parms', {'h', 5});
    MOD = add_to_ee_model(MOD, 'parms', {'Vset', 1.5});
    MOD = add_to_ee_model(MOD, 'parms', {'Vreset', -1.5});
    MOD = add_to_ee_model(MOD, 'parms', {'K', 1e3});
    MOD = add_to_ee_model(MOD, 'parms', {'Kclip', 1e3});
    MOD = add_to_ee_model(MOD, 'parms', {'maxslope', 1e15});
    MOD = add_to_ee_model(MOD, 'parms', {'GMIN', 1e-12});

    MOD = add_to_ee_model (MOD, 'fe', @fe);
    MOD = add_to_ee_model (MOD, 'qe', @qe);
    MOD = add_to_ee_model (MOD, 'fi', @fi);
    MOD = add_to_ee_model (MOD, 'qi', @qi);

    MOD = finish_ee_model(MOD);

end

function out = fe(S)
    out = fqei(S, 'f', 'e');
end

function out = qe(S)
    out = fqei(S, 'q', 'e');
end

function out = fi(S)
    out = fqei(S, 'f', 'i');
end

function out = qi(S)
    out = fqei(S, 'q', 'i');
end

function out = fqei(S, forq, eori)

    v2struct(S);

    if 1 == strcmp(eori,'e') % e
        if 1 == strcmp(forq, 'f') % f
            out(1,1) = I0 * safeexp(-(h-l)/g0, maxslope) * mysinh(vpn/V0, maxslope);
            out(1,1) = out(1,1) + GMIN * vpn;
        else % q
            out(1,1) = 0;
        end % forq
    else % i
        if 1 == strcmp(forq, 'f') % f
			clip_ge_h = -safeexp(Kclip*(l-h), maxslope);
			clip_le_0 = safeexp(Kclip*(-l), maxslope);
            out(1,1) = K * (vpn - (1-l/h) * Vset - l/h * Vreset) + clip_ge_h + clip_le_0;
        else % q
            out(1,1) = -l;
        end
    end
end

%%%%%%%%%%%%%  Internal Functions  %%%%%%%%%%%%%%%%%

function y = mysinh(x, maxslope)
    y = (safeexp(x, maxslope) - safeexp(-x, maxslope))/2;
end % mysinh
