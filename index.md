---
title       : Economic Data Explorer
subtitle    : JHU's Coursera Developing Data Products Course Project
author      : mattmdedek
job         : 
framework   : revealjs     # {io2012, html5slides, shower, dzslides, ...}
highlighter : highlight.js  # {highlight.js, prettify, highlight}
hitheme     : tomorrow      # 
widgets     : []            # {mathjax, quiz, bootstrap}
ext_widgets : {rCharts: libraries/nvd3}
mode        : selfcontained # {standalone, draft}
knit        : slidify::knit2slides
--- #Slide1

<style>iframe{background-color: white}</style>

## Coursera: Johns Hopkins University

#### Data Science Specialization

#### Developing Data Products Course Project

## Political and Budgetary Data Explorer

--- #Slide2

## Are Political Stereotypes Hype or Truth?

#### The commonly held beleifs are that:

* Republicans tax less and spend less
* Democrats tax more and spend more


Does the data show this relationship between the size of government and the political parties in power?

--- #Slide3

## The Application

This data product lets you explore US Federal budget data
in the context of the political party majorities in congress and
the oval office.

### Sources of Data

* Political Party Data: Wikipedia
http://en.wikipedia.org/wiki/Party_divisions_of_United_States_Congresses

* Budget Data: Office of Management and Budget
http://www.whitehouse.gov/omb/budget/Historicals

--- #Slide4

## Features

#### Choose variables to compare, view annual details




```r
tmpP<-nPlot(FedExpGDP ~ Year, data=df, type="scatterChart", group='PresParty')
```

<iframe src=' assets/fig/example-plot-1.html ' scrolling='no' frameBorder='0' seamless class='rChart nvd3 ' id=iframe- chartb1e9283f946 ></iframe> <style>iframe.rChart{ width: 100%; height: 400px;}</style>

--- #Slide5

## Thanks for Viewing My App

Application URL:
https://mattmdedek.shinyapps.io/JHU-DataProductsProject/

Application Source Code:
https://github.com/mattmdedek/jhu-data-products/tree/master

Slides Source Code:
https://github.com/mattmdedek/jhu-data-products/tree/gh-pages

