# R script to build quick queries
  #-------------------------------------------------
  #Two series of Queries by Bzone on Household Table
  # sum:
  #   'Dvmt'
  #   'WalkTrips'
  #   'BikeTrips'
  #   'TransitTrips'
  #   'VehicleTrips'
  #   'DailyCO2e'
  #   'DailyKWH'
  #   'DailyGGE'
  # mean:
  #   'Income'
  #   'HhSize'
  #   'Vehicles'
  #   'AveVehTripLen'
  #-------------------------------------------------

# 1. Create a single query manually to illustrate the structure
# 2. Build the sum queries using quick query
# 3. Build the mean queries using quick query
# 4. Save the resulting query

sum_metrics = c('Dvmt', 'WalkTrips', 'BikeTrips', 'TransitTrips', 'VehicleTrips',
                'DailyCO2e', 'DailyKWH', 'DailyGGE')

ave_metrics = c('Income', 'HhSize', 'Vehicles', 'AveVehTripLen')

# Here's how to set these up by hand in a .veqry list format:
QuerySpec <- list(
  # Sum query
      list(
      Name = "Dvmt",
      Summarize = list(
        Expr = "sum(Dvmt)",
        Units = c(
          Dvmt = "MI/DAY"
        ),
        Table = "Household"
      ),
      By = "Bzone",
      Units = "Miles per day",
      Description = "Total household daily vehicle miles traveled by Bzone"
    ),
  # Mean query
    list(
      Name = "Income",
      Summarize = list(
        Expr = "mean(Income)",
        Units = c(
          Dvmt = "USD",
          Marea = ""
        ),
        By = "Bzone",
        Table = "Household"
      ),
      Units = "USD",
      Description = "Average Household Income by Bzone"
    )
)
sampleQuery <- VEQuery$new(QueryName="Base-Bzone-Query",QuerySpec=QuerySpec)
# qry$save() # with no attached model, goes into VE_RUNTIME/queries under name "HGAC-Bzone.veqry"

# From there, it can be applied to any model as in the following function. Note that running
# query$quickSpec requires a model to be attached so we can verify that the requested fields are
# actually there. (It's always better to force a compile error rather than a runtime error.)

buildBzoneQuery <- function(Model=NULL,Query=NULL,QueryName="BzoneQuery") {
  # TODO: verify that these constructions will overwrite any previous BZone query
  if ( is.null(Model) || ! inherits(Model,"VEModel") ) {
    stop("Must provide VEModel to build and run the Query")
  }
  message("Before building:")
  if ( is.null(Query) || ! inherits(qry,"VEQuery") ) {
    message("No query provided: constructing from scratch")
    qry <- VEQuery$new(Model=Model,QueryName=QueryName)
    startIndex <- 1
  } else {
    startIndex <- 2 # presume we're using sample query from earlier
    qry <- VEQuery$new(Model=Model,QueryName=QueryName,OtherQuery=Query)
  }
  for ( index in startIndex:length(sum_metrics) ) {
    qry$quickSpec(Table="Household",Field=sum_metrics[index],Geography="Bzone",FUN="sum")
  }
  for ( index in startIndex:length(ave_metrics) ) {
    qry$quickSpec(Table="Household",Field=ave_metrics[index],Geography="Bzone",FUN="mean")
  }
  qry$save() # save it to the Model
  message("After building:")
  print(qry)
  return(qry)
}

# Run the query (adjust the Model parameter as needed to point at the model to query)
runBzoneQuery <- function(ModelName="HGAC-Scenarios",Query=NULL,QueryName=NULL,Rebuild=TRUE) {
  # Use Query=sampleQuery to start from pre-built query; otherwise all the metrics will be built
  # That's an easy way to add these sum/average elements to any existing query that doesn't have
  # them already. The name of then newly built query will be "BzoneQuery" (disambiguated) unless
  # QueryName is also provided. If QueryName is explicitly NULL, use the name of Query.
  HGAC_Model <- openModel(ModelName) # Needs to have been run with some results!
  if ( ! inherits(HGAC_Model,"VEModel") ) stop("Must provide a valid Model to query")
  if ( ! missing(QueryName) ) {
    qry <- buildBzoneQuery(Model=HGAC_Model,Query=Query,QueryName=QueryName)
  } else {
    if ( Rebuild ) {
      qry <- buildBzoneQuery(Model=HGAC_Model,Query=Query) # Use function default "BzoneQuery" as name
    } else {
      qry <- Query # Don't build anything - in which case this function is just a "query runner"
      qry$model(Model) # set Model in case the passed Query started out attached to a different model
    }
  }
  qry$run(Force=TRUE) # Always re-run the full query (will do all reportable scenarios)
  qry$export(longScenarios=FALSE,format="csv")
  return(qry)
}

stop("Nothing wrong - just heading off streamlined sample code")

# To use the above functions:
qry <- runBzoneQuery(Model="My-HGAC")

# To pivot off the sample query:
qry <- runBzoneQuery(Model="My-HGAC",Query=sampleQuery)

# To build and run the query in the simplest possible way without the functions, do the following.
# This short snipped essentially reproduces the original script using the VE query mechanism

mod <- openModel("My-HGAC")
qry <- VEQuery$new(Model=mod,QueryName="BZone-Query")
for ( index in 1:length(sum_metrics) ) {
  # note that FUN="sum" is the default if you don't specify it
  qry$quickSpec(Table="Household",Field=sum_metrics[index],Geography="Bzone",FUN="sum")
}
for ( index in 1:length(ave_metrics) ) {
  qry$quickSpec(Table="Household",Field=ave_metrics[index],Geography="Bzone",FUN="mean")
}
qry$save()          # optional; may overwrite query with the same name
qry$run(Force=TRUE) # in case there was a previously-run query with the exact same name, or if the
                    # scenarios have changed.
qry$export()        # does wide format by default (single table, rows=metrics, columns=scenarios+metadata)