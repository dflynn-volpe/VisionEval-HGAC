# Try out running HGAC scenarios

tract_scenario_mod <- openModel('HGAC-RSPM-Tract')
tract_scenario_mod$results()

start_time <- Sys.time()

tract_scenario_mod$run()

end_time <- Sys.time() - start_time
print(paste(round(end_time, 2), attr(end_time, 'units'), 'to complete H-GAC tract-level scenarios'))