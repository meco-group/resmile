gre% Example for a dataset for which `fit_resmile` is not more efficient than
% the `fit_regsimple`. Both of them lead to removing the same knots.

rsm=Resmile(load('dsrand_noisyw2'));

figure('Name','fit_regsimple results')
rsm.fit_regsimple
rsm.simplify
rsm.analyze
rsm.plot(Resmile.PL_TABS_SPLINES)

figure('Name','fit_resmile results')
rsm.fit_resmile
rsm.simplify
rsm.analyze
rsm.plot(Resmile.PL_TABS_SPLINES)
