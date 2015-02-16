
# This is the server logic for a Shiny web application.
# You can find out more about building applications with Shiny here:
#
# http://shiny.rstudio.com

library(shiny)
library(ggplot2)
library(rCharts)
library(reshape2)

#options(RCHART_WIDTH=600)

df <- read.table("../data/mergedData.txt", sep="\t", header=T)
df$pcHouseR <- df$HouseRepublicans / (df$HouseRepublicans + df$HouseDemocrats)
df$pcSenR <- df$SenRepublicans / (df$SenRepublicans + df$SenDemocrats)
df$HouseParty <- ifelse(df$pcHouseR < 1/3, 'Democrat Super Majority',
                        ifelse(df$pcHouseR < 1/2, 'Democrat Majority',
                        ifelse(df$pcHouseR == 1/2, 'Split',
                        ifelse(df$pcHouseR < 2/3, 'Republican Majority', 'Republican Super Majority'))))
df$SenParty <- ifelse(df$pcSenR < 1/3, 'Democrat Super Majority',
                        ifelse(df$pcSenR < 1/2, 'Democrat Majority',
                        ifelse(df$pcSenR == 1/2, 'Split',
                        ifelse(df$pcSenR < 2/3, 'Republican Majority', 'Republican Super Majority'))))

colDf <- read.table("../data/ColumnNames.txt", sep="\t", header=T)
colDf <- colDf[colDf$ColLabel != "",]
colDf$ColName <- as.character(colDf$ColName)
colDf$ColLabel <- as.character(colDf$ColLabel)

shinyServer(function(input, output) {

  output$distPlot <- renderChart({
    # Y Variable
    yVarName <- colDf[colDf$ColLabel == input$yVar,c('ColName')]
    plotY <- df[,c(yVarName)]
    # X Variable
    xVarName <- colDf[colDf$ColLabel == input$xVar,c('ColName')]
    plotX <- df[,c(xVarName)]
    # Color Variable
    colVarName <- colDf[colDf$ColLabel == input$colVar,c('ColName')]
    colVar <- df[,c(colVarName)]

    plotDf <- data.frame(x=plotX, y=plotY, clr=colVar)
    
    # draw the histogram with the specified number of bins
    #ggplot(plotDf, aes(x=x, y=y, col=clr)) + geom_line()
    tmpP<-nPlot(y ~ x, data=plotDf, type="scatterChart", group='clr')
    if(colVarName == "PresParty"){
      tmpP$chart(color=c('Blue', 'Red'))
    } else {
      tmpP$chart(color=c('Pink', 'Blue', 'Purple', 'Grey', 'Red'))
    }
    tmpP$xAxis(axisLabel = input$xVar)
    tmpP$yAxis(axisLabel = input$yVar)
    tmpP$addParams(width=500, height=500, dom='distPlot')
    return(tmpP)
  })
  
  output$pieHouse <- renderChart({
    yDf <- df[df$Year == input$sYear,
              c('HouseDemocrats', 'HouseRepublicans', 'HouseOthers', 'HouseVacancies')]
    plotDf <- melt(yDf)
    pieC <- nPlot(value ~ variable, data = plotDf, type = 'pieChart')
    pieC$chart(donut = TRUE)
    pieC$chart(color=c('Blue', 'Red', 'Green', 'Black'))
    pieC$addParams(width=500, height=500, dom="pieHouse")
    return(pieC)
  })
  
  output$pieSenate <- renderChart({
    yDf <- df[df$Year == input$sYear,
              c('SenDemocrats', 'SenRepublicans', 'SenOthers', 'SenVacancies')]
    plotDf <- melt(yDf)
    pieC <- nPlot(value ~ variable, data = plotDf, type = 'pieChart')
    pieC$chart(donut = TRUE)
    pieC$chart(color=c('Blue', 'Red', 'Green', 'Black'))
    pieC$addParams(width=500, height=500, dom="pieSenate")
    return(pieC)
  })
  
  output$piePresident <- renderChart({
    yDf <- df[df$Year == input$sYear,
              c('PresParty')]
    if(yDf[1] == 'D'){
      yDf <- data.frame(Democrat=c(1), Republican=c(0))
    } else {
      yDf <- data.frame(Democrat=c(0), Republican=c(1))
    }
    plotDf <- melt(yDf)
    pieC <- nPlot(value ~ variable, data = plotDf, type = 'pieChart')
    pieC$chart(donut = TRUE)
    pieC$chart(color = c('Blue', 'Red'))
    pieC$addParams(width=500, height=500, dom="piePresident")
    return(pieC)
  })
  
  output$SummaryTable <- renderDataTable(df)

})
