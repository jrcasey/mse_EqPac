function CruiseDat = getCruiseData(CruiseDB, depthVec)
%% Standardize EqPac Data

varNames = CruiseDB.Properties.VariableNames(6:end); % just the nutrients for now
% Find and index stations
uStations = unique(CruiseDB.Station);
nStations = numel(uStations);
% indices for each station
for a = 1:nStations
    station_ind{a} = find(CruiseDB.Station == uStations(a));
end
% indices for each depth
for a = 1:numel(depthVec)
   depth_ind{a} = find(CruiseDB.Depth == depthVec(a));
end

% Interpolate (depth)
CruiseDat = struct;
CruiseDat.Stations = uStations;
CruiseDat.Depth = depthVec;
for a = 1:nStations
    for b = 1:numel(varNames) 
        clear x v vq
        x = CruiseDB.Depth(station_ind{a});
        v = CruiseDB.(varNames{b})(station_ind{a});
        % deal with the nans
        nanInd = find(isnan(v));
        x(nanInd) = [];
        v(nanInd) = [];
        if numel(find(~isnan(v)))<3
            CruiseDat.(varNames{b})(a,:) = zeros(numel(depthVec),1);
        else
        vq = interp1(x,v,depthVec,'linear');
        CruiseDat.(varNames{b})(a,:) = vq;
        end
    end
    CruiseDat.Lat(a) = CruiseDB.Lat(station_ind{a}(1));
    CruiseDat.Lon(a) = CruiseDB.Lon(station_ind{a}(1));
    CruiseDat.Date(a) = CruiseDB.Date(station_ind{a}(1));
end

% interpolate (latitude)
depthIdx_vec = 1:numel(depthVec);
for a = 1:numel(depthVec)
    for b = 1:numel(varNames) 
        clear x v vq
        x = CruiseDB.Lat(depth_ind{a});
        v = CruiseDB.(varNames{b})(depth_ind{a});
        % deal with the nans
        nanInd = find(isnan(v));
        x(nanInd) = [];
        v(nanInd) = [];
        if numel(find(~isnan(v)))<5
            CruiseDat.(varNames{b})(:,a) = zeros(nStations,1);
        else
        vq = interp1(x,v,CruiseDat.Lat,'linear');
        CruiseDat.(varNames{b})(:,a) = vq;
        end
    end
end


% Change some units to nM
CruiseDat.Nitrate = CruiseDat.NO3 .* 1000;
CruiseDat.Nitrite = CruiseDat.NO2 .* 1000;
CruiseDat.Orthophosphate = CruiseDat.PO4 .* 1000;
CruiseDat.Ammonia = nanmean(cat(3,CruiseDat.NH4,CruiseDat.LL_nh4),3) .* 1000; % shit correlation between the two methods, so taking the average for lack of a better idea

% Some name changes too
CruiseDat.T = CruiseDat.temp;
CruiseDat = rmfield(CruiseDat,{'Temp_1000','urea','LL_nh4','NH4','NO3','NO2','PO4'});




end