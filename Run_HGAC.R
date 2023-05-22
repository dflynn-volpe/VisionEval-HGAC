# Try out running HGAC scenarios

taz_scenario_mod <- openModel('HGAC-RSPM-TAZ')
taz_scenario_mod <- openModel('HGAC-RSPM-TAZ_BaseOnly')

taz_scenario_mod$results()

start_time <- Sys.time()

taz_scenario_mod$run()

end_time <- Sys.time() - start_time
print(paste(round(end_time, 2), attr(end_time, 'units'), 'to complete H-GAC taz-level scenarios'))