# Script to prepare inputs for HGAC VERSPM VisionEval model
# This prepares inputs for Scenario 12a, where the number of employment is in Environmental Justice-sensitive bzones increases by 15%.

input <- read.csv('./models/HGAC-RSPM-TAZ/inputs/bzone_employment.csv')
base <- input[input$Year==2019,]
input <- input[input$Year==2045,]
change_file <- read.csv('./12a_input_script/TAZ5717_EJ_2019ACS.csv')
taz_groupings <- read.csv('./12a_input_script/TOE_TAZ-BZONE.csv')

ej_list <- change_file$NewTAZ_ID

# Changing employment data 

input[input$Geo %in% ej_list,]$TotEmp   <- round(1.15*input[input$Geo %in% ej_list,]$TotEmp )
input[input$Geo %in% ej_list,]$RetEmp  <- round(1.15*input[input$Geo %in% ej_list,]$RetEmp)
input[input$Geo %in% ej_list,]$SvcEmp  <- round(1.15*input[input$Geo %in% ej_list,]$SvcEmp)


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
if(!dir.exists('completed inputs/12b')) { dir.create('completed inputs/12b') }
write.csv(final, "completed inputs/12b/bzone_employment.csv", row.names=FALSE)
