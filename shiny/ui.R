
# This is the user-interface definition of a Shiny web application.
# You can find out more about building applications with Shiny here:
#
# http://shiny.rstudio.com
#

library(shiny)
library(xlsx)
require(rCharts)

#options(RCHART_LIB='nvd3')

colDf <- read.table("../data/ColumnNames.txt", sep="\t", header=T)
colDf <- colDf[colDf$ColLabel != "" & colDf$ColLabel != 'Year',]
colDf$ColName <- as.character(colDf$ColName)
colDf$ColLabel <- as.character(colDf$ColLabel)

df <- read.table("../data/mergedData.txt", sep="\t", header=T)

shinyUI(fluidPage(

  # Application title
  titlePanel("Budget and Political Parties in the USA"),

  # Sidebar with a slider input for number of bins
  sidebarLayout(
    sidebarPanel(
      selectInput("xVar", "X Axis",
                  choices = colDf[colDf$OkX == 1,]$ColLabel),
      selectInput("yVar", "Y Axis",
                  choices = colDf[colDf$OkY == 1,]$ColLabel),
      selectInput("colVar", "Color By",
                  choices = c("Party of President", "Senate Majority", "House Majority")),
      selectInput("sYear", "Year",
                  choices = df$Year)
    ),

    # Show a plot of the generated distribution
    mainPanel(
      tabsetPanel(
        tabPanel('Plots',
            showOutput("distPlot", "nvd3"),
            headerPanel(h4("Year:")),
            headerPanel(h5("House")),
            showOutput("pieHouse", "nvd3"),
            headerPanel(h5("Senate")),
            showOutput("pieSenate", "nvd3"),
            headerPanel(h5("President")),
            showOutput("piePresident", "nvd3")
        ),
        tabPanel('Data Table',
          dataTableOutput("SummaryTable"))
      )
    )
  )
))
