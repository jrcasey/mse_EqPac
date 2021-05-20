function envDat = getEnvVars(CruiseData,station_idx,depth_idx)
%% getEnvVars
% Retrieve enviromental data for a particular grid point.

envDat = struct;
envDat.Ammonia = CruiseData.Ammonia(station_idx,depth_idx);
envDat.Nitrite = CruiseData.Nitrite(station_idx,depth_idx);
envDat.Nitrate = CruiseData.Nitrate(station_idx,depth_idx);
envDat.Orthophosphate = CruiseData.Orthophosphate(station_idx,depth_idx);
envDat.T = CruiseData.T(station_idx,depth_idx);
envDat.Ed = CruiseData.IrrDat(depth_idx,:,station_idx);

end


