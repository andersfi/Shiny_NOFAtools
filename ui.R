## ui.R ##
library(shinydashboard)
library(markdown)
library(leaflet)

# load external data (could probably be more elegantly handeld in dplyr, as in server.R)
source("dataIO_nofa_db.R")

dashboardPage(
  
  # dashboard header
  dashboardHeader(title = "NOFA"),
  
  # Sidebar menu....
  dashboardSidebar(
    sidebarMenu(
      menuItem("Home", tabName = "home", icon = icon("th")),
      menuItem("Vocabulary", tabName = "vocabulary", icon = icon("file-text-o")),
      menuItem("locationID map", tabName = "locationIDmap", icon = icon("map")),
      menuItem("locationID match-data", tabName = "locationIDmatch", icon = icon("magic")),
      menuItem("Lookup-tables", tabName = "lookup-tables", icon = icon("database"))
    )
  ),
  
  # Dashboard content
  dashboardBody(
    tabItems(
      # Home tab content 
      tabItem(tabName = "home",
              fluidRow(
                includeMarkdown("text_NOFAtools_home_intro.md")
              )
      ),


      
      # Vocabulary tab content
      tabItem(tabName = "vocabulary",
              fluidRow(
                includeMarkdown("text_NOFAtools_vocabulary.md")
              )
      ),
 
      # locationIDmap tab content
      tabItem(tabName = "locationIDmap",
              sidebarPanel(
                includeMarkdown("text_NOFAtools_locationIDmap.md"),
                textInput("municipalityIDinn","Enter MunicipalityID (kommunenummer):",value="1601"),
                selectInput('locaitonIDmap_mapbackground', 'Map background',
                            choices = c("OpenStreetMap", "Esri.WorldImagery"))
              ),
              mainPanel(leafletOutput("locations"))
      ),
      
      # locationIDmatch tab content
      tabItem(tabName = "locationIDmatch",
              sidebarPanel(
                includeMarkdown("text_NOFAtools_locationIDmatch_1.md"),
                fileInput('locationID_file', 'Upload a CSV file',
                          accept=c('text/csv',
                                   'text/comma-separated-values,text/plain',
                                   '.csv')),
                includeMarkdown("text_NOFAtools_locationIDmatch_2.md"),
                downloadButton('download_match_location_data', 'Download matched location data')
              ),
              mainPanel(tableOutput('match_location')
           )
      ),


      # lookup_tables tab content
      tabItem(tabName = "lookup-tables",
              fluidRow(
                includeMarkdown("text_NOFAtools_lookup_tables.md"),  
                selectInput("lookuptables", "Choose a lookup-table:", 
                              choices = c("l_organismQuantityType","l_sampleSizeUnit","l_taxon","l_establishmentMeans",
                                          "l_spawningCondition","l_reliability" ,"l_samplingProtocol")),
                  downloadButton('downloadData', 'Download')
                  ),
              mainPanel(
                  DT::dataTableOutput('lookuptables_view')
                )
              )
            
      
      
      
    )
  )
)
