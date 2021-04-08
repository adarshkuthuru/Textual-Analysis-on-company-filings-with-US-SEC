library(rvest)
library(tidyverse)
library(RCurl)
library(XML)

data=read.csv("C:/Users/KUTHURU/Downloads/Semester 3/RA work/Downloaded Files/data.csv", header = TRUE)

Relocated=matrix(NA,nrow(data),5) #null matrix
count=0
for(i in 1:nrow(data)){
h=grep("relocat", readLines(as.character(data[i,9])), ignore.case =T, value=T, fixed=F)
if(length(h)!=0){
  Relocated[i,1]=as.character(data[i,7])
  count=count+1
  }
}

count1=0
for(j in 1:nrow(Relocated)){
  if(is.na(Relocated[j,1])==F){
    h=grep("headquarter", readLines(as.character(data[j,9])), ignore.case =T, value=T, fixed=F)
    if(length(h)!=0){
      Relocated[j,2]=as.character(data[j,7])
      Relocated[j,3]=as.character(data[j,2])
      count1=count1+1
    } 
  }
}
  