
# This is the server logic for a Shiny web application.
# You can find out more about building applications with Shiny here:
#
# http://shiny.rstudio.com

library(shiny)
library(ggplot2)
library(rCharts)
library(reshape2)

# Get the main data.frame for the application
df <- read.table("data/mergedData.txt", sep="\t", header=T)

# Calculate percentages of political parties from counts
df$pcHouseR <- df$HouseRepublicans / (df$HouseRepublicans + df$HouseDemocrats)
df$pcSenR <- df$SenRepublicans / (df$SenRepublicans + df$SenDemocrats)

# Categorize percentages for coloring in plots
df$HouseParty <- ifelse(df$pcHouseR < 1/3, 'Democrat Super Majority',
                        ifelse(df$pcHouseR < 1/2, 'Democrat Majority',
                        ifelse(df$pcHouseR == 1/2, 'Split',
                        ifelse(df$pcHouseR < 2/3, 'Republican Majority', 'Republican Super Majority'))))
df$SenParty <- ifelse(df$pcSenR < 1/3, 'Democrat Super Majority',
                        ifelse(df$pcSenR < 1/2, 'Democrat Majority',
                        ifelse(df$pcSenR == 1/2, 'Split',
                        ifelse(df$pcSenR < 2/3, 'Republican Majority', 'Republican Super Majority'))))

# Get information about the columns in the main data.frame
# the colDf data.frame contains user-friendly column names and
# configures whether or not the columns of the main data.frame are
# suitable X and Y variables.
colDf <- read.table("data/ColumnNames.txt", sep="\t", header=T)
# Remove columns that do not have a friendly label
# (an empty label denotes that we don't want to view the column)
colDf <- colDf[colDf$ColLabel != "",]
# Unfactor columns
colDf$ColName <- as.character(colDf$ColName)
colDf$ColLabel <- as.character(colDf$ColLabel)

# Main server-side code:
shinyServer(function(input, output) {

  # Header line for pie charts echos the year back to the user
  output$echoYear <- renderText({paste("Federal Government Political Party Composition in", input$sYear)})
  
  # Return the name of the president.
  # Can't find a way to specify text color from the server,
  # so there are two locations for the president name in the UI
  # one with red styling for republican presidents, one with blue
  # styling for democrat presidents.
  output$echoPresidentD <- renderText({
    rowNo <- match(c(input$sYear), df$Year)
    presParty <- as.character(df[rowNo,]$PresParty)
    if(presParty == "Democrat"){
      return(paste("President:", as.character(df[rowNo,]$President), "(D)"))
    } else {
      return("")
    }
  })
  
  output$echoPresidentR <- renderText({
    rowNo <- match(c(input$sYear), df$Year)
    presParty <- as.character(df[rowNo,]$PresParty)
    if(presParty == "Republican"){
      return(as.character(paste("President:", as.character(df[rowNo,]$President), "(R)")))
    } else {
      return("")
    }
  })
  
  # Pie Charts
  
  # Create a pie chart displaying the composition of
  # the house of representatives
  output$pieHouse <- renderChart({
    # use the year selected by the user:
    yDf <- df[df$Year == input$sYear,
              c('HouseDemocrats', 'HouseRepublicans', 'HouseOthers', 'HouseVacancies')]
    # convert columns to rows
    plotDf <- melt(yDf)
    # make pie chart
    pieC <- nPlot(value ~ variable, data = plotDf, type = 'pieChart')
    # display as donut
    pieC$chart(donut = TRUE)
    # set the colors
    pieC$chart(color=c('Blue', 'Red', 'Green', 'Black'))
    # set plot size and DOM node
    pieC$addParams(width=600, dom="pieHouse")
    return(pieC)
  })
  
  # Create pie chart for the political party composition of the Senate
  # same steps as the chart for the house above.
  output$pieSenate <- renderChart({
    yDf <- df[df$Year == input$sYear,
              c('SenDemocrats', 'SenRepublicans', 'SenOthers', 'SenVacancies')]
    plotDf <- melt(yDf)
    pieC <- nPlot(value ~ variable, data = plotDf, type = 'pieChart')
    pieC$chart(donut = TRUE)
    pieC$chart(color=c('Blue', 'Red', 'Green', 'Black'))
    pieC$addParams(width=600, dom="pieSenate")
    return(pieC)
  })
  
  # Create the main scatter plot
  output$distPlot <- renderChart({
    
    # Add X, Y and Color columns to the political/economic data.frame
    # Y Variable - selected by user
    yVarName <- colDf[colDf$ColLabel == input$yVar,c('ColName')]
    plotY <- df[,c(yVarName)]
    # X Variable - selected by user
    xVarName <- colDf[colDf$ColLabel == input$xVar,c('ColName')]
    plotX <- df[,c(xVarName)]
    # Color Variable - selected by user
    colVarName <- colDf[colDf$ColLabel == input$colVar,c('ColName')]
    colVar <- df[,c(colVarName)]
    
    # Create the plotting data.frame
    plotDf <- df
    plotDf$x <- plotX
    plotDf$y <- plotY
    plotDf$clr <- colVar
    
    # Create the main plot
    tmpP<-nPlot(y ~ x, data=plotDf, type="scatterChart", group='clr')
    
    # Set color vectors in shades of red and blue to convey majority party
    if(colVarName == "PresParty"){
      tmpP$chart(color=c('Blue', 'Red'))
    } else {
      # order of color factors:
      # Majority R, Majority D, Supermajority D, Split, Supermajority R
      tmpP$chart(color=c('red', 'blue', 'darkblue', 'grey', 'darkred'))
    }
    
    # label the axes
    tmpP$xAxis(axisLabel = input$xVar)
    tmpP$yAxis(axisLabel = input$yVar)
    
    # Generate a tooltip on hover which displays
    # color coded information of the president, house and senate.
    tmpP$chart(tooltipContent="#!
            function(key, x, y, e){
              tt = '<strong>' + e.point.Year + '</strong><br/>';
              tt = tt + 'President: <font color=\"';
              if(e.point.PresParty == 'Democrat') {
                tt = tt + 'blue';
              } else {
                tt = tt + 'red';
              }
              tt = tt + '\">' + e.point.President + '</font>';
              tt = tt + '<br />House: <font color=\"red\">' + e.point.HouseRepublicans + '</font> / ';
              tt = tt + '<font color=\"blue\">' + e.point.HouseDemocrats + '</font>';
              tt = tt + '<br />Senate: <font color=\"red\">' + e.point.SenRepublicans + '</font> / ';
              tt = tt + '<font color=\"blue\">' + e.point.SenDemocrats + '</font>';
              return tt;
            } !#")
    
    # attach the plot
    tmpP$addParams(width=600, dom='distPlot')
    return(tmpP)
  })
  
  # TODO: capture click event on main plot and use it to select and update the year
})
