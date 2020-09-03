% Complete GUI example that allows you to choose one of the predefined datasets and plot the results
rsm = Resmile(Resmile.dataset_chooser_gui)
if strcmp(questdlg("Make state-space models coherent?","","Yes","No",""),"Yes") %Choose `Yes` for crane model
    rsm.make_coherent
end
rsm.fit_resmile
rsm.simplify
rsm.analyze
rsm.plot_chooser_gui
rsm.spline_remover_info