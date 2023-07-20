# UI
library(shiny)
library(bs4Dash)

# Authentification
library(shinymanager)
library(shinyWidgets)

# OOP
library(R6)

# Data
library(DT)
library(markdown)

# Images
library(EBImage)

# Plotting
library(plotly)

#setwd("D:/Dropbox/2_WDB/apps/lvp_app/rshiny")





#------------------------------------------------------------- Setup header ----
header_ui = function() {
  
  # Get data from the description file
  desc = read.delim("DESCRIPTION", header = FALSE)
  
  # Extract and capitalise name
  name = stringr::str_split(desc[1,1], ":")[[1]][2]
  name = toupper(trimws(name))
  
  # Extract version
  version = gsub("[^0-9.-]", "", desc[4,1])  
  header = paste(name, "|", version, sep = " ")
  bs4Dash::dashboardHeader(title = header)
}

#------------------------------------------------------------ Setup sidebar ----

sidebar_ui = function() {
  bs4Dash::dashboardSidebar(
    bs4Dash::sidebarMenu(
      
      # Welcome menu
      bs4Dash::menuItem(
        text = "Welcome",
        tabName = "welcome",
        icon = shiny::icon("home")),
      
      bs4Dash::menuItem(
        text = "Treaties",
        tabName = "treaties"
      ),
      
      bs4Dash::menuItem(
        text = "Database",
        tabName = "database",
        
        bs4Dash::menuSubItem(
          text = "Global",
          tabName = "global_db"
        ),
        
        bs4Dash::menuSubItem(
          text = "Smallswords",
          tabName = "smallswords"
        )
      )
    )
  )
}


#--------------------------------------------------------------- Setup body ----
body_ui = function() {
  bs4Dash::dashboardBody(
    bs4Dash::tabItems(
      
      # Welcome page
      bs4Dash::tabItem(
        tabName = "welcome",
        lvp_welcome()
      ),
      
      # Treaties page
      bs4Dash::tabItem(
        tabName = "treaties",
        treaties_ui(id = 'treaties')
      ),
      
      # Smallsword page
      bs4Dash::tabItem(
        tabName = "smallswords",
        smallswords_ui(id = "smallswords_db")
      )
      
    )
  )
}





#----------------------------------------------------------------------- UI ----
header = header_ui()
sidebar = sidebar_ui()
body = body_ui()
# ui = bs4Dash::dashboardPage(header, sidebar, body)
ui = bs4Dash::dashboardPage(header, sidebar, body)
#------------------------------------------------------------------- Server ----

server = function(input, output, session) {
  
  # Initiate some variables
  options(shiny.maxRequestSize=300*1024^2)
  
  treaties_server(id = 'treaties')
  smallswords_server(id = "smallswords_db")
  
  
  
  
}



#---------------------------------------------------------------------- End ----
shinyApp(ui, server)
