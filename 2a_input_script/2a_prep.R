# Script to prepare inputs for HGAC VERSPM VisionEval model
# This prepares inputs for Scenario 2a, where the number of dwelling units is altered to reflect changes in employment growth in selected employment centers


input <- read.csv('bzone_dwelling_units_2045.csv')
base <- read.csv('../models/HGAC-RSPM-TAZ/inputs/bzone_dwelling_units.csv')
base <- base[base$Year==2019,]

# which bzones get increased? 
increase_file <- read.csv('Bzone1aGalReloTAZs.csv')
decrease_file <- read.csv('GalvestonIsland1aDwellingUnits.csv')
taz_groupings <- read.csv('TOE_TAZ-BZONE.csv')
decrease_factor= 0.05

increase_list <- increase_file$NewTAZ_ID
decrease_list <- decrease_file$NewTAZ_ID

# identify Bzones in which to decrease dwelling units
# apply decrease factor to determine total change in Bzones with decrease dwelling units

decrease_rows <- input$Geo %in% decrease_list
changes <- lapply(input[decrease_rows,c("SFDU","MFDU","GQDU")],function(x) decrease_factor*sum(x))

total_change_sf = changes$SFDU
total_change_mf = changes$MFDU
total_change_gq = changes$GQDU

increase_rows <- input$Geo %in% increase_list
initial <- lapply(input[increase_rows,c("SFDU","MFDU","GQDU")],sum)

increase_factor <- mapply(function(change,initial) change/initial, changes, initial)

increase_factor[increase_factor == Inf] = 0 # Replace any Inf with zero in the increase factor
# increase_factor is then a list with elements c("SFDU","MFDU","GQDU") each of which is the corresponding factor
increase_factor <- as.data.frame(t(increase_factor))

# Changing dwelling units in increase_rows and decrease_rows vectors

input$SFDU[increase_rows] <- (1-increase_factor$SFDU)*input$SFDU[increase_rows]
input$MFDU[increase_rows] <- (1-increase_factor$MFDU)*input$MFDU[increase_rows]
input$GQDU[increase_rows] <- (1-increase_factor$GQDU)*input$GQDU[increase_rows]

input$SFDU[decrease_rows] <- (1-decrease_factor)*input$SFDU[decrease_rows]
input$MFDU[decrease_rows] <- (1-decrease_factor)*input$MFDU[decrease_rows]
input$GQDU[decrease_rows] <- (1-decrease_factor)*input$GQDU[decrease_rows]

input$Bzone <- taz_groupings$Bzone

#aggregates input into dataframe
final <- aggregate(input[,c("Year","SFDU","MFDU","GQDU")],by=list(Geo=taz_groupings$Bzone),sum)

#Adding 3 sfdu to rows with 0 units
final$SFDU[final$SFDU==0 & final$MFDU==0 & final$GQDU==0] <- 3


#adds 2019 rows
final <- rbind(base[base$Year==2019,],final)

#deleting 3 excess bzones
final <- final[!(final$Geo %in% c(4911, 5151, 5168)),]

#checks dimensions
setdiff(final$Geo, base$Geo)
setdiff(base$Geo, final$Geo)

#prints output: run to view dataframe before exporting
print(final)

#   NOTE: final will have columns c("Geo","Year","SFDU","MFDU","GQDU"), and the "Geo" rows will be Bzones...

# NOTE: final$Geo is now an R factor, but we can change it back like this
#   final$Geo <- as.character(final$Geo)
# We don't need to do that if we're just writing it to .csv (as.character is the default column processing)

#exports final output to csv file
if(!dir.exists('1a')) { dir.create('1a') }
write.csv(final, "1a/bzone_dwelling_units.csv", row.names=FALSE)
