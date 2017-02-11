function dfdp = df_dp_DAEAPI_auto(x, u, parmObj, DAE)
%function dfdp = df_dp_DAEAPI_auto(x, u, parmObj, DAE)
%Calls function dfq_dp_DAEAPI_auto(...) and returns df_dp (derivative of f with
%respect to parameters) 
%See help for dfq_dp_DAEAPI_auto for more info.
	dfdp = dfq_dp_DAEAPI_auto(x, u, parmObj,'f',DAE);
end
