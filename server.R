## server.R ##
library(leaflet)



shinyServer(function(input, output) { 

  source("db_connect.R") # returns nofa_db_dplyr db connection
  
  #----------------------------------------------------------------------------
  #lookup-tables
  #----------------------------------------------------------------------------
  lookupTableInput <- reactive({
    switch(input$lookuptables,
           "l_organismQuantityType" = l_organismQuantityType,
           "l_sampleSizeUnit" = l_sampleSizeUnit,
           "l_taxon" = l_taxon,
           "l_establishmentMeans" = l_establishmentMeans,
           "l_spawningCondition" = l_spawningCondition,
           "l_reliability" = l_reliability,
           "l_samplingProtocol" = l_samplingProtocol)
  })
  
   output$lookuptables_view <- DT::renderDataTable(
    DT::datatable(
      lookupTableInput()
    )
   )

  
  # output$lookuptables_view <- renderTable({
  #   lookupTableInput()
  # })
  
  output$downloadData <- downloadHandler(
    filename = function() { 
      paste(input$lookuptables, '.csv', sep='') 
    },
    content = function(file) {
      write.csv(lookupTableInput(), file)
    }
  )
  
  # location map ----------------------------------------------------------------
  # download locations, including lat,long coords from db and display as leaflet with popups
  # due to slow rendering time of leaflet, select one municipality pr view. 

    # create map from db download
    output$locations <- renderLeaflet({
    locations_tbl <- tbl(nofa_db_dplyr,"lake")
    MunicipalityID_inn <- as.integer(input$municipalityIDinn)
    # next lines depricated - run raw sql instad so that searching on arrays are enabled
    #MunicipalityID_selected <- paste("{",MunicipalityID_inn,"}",sep="")#input$locationID)
    #locations_temp <- select(locations_tbl,decimalLatitude,decimalLongitude,id,nationalWaterBodyID,waterbody,municipalityIDs) %>% filter(municipalityIDs==MunicipalityID_selected)
    locations_temp <- tbl(nofa_db_dplyr,
                     sql(paste("SELECT id, \"decimalLatitude\", \"decimalLongitude\", \"nationalWaterBodyID\", \"waterbody\",\"municipalityIDs\" FROM nofa_new.lake WHERE", MunicipalityID_inn,"=any(\"municipalityIDs\")")))
    locations <- as.data.frame(locations_temp) # create in-memory object from db connection
    
    waterbodyPopup_popup <- paste0("<strong>locationID: </strong>", 
                                   locations$id, 
                                   "<br><strong>WaterbodyID: </strong>", 
                                   locations$nationalWaterBodyID, 
                                   "<br><strong>waterbody:</strong>", 
                                   locations$waterbody)
    # note: leaflet backround (providerTiles) are drawn from input dropdown menu
    leaflet(locations) %>% addProviderTiles(input$locaitonIDmap_mapbackground) %>% 
      addMarkers(lng = ~decimalLongitude, lat = ~decimalLatitude,
                 clusterOptions = markerClusterOptions(),popup=waterbodyPopup_popup)
    
  })
    
  # loactionIDmatch -------------------------------------------------------------
  # takes innput csv file with waterbodyID (nve) and returns NOFA locationID 
  
  # match data by quering databaswe and return reactive object "match_location_data" 
  match_location_data <- reactive({
    inFile <- input$locationID_file
    
    if (is.null(inFile))
      return(NULL)
    
    temp <- read.csv(inFile$datapath)
    
    temp$nationalWaterBodyID <- as.character(paste("{NO_",temp$watebodyID,"}",sep=""))
    dim2_temp <- length(names(temp))
    temp_inn <- select(temp,nationalWaterBodyID)
    waterbody_temp <- tbl(nofa_db_dplyr,"lake")
    what_waterbody_temp <- select(waterbody_temp,id,nationalWaterBodyID,waterbody) %>% rename(locationID=id)
    temp_out <- left_join(temp_inn,what_waterbody_temp,by="nationalWaterBodyID",copy=T)
    temp_out <- left_join(temp,temp_out,by="nationalWaterBodyID")  %>%
      select(locationID,nationalWaterBodyID,waterbody,1:dim2_temp)
    return(temp_out)
  })
  
  # Creates output table to be displayed by calling reactive function
  output$match_location <- renderTable({
    match_location_table <- match_location_data()
    return(match_location_table)
  })
  
  # create download object from reactive object
  output$download_match_location_data <- downloadHandler(
    filename = function() { paste(input$locationID_file,"_matched_with_NOFA_locationID_",Sys.Date(), ".csv", sep="") },
    content = function(file) {
      write.csv(match_location_data(), file)
    }
  )

    # end of server function    
    on.exit(rm(nofa_db_dplyr))
    on.exit(gc())  

  }
)    
    
    
