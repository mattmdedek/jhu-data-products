
# This is the user-interface definition of a Shiny web application.
# You can find out more about building applications with Shiny here:
#
# http://shiny.rstudio.com
#

library(shiny)
require(rCharts)

# Get information about columns from the configuration file
# this configuration file has user-friendly column names
# and denotes which columns are appropriate X and Y variables
# for plotting.
colDf <- read.table("data/ColumnNames.txt", sep="\t", header=T)
colDf <- colDf[colDf$ColLabel != "",]
colDf$ColName <- as.character(colDf$ColName)
colDf$ColLabel <- as.character(colDf$ColLabel)

# Read the data table
df <- read.table("data/mergedData.txt", sep="\t", header=T)

shinyUI(fluidPage(

  # Title
  titlePanel("Budget and Political Parties in the USA: 1948-2014"),

  # Widgets and main plot
  fluidRow(
    # Sidebar with a slider input for number of bins
    column(4,
      wellPanel(
        # Permitted X-axis variables.
        # subset the columns by $OkX
        selectInput("xVar", "X Axis",
                    choices = colDf[colDf$OkX == 1,]$ColLabel,
                    selected="Year"),
        # Permitted Y-axis variables.
        # subset the columns by $OkY
        selectInput("yVar", "Y Axis",
                    choices = colDf[colDf$OkY == 1,]$ColLabel,
                    selected = "% GDP Federal Gov't Spending"),
        # Only allow points to be colored by political information
        selectInput("colVar", "Color By",
                    choices = c("Party of President", "Senate Majority", "House Majority"),
                    selected = "Party of President"),
        selectInput("sYear", "Year",
                    choices = df$Year, selected=2014)
      )
    ),

    # Show scatter plot of the selected variables
    column(8, div(showOutput("distPlot", "nvd3")))
  ),
  
  # separating horizontal line
  hr(),
  
  # Header for political summary - displays the year
  fluidRow(column(12, headerPanel(h3(textOutput("echoYear"))))),
  
  # President's name in color
  # Could not find a way to set color in server.R, so there are
  # two place holders for the president's name (red and blue for R/D)
  # only one of these will have input.
  fluidRow(column(12, headerPanel(h4(textOutput("echoPresidentR"), style="color:red")))),
  fluidRow(column(12, headerPanel(h4(textOutput("echoPresidentD"), style="color:blue")))),
  
  # Pie charts summarizing political party representation
  # in congress for the selected year
  fluidRow(column(6,
      fluidRow(column(12, headerPanel(h4("House of Representatives")))),
      fluidRow(column(12,
        div(showOutput("pieHouse", "nvd3"), style="margin-left:-100px")
      ))
    ),
    column(6,
      fluidRow(column(12, headerPanel(h4("Senate")))),
      fluidRow(column(12,
        div(showOutput("pieSenate", "nvd3"), style="margin-left:-100px")
      ))
    )
  )
))
