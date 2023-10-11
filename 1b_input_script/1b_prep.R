# Script to prepare inputs for HGAC VERSPM VisionEval model
# This prepares inputs for Scenario 1b, where data is altered to reflect increased employment in Conroe, Sugar Land, and Rosenberg

input <- read.csv('./1b_input_script/bzone_employment.csv')
base <- input[input$Year==2019,]
input <- input[input$Year==2045,]
change_file <- read.csv('./1b_input_script/bzone-employment_new_ctrs.csv')
#taz_groupings <- read.csv('TOE_TAZ-BZONE.csv')

sugarland_list <- change_file[change_file$Emp_Ctr=='Sugar Land',]$NewTAZ_ID_
rosenberg_list <- change_file[change_file$Emp_Ctr=='Rosenberg',]$NewTAZ_ID_
conroe_list <- change_file[change_file$Emp_Ctr=='Conroe',]$NewTAZ_ID_

# Changing employment data 

input[input$Geo %in% sugarland_list,]$TotEmp <- round(1.05*input[input$Geo %in% sugarland_list,]$TotEmp)
input[input$Geo %in% sugarland_list,]$RetEmp <- round(1.05*input[input$Geo %in% sugarland_list,]$RetEmp)
input[input$Geo %in% sugarland_list,]$SvcEmp <- round(1.05*input[input$Geo %in% sugarland_list,]$SvcEmp)
input[input$Geo %in% rosenberg_list,]$TotEmp <- round(1.15*input[input$Geo %in% rosenberg_list,]$TotEmp)
input[input$Geo %in% rosenberg_list,]$RetEmp <- round(1.15*input[input$Geo %in% rosenberg_list,]$RetEmp)
input[input$Geo %in% rosenberg_list,]$SvcEmp <- round(1.15*input[input$Geo %in% rosenberg_list,]$SvcEmp)
input[input$Geo %in% conroe_list,]$TotEmp <- round(1.15*input[input$Geo %in% conroe_list,]$TotEmp)
input[input$Geo %in% conroe_list,]$RetEmp <- round(1.15*input[input$Geo %in% conroe_list,]$RetEmp)
input[input$Geo %in% conroe_list,]$SvcEmp <- round(1.15*input[input$Geo %in% conroe_list,]$SvcEmp)

input$TotEmp <- round(input$TotEmp)
input$RetEmp <- round(input$RetEmp)
input$SvcEmp <- round(input$SvcEmp)

#input$Bzone <- taz_groupings$Bzone

#aggregates input into dataframe
#final <- aggregate(input[,c("Year","TotEmp","RetEmp","SvcEmp")],by=list(Geo=taz_groupings$Bzone),sum)


#adds 2019 rows
final <- rbind(base, input)

#prints output: run to view dataframe before exporting
print(final)

#   NOTE: final will have columns c("Geo","Year","TotEmp","RetEmp","SvcEmp"), and the "Geo" rows will be Bzones...

# NOTE: final$Geo is now an R factor, but we can change it back like this
#   final$Geo <- as.character(final$Geo)
# We don't need to do that if we're just writing it to .csv (as.character is the default column processing)

#exports final output to csv file
if(!dir.exists('completed inputs/1b')) { dir.create('completed inputs/1b') }
write.csv(final, "completed inputs/1b/bzone_employment.csv", row.names=FALSE)
