library(xlsx)

xlToTxt <- function(fn, rStart, cnames){
  inFp <- paste("../data/xls/", fn, ".xls", sep="")
  outFp <- paste("../data/txt/", fn, ".txt", sep="")
  rEnd <- rStart + 67
  
  thisDf <- read.xlsx(file=inFp,
                      sheetName="Table",
                      startRow=rStart,
                      endRow=rEnd,
                      header=F)
  
  colnames(thisDf) <- cnames
  thisDf <- thisDf[thisDf$Year != 'TQ',]
  write.table(thisDf, file=outFp, sep="\t", quote=F, row.names=F)
}

mergeTables <- function(){
  fps <- Sys.glob("../data/txt/*.txt")
  n <- 0
  
  for(fp in fps){
    df <- read.table(fp, sep="\t", header=T)
    if(n==0){
      fullDf <- df
    } else {
      fullDf <- merge(df, fullDf, by.x="Year", by.y="Year")
    }
    n <- n + 1
  }
  return(fullDf)
}


# Government Expeditures as Percent of GDP
xlToTxt("TotExpense_GDP", 4,
        c('Year', 'TotExpGDP', 'FedExpGDP', 
          'FedExpGDPOnBudget', 'FedExpGDPOffBudget', 'NIPAExpGDP', 'SLExpGDP'))

# Government Expeditures as Billions of Dollars
xlToTxt("TotExpense_Billion", 5,
        c('Year', 'TotExpB', 'FedExpB', 
          'FedExpBOnBudget', 'FedExpBOffBudget', 'NIPAExpB', 'SLExpB'))

# Government Surplus/Deficit as GDP and Billions of dollars
xlToTxt("SurplusDeficit", 5,
        c('Year', 'TotSurDefB', 'FedSurDefB', 'FedSurDefBOnBudget', 
          'FedSurDefBOffBudget', 'NIPASurDefB', 'TotSurDefGDP', 'FedSurDefGDP', 'SLSurDefGDP'))

# Government receipts as GDP and Billions of dollars
xlToTxt("Receipts", 6, 
        c('Year', 'TotRecB', 'FedRecB', 'FedRecBOnBudget', 
          'FedRecBOffBudget', 'NIPARecB', 'GDP', 
          'TotRecGDP', 'FedRecGDP', 'SLRecGDP'))

# Goverment Expeditures as GDP
xlToTxt("Expense_GDP", 4,
        c('Year', 'TotExpGDP', 'FedDefenseExpGDP', 'FedInterestExpGDP',
          'FedSSExpGDP', 'FedOtherIndExpGDP', 'FedOtherExpGDP', 'SLExpGDP'))

# Goverment Expeditures as Billions of Dollars
xlToTxt("Expense_Billion", 5, 
        c('Year', 'TotExpB', 'FedDefenseExpB', 'FedInterestExpB',
          'FedSSExpB', 'FedOtherIndExpB', 'FedOtherExpB', 'SLExpB'))

mergedDf <- mergeTables()

write.table(mergedDf, "../data/mergedData.txt", sep="\t", quote=F, row.names=F)
