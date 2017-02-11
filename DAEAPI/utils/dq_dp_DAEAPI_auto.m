function dqdp = dq_dp_DAEAPI_auto(x, parmObj, DAE)
%function dqdp = dq_dp_DAEAPI_auto(x, parmObj, DAE)
%Calls function dfq_dp_DAEAPI_auto(...) and returns dq_dp (derivative of q with
%respect to parameters) 
%See help for dfq_dp_DAEAPI_auto for more info.
	[dfdp, dqdp] = dfq_dp_DAEAPI_auto(x, [], parmObj, 'q',DAE);
end
