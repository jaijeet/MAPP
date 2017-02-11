function Sout = ee_model_parm2struct(MOD)
%function Sout = ee_model_parm2struct(MOD)
%used to be: function Sout = ee_model_parm2struct(MOD, S) - 2nd arg support
%                                           removed 2014/06/23, JR.
%Author: Tianshi Wang, 2014/02/15
    
% Changelog
% ---------
%2014/02/15: Tianshi Wang, <tianshi@berkeley.edu>
%updated/arg list changed by: JR, 2014/06/23.

    %{
	if nargin >= 2
		Sout = S;
	end
    %}

	parm_vals = MOD.getparms(MOD);
    Sout = cell2struct(parm_vals, MOD.parm_names, 2);

    % parameters
    %{
    for idx = 1 : 1 : length(MOD.parm_names)
        eval ( ['Sout.', MOD.parm_names{idx}, ' = parm_vals{idx};'] );
    end
    %}
end
