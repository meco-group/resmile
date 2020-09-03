% This script corresponds to the paper:
% A. Retzler; J. Swevers; J. Gillis; Zs. Kollar, "ReSMILE: trading off model 
% accuracy and complexity for linear parameter-varying systems", 
% Proceedings of ISMA2020 and USD2020, Leuven, 2020
% 
% How to use:
% First set up the toolbox based on the instructions in README.md, then run
% this script step by step (Ctrl+Enter runs the section under the cursor). 
clear all

%% 1) SMILE
% crane dataset
% knots at data points (default KNOTS_ACCURATELY)
% 8 data points, 8 knots, 9 coefficients -> overfitting observable
rsm = Resmile(Resmile.dataset_oc);
rsm.make_coherent
rsm.fit_ls
rsm.analyze
rsm.plot(Resmile.PL_TABS_SPLINES)

%% 2) SMILE
% crane dataset
% one less knot (KNOTS_IN_MIDDLE) to eliminate overfitting
% 8 data points, 7 knots, 8 coefficients -> no overfitting observable
rsm = Resmile(Resmile.dataset_oc);
rsm.make_coherent
rsm.knots_distribute_mode = Resmile.KNOTS_IN_MIDDLE; 
rsm.fit_ls
rsm.analyze
rsm.plot(Resmile.PL_TABS_SPLINES)

%% 3) Regularized SMILE
% crane dataset
% regularization, but no reweighting
% knots at data points (default KNOTS_ACCURATELY) from now on 
rsm = Resmile(Resmile.dataset_oc);
rsm.make_coherent
rsm.fit_regsimple
rsm.simplify
rsm.analyze
rsm.plot(Resmile.PL_TABS_SPLINES)

%% 4) Regularized SMILE 
% prepared random dataset dsrand_noisyw1
% regularization, but no reweighting
rsm = Resmile(load('dsrand_noisyw1'));
rsm.fit_regsimple
rsm.simplify
rsm.analyze
rsm.plot(Resmile.PL_TABS_SPLINES)

%% 5) Regularized, reweighted SMILE = ReSMILE
% prepared random dataset dsrand_noisyw1
% knot #22 and #24 not removed
rsm = Resmile(load('dsrand_noisyw1'));
rsm.fit_resmile
rsm.simplify
rsm.analyze
rsm.plot(Resmile.PL_TABS_SPLINES)

%% 6) Regularized, reweighted SMILE = ReSMILE
% crane dataset
% plot splines
rsm = Resmile(Resmile.dataset_oc);
rsm.make_coherent
rsm.fit_resmile
rsm.simplify
rsm.analyze
rsm.plot(Resmile.PL_TABS_SPLINES)

%% 7) plot FRFs
rsm.plot(Resmile.PL_TABS_FRF)

%% 8) show splines_remover_info
% Get to know which splines where not taken into account in the objective,
% and had a constraint in the simplify step.
rsm.spline_remover_info
