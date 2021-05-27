%% Post processing on local machine for EqPac cruise
% 1. After SLURM batch finishes, zip the results on the remote server by executing:
% zip -r All_Solutions.zip /nobackup1/jrcasey/
% 2. Then in a new terminal, copy the remote file All_Solutions.zip to a local
% directory:
% scp -i /Users/jrcasey/eofe-cluster/linux/eofe-key jrcasey@eofe7.mit.edu:~/mse_EqPac/All_Solutions.zip ~/Documents/MATLAB/CBIOMES/Data/Environmental_Data/Cruises/EqPac/
% 3. Unzip the file and rename the containing folder 'Solution_YYYYMMDD'
% 4. Point to that directory here and run get_EqPac_Results_server.m. If you
% get an error, go into the function and save the missing indices in a file
% called 'missingFileNo.mat' which can be passed to mse.m. The
% missing files can be run by editing Job_loop.sh (just change the batch
% parameters to match the length of missingFileNo). If this was done,
% you'll need to repeat the above steps with the complete set of results
% again. This time, it should work. 

% just in case you're not already there...
cd /Users/jrcasey/Documents/MATLAB/GitHub/mse_EqPac/
addpath(genpath('/Users/jrcasey/Documents/MATLAB/GitHub/mse_EqPac/'))

% Point to solutions directory
ResultsDirectory = '/Users/jrcasey/Documents/MATLAB/CBIOMES/Data/Environmental_Data/Cruises/EqPac/Solution_20210526/';

% load specifics about the run
load('data/output/Gridding.mat');
load('data/output/FileNames.mat');
load('data/output/CruiseData.mat');
load('data/GEM/PanGEM.mat');

% Compile results (takes about 20 minutes)
[FullSolution_L1] = get_EqPac_Results_server(ResultsDirectory,PanGEM,FileNames,Gridding,CruiseData);

% Save compiled results locally. 
%%%%%%%%%%%%%%%%%%% 
% IMPORTANT: DO NOT COMMIT FullSolution_L1.mat or FullSolution_L2.mat or you will
% overrun the github file size limit and fuck everything up royally.
%%%%%%%%%%%%%%%%%%% 

save('/Users/jrcasey/Documents/MATLAB/GitHub/mse_EqPac/data/output/FullSolution_L1.mat','FullSolution_L1');