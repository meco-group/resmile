% This is an example on using LC Toolbox objects as input to and output of Resmile.

%% Load the crane data into a GridMod object 
fs = 100; %sampling rate
lengths = sort([0.8  0.5918  0.5  0.4587  0.4084  0.3660  0.3298  0.2988  0.25]); %scheduling parameter values corresponding to each model
load crane_L025.mat   
Gparam_ss{1} = fromstd(ssModh);
load crane_L02988.mat
Gparam_ss{2} = fromstd(ssModh);
load crane_L03298.mat   
Gparam_ss{3} = fromstd(ssModh);
load crane_L03660.mat
Gparam_ss{4} = fromstd(ssModh);
load crane_L04084.mat   
Gparam_ss{5} = fromstd(ssModh);
load crane_L04587.mat
Gparam_ss{6} = fromstd(ssModh);
load crane_L05.mat   
Gparam_ss{7} = fromstd(ssModh);
load crane_L05918.mat
Gparam_ss{8} = fromstd(ssModh);
load crane_L08.mat
Gparam_ss{9} = fromstd(ssModh);
clear FRFarray stdArray weightsArray ssModh ssModq stdAng Wang FRFang

range = [0.25, 0.8]; %the range of the scheduling parameter
rate = [-0.12,0.1]; %this is the rate of variation of the sched. parameter (needed for control design) 
scheduling_parameter = SchedulingParameter('l',range,rate);

schGrid = {'l',lengths};
g = Gridmod(Gparam_ss, schGrid);

%% Run the ReSMILE on the data
rsm = Resmile(g);
rsm.make_coherent
rsm.fit_resmile
rsm.simplify
rsm.input_data.bode_frequencies = [logspace(log10(0.03),log10(2.9),20) linspace(3.5,5,20)];
rsm.analyze
rsm.plot(Resmile.PL_TABS_SPLINES)

%% Get the output LPVDSSmod (for control design)
result = rsm.simplified_ssmod(scheduling_parameter)
