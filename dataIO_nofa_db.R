###############################################################################
#
# Returns data fetched from nofa_db as local in-memory dataframes
# - lookup-tables
#
###############################################################################

library(dplyr)
library(leaflet)
library(RPostgreSQL)
#library(data.table)

# returns connection objects: "nofa_db_RPostgreSQL" using RPostgreSQL
source("db_connect.R") 

# connection
# nofa_db_dplyr <- src_postgres(host="vm-srv-finstad.vm.ntnu.no",dbname="ecco_biwa_db",
#                               user=user,password=passwd, options="-c search_path=nofa_new")

#------------------------------------------------------------------------------
# Get list of tables and lookuptables 
#------------------------------------------------------------------------------
# select list of tables from from pg_catalog.pg_tables
nofa_tablelist <- dbGetQuery(nofa_db_RPostgreSQL, "SELECT * FROM pg_catalog.pg_tables 
                             WHERE schemaname='nofa_new'") 

lookup_tables_names <- filter(nofa_tablelist,grepl("l_",tablename))$tablename

# download lookup tables
l_organismQuantityType <-dbGetQuery(nofa_db_RPostgreSQL,"SELECT * FROM nofa_new.\"l_organismQuantityType\"")
l_sampleSizeUnit <- dbGetQuery(nofa_db_RPostgreSQL,"SELECT * FROM nofa_new.\"l_sampleSizeUnit\"")
l_taxon <- dbGetQuery(nofa_db_RPostgreSQL,"SELECT * FROM nofa_new.\"l_taxon\"")
l_establishmentMeans<- dbGetQuery(nofa_db_RPostgreSQL,"SELECT * FROM nofa_new.\"l_establishmentMeans\"")
l_spawningCondition <- dbGetQuery(nofa_db_RPostgreSQL,"SELECT * FROM nofa_new.\"l_spawningCondition\"")
l_spawningLocation <- dbGetQuery(nofa_db_RPostgreSQL,"SELECT * FROM nofa_new.\"l_spawningLocation\"")
l_reliability <- dbGetQuery(nofa_db_RPostgreSQL,"SELECT * FROM nofa_new.\"l_reliability\"")
l_samplingProtocol <- dbGetQuery(nofa_db_RPostgreSQL,"SELECT * FROM nofa_new.\"l_samplingProtocol\"")

#------------------------------------------------------------------------------
# Get list of column names for selected tables
#------------------------------------------------------------------------------
# get columnames
nofa_colnames <- dbGetQuery(nofa_db_RPostgreSQL, "SELECT * FROM information_schema.columns 
                             WHERE table_schema='nofa_new' AND table_name='event'
                               OR table_schema='nofa_new' AND table_name='occurence'
                               OR table_schema='nofa_new' AND table_name='location';") %>%
                select(column_name,table_name,data_type,ordinal_position)

#------------------------------------------------------------------------------
# Get comments for selected tables
#------------------------------------------------------------------------------

nofa_tablecomments <- dbGetQuery(nofa_db_RPostgreSQL, "SELECT * FROM pg_description 
                                  WHERE  objoid = 'nofa_new.event'::regclass
                                  OR objoid = 'nofa_new.occurence'::regclass
                                  OR objoid = 'nofa_new.location'::regclass;")


# cloase db connections 
RPostgreSQL::dbDisconnect(nofa_db_RPostgreSQL)
#RPostgreSQL::dbDisconnect(nofa_db_dplyr$con)
