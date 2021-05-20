function [TpDat] = getTpOptParams(TpDat,envDat)

% Computes, formats and compiles S, A, u, D, kcat, SA, and T into a
% structure for input into TpOpt

%% Compile indices
TpMets = TpDat.TpMets;
nTpMets = numel(TpMets);
TpRxns = TpDat.TpRxns;
nTpRxns = numel(TpRxns);

%% Compile environmental data
% Get temperature
TpDat.T = repmat(envDat.T,nTpRxns,1); % degC
% Get substrate concentrations and hydrated molecular diffusivity
TpDat.S = zeros(nTpMets,1);
for a = 1:nTpMets
    TpDat.S(a) = 1e-6.*envDat.(TpMets{a}); % mol m-3
    TpMets_MW = TpDat.TpMets_MW(a); % g mol-1
    TpDat.D(a) = getDiffusivity(TpMets_MW,TpDat.T(a)); % m2 s-1
end

end

