clear
close all

%% MSE Batch Setup
% Run this before sending off to the server.

% Defines directories, filenames, gridding parameters, and various options
% to set up a batch run. Loads and formats environmental data to match the
% gridding.

% Steps required to set up a run:
% Filenames - define paths to data, models, databases, and outputs
% Gridding - define domain and resolution of the batch run
% Optimization options - define step sizes, tolerances, etc for the solvers
% Other options - there are a few other miscellaneous parameters to attend
% to

% Saves FileNames, Gridding, CruiseData, and Options structures to ~/data/output folder

% The AMT-13 cruise is included as an example, but of course in principle
% any dataset will do. 

% John R. Casey
% 20210221

%% Change directory
% change this path to where you have MSE installed
rootPath = '/Users/jrcasey/Documents/MATLAB/GitHub/MSE_EqPac';
cd(rootPath)
% make sure the toolbox is in Matlab's path
addpath(genpath(rootPath));

%% Version
version = strcat({'_v'},datestr(date,'yyyymmdd'))

%% Version control and paths (save a copy of this to the server)
% These files are required to run MSE

FileNames = struct;
% Current PanGEM
FileNames.PanGEM_Path = 'data/GEM/PanGEM.mat';
% Organism database
FileNames.orgDB_Path = 'data/db/orgDatabase.csv';
% Current strain models
FileNames.StrMod_Path = 'data/GEM/StrMod.mat';
% List of strains to be analyzed
FileNames.strainList_Path = 'data/db/strainList.mat';
% Current OGTDat
FileNames.OGTDat_Path = 'data/db/OGTDat.csv';
% Cruise data
FileNames.CruiseDB_filename = 'data/envData/EqPac_tt011_Gridded.csv';
% HyperPro profiles
FileNames.IrrDat_fileName = 'data/envData/IrrDat.mat';
% TpDat path
FileNames.TpDat_fileName = 'data/db/TpDat.csv';
% PhysOpt and PigOpt constraints path
FileNames.PhysOptPigOptConstraints_fileName = 'data/db/BOFConstraints.csv';
% PigDB path
FileNames.PigDB_fileName = 'data/db/AbsorptionDatabase.csv';
% Destination for solution
FileNames.destination_fileName = strcat('nobackups/jrcasey/Solution',version,'.mat');

%% Save and output options

Options = struct;
Options.saveSolution = false;
Options.saveStrMod = false;

%% Optimization solver options

Options.maxIter_TpOpt = 1000; % maximum iterations for TpOpt algorithm
Options.maxIter_physOpt = 1000; % maximum iterations for PhysOpt algorithm
Options.stepTol_TpOpt = 1e-8; % step tolerance for TpOpt algorithm

%% Other options

Options.fmax = 0.085; % maximum coverage of cell surface area by transporters (proportion; see Casey and Follows, 2020 Plos CompBio)

%% Gridding (save a copy of this to the server)

Gridding = struct;
% Stations to include in batch run
Gridding.stationsVec =[1:15]; % station names
Gridding.stationsVec2 = [1:15]; % corresponding station indices (in CruiseData)
Gridding.nStations = numel(Gridding.stationsVec);
% Depth (m)
Gridding.minZ = 10; % minimum depth
Gridding.maxZ = 200; % maximum depth
Gridding.intervalZ = 10; % depth interval
Gridding.depthVec = Gridding.minZ:Gridding.intervalZ:Gridding.maxZ;
Gridding.nZ = numel(Gridding.depthVec);
% Wavelength (nm)
Gridding.minLambda = 400; % minimum wavelength (nm)
Gridding.maxLambda = 686; % maximum wavelength (nm)
Gridding.bandwidth = 2; % bandwidth (nm)
Gridding.lambdaVec = Gridding.minLambda:Gridding.bandwidth:Gridding.maxLambda; % nm wavelength

% Get strains to analyze
load(FileNames.strainList_Path);
Gridding.strNameVec = strList;
Gridding.nStr = numel(Gridding.strNameVec);

%% Import environmental data

% Some notes:
% - nutrient concentrations should be in nM
% - temperature is in degrees C
% - Spectral downwelling irradiance should be in W m-2 (nm bandwidth)-1

%% Import Cruise Data
% Load and format nutrient concentrations, temperature, and other cruise
% variables

CruiseDB = readtable(FileNames.CruiseDB_filename,'Delimiter',',','ReadVariableNames',true);
CruiseData = getCruiseData(CruiseDB,Gridding.depthVec);

%% Import spectral irradiance
% load and format HyperPro profiles
load(FileNames.IrrDat_fileName);
[IrrDat2] = standardizeIrr(IrrDat,Gridding.lambdaVec,Gridding.depthVec); %mmoles photons m-2 h-1 bandwidth*nm-1
IrrDat3 = reshape([IrrDat2{:}],numel(Gridding.depthVec),numel(Gridding.lambdaVec),numel(IrrDat2));
CruiseData.IrrDat = IrrDat3;
CruiseData.PAR = squeeze(nansum(IrrDat3,2))'; % mmol photons m-2 h-1
CruiseData.PAR2 = IrrDat.PAR(Gridding.depthVec,Gridding.stationsVec); % mumol 

%% Parse strain models and save to data/GEM/StrMod/ folder

load(FileNames.StrMod_Path);
for a = 1:Gridding.nStr
    strName = Gridding.strNameVec{a};
    mod = StrMod.(strName);
    mod.id = strName;
    save(strcat('data/GEM/StrMod/',strName,'.mat'),'mod');
end

%% Save to output folder

save('data/output/Gridding.mat','Gridding');
save('data/output/FileNames.mat','FileNames');
save('data/output/Options.mat','Options');
save('data/output/CruiseData.mat','CruiseData');



