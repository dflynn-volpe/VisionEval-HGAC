# Try out running HGAC scenarios
library(tidyverse) # install.packages('tidyverse')

taz_scenario_mod <- openModel('HGAC-RSPM-TAZ')

taz_scenario_mod$results()


# This step can take several hours -- only run when ready!
start_time <- Sys.time()

taz_scenario_mod$run()

end_time <- Sys.time() - start_time
print(paste(round(end_time, 2), attr(end_time, 'units'), 'to complete H-GAC taz-level scenarios'))

## Extract HGAC results
# Start here to extract completed results
taz_scenario_mod <- openModel('HGAC-RSPM-TAZ')

print(taz_scenario_mod$query())

# Open the query and run it on the scenario results
qry <- taz_scenario_mod$query("Full-Query") # open the query

qry$run() # do the query on mod.scenarios model

qry$export()

# Manual extract for Bzones
results <- taz_scenario_mod$results()

print(results)

# This step outputs *All* tables from the results to .csv files
# This is a long process and will generate several Gb of outputs!
results$extract(saveResults=TRUE)   # if not saveResults, return a list of data.frames, invisibly

# Manually then deleted Vehicle and Worker files, which are very large, and delted 2019 outputs from various scenarios

# Compile household metrics ----
# For each sceanrio, go into the results > <scenario> > output / Extract_date folders
# find Household file for 2019 or 2045, and sum up following metrics by Bzone:
# - DVMT
# - Count of households
# - WalkTrips
# - BikeTrips
# - TransitTrips
# - VehicleTrips
# - DailyCO2e
# - Daily KWH
# - DailyGGE

# Also, average the following
# - Income
# - HhSize
# - Vehicles
# - AveVehTripLen

base = 'stage-pop-base'
scenarios = c('stage-pop-future',
              '1a', '1b', '1c',
              '2a', '2b', '2c',
              '3', '4a', '4b')

sum_metrics = c('Dvmt', 'WalkTrips', 'BikeTrips', 'TransitTrips', 'VehicleTrips',
                'DailyCO2e', 'DailyKWH', 'DailyGGE')

ave_metrics = c('Income', 'HhSize', 'Vehicles', 'AveVehTripLen')

summarize_bzone <- function(model_name, scen_name, sum_metrics, ave_metrics){
  # model_name = taz_scenario_mod; scen_name = 'stage-pop-base'
  
  extract_path = file.path(model_name$modelResults, scen_name, 'output')
  extract_name = sort(dir(extract_path))[1] # take only latest
  extract_files = dir(file.path(extract_path, extract_name))
  hh_file = extract_files[grep('Household_\\d{4}-\\d{2}-\\d{2}_\\d{2}-\\d{2}-\\d{2}.csv$', extract_files)]
  # Read in hh_file
  hh_x <- readr::read_csv(file.path(extract_path, extract_name, hh_file))
  
  sum_x <- hh_x %>% group_by(Bzone) %>%
    summarize(across(sum_metrics, sum),
              Count = n())
  
  mean_x <- hh_x %>% group_by(Bzone) %>%
    summarize(across(ave_metrics, mean))
  
  bzone_summary = sum_x %>% left_join(mean_x) %>% mutate(scenario = scen_name)
  bzone_summary
}

compiled = vector()

compiled = rbind(compiled, summarize_bzone(taz_scenario_mod, base, sum_metrics, ave_metrics))

for(scen in scenarios){
  cat('Processing scenario', scen, '\n\n')
  compiled = rbind(compiled, summarize_bzone(taz_scenario_mod, scen, sum_metrics, ave_metrics))
}

write_csv(compiled, file.path(taz_scenario_mod$modelResults, 'Compiled_Household_Metrics_Bzone.csv'))

# Query version ----
# To fix -- these don't work currently

# 
# 
# qry <- taz_scenario_mod$query("Bzone-Query") # open the query
# qry$run() # do the query on mod.scenarios model
# 
# qry$export()
# 
# 
# qry <- taz_scenario_mod$query("Bzone-Query-Short") # open the query
# qry$run() # do the query on mod.scenarios model
# 
# qry$export()
