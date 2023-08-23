input <- read.csv('bzone_dwelling_units_2045.csv')
increase_file <- read.csv('Bzone1aGalReloTAZs.csv')
decrease_file <- read.csv('GalvestonIsland1aDwellingUnits.csv')
taz_groupings <- read.csv('TOE_TAZ-BZONE.csv')
decrease_factor=.2

increase_list<-increase_file$NewTAZ_ID
decrease_list<-decrease_file$NewTAZ_ID

# identify Bzones in which to decrease dwelling units
# apply decrease factor to determine total change in Bzones with decrease dwelling units

decrease_rows <- input$Geo %in% decrease_list
changes <- lapply(input[decrease_rows,c("SFDU","MFDU","GQDU")],function(x) decrease_factor*sum(x))

total_change_sf=changes$SFDU
total_change_mf=changes$MFDU
total_change_gq=changes$GQDU

increase_rows <- input$Geo %in% increase_list
initial <- lapply(input[increase_rows,c("SFDU","MFDU","GQDU")],sum)

increase_factor <- mapply(function(change,initial) change/initial, changes, initial)

increase_factor[increase_factor == Inf] = 0 # Replace any Inf with zero in the increase factor
# increase_factor is then a list with elements c("SFDU","MFDU","GQDU") each of which is the corresponding factor
increase_factor <- as.data.frame(t(increase_factor))
# Changing dwelling units in increase_rows and decrease_rows lists
print(increase_factor)
print(input)
input$SFDU[increase_rows] <- (1-increase_factor$SFDU)*input$SFDU[increase_rows]
input$MFDU[increase_rows] <- (1-increase_factor$MFDU)*input$MFDU[increase_rows]
input$GQDU[increase_rows] <- (1-increase_factor$GQDU)*input$GQDU[increase_rows]

input$SFDU[decrease_rows] <- (1-decrease_factor)*input$SFDU[decrease_rows]
input$MFDU[decrease_rows] <- (1-decrease_factor)*input$MFDU[decrease_rows]
input$GQDU[decrease_rows] <- (1-decrease_factor)*input$GQDU[decrease_rows]

input$Bzone <- taz_groupings$Bzone

#aggregates input into dataframe
final <- aggregate(input[,c("SFDU","MFDU","GQDU")],by=list(Geo=taz_groupings$Bzone),sum)

#Adding 3 sfdu to rows with 0 units
zero_rows <- input[sum(input$SFDU+input$MFDU+input$GQDU)==0]$Bzone
final$SFDU[zero_rows] <- 3

#prints output: run to view dataframe before exporting
print(final)

#   NOTE: final will have columns c("Geo","SFDU","MFDU","GQDU"), and the "Geo" rows will be Bzones...

# NOTE: final$Geo is now an R factor, but we can change it back like this
#   final$Geo <- as.character(final$Geo)
# We don't need to do that if we're just writing it to .csv (as.character is the default column processing)

#exports final output to csv file
write.csv(final, "1a_bzone_dwelling_units.csv", row.names=FALSE)
