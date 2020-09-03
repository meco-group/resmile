barvalues_test
rsm = Resmile(Resmile.dataset_chooser_gui);
rsm.make_basis(input_data, Resmile.KNOTS_ACCURATELY);
rsm.phi_plotting_after_n_iterations = 1;
rsm.fit_resmile
rsm.plot(Resmile.PL_TABS_FRF)
disp("<press any key>"), pause 
rsm.plot(Resmile.PL_TABS_FRFERR)
disp("<press any key>"), pause
rsm.plot(Resmile.PL_TABS_SPLINES)
rsm.simplified_model
