library(rvest)
library(tidyverse)
library(RCurl)
library(XML)
library(stringr)
library(edgarWebR)
library(rvest)
library(readtext)
library(stringr)
library(stringi)
library(ggmap)
library(gmapsdistance)

data=read.csv("C:/Users/KUTHURU/Downloads/Laptop/Semester 3/RA work/Iteration-3/data2.csv", header = TRUE)

#h=parse_text_filing(as.character(data[17,6]), strip = TRUE, include.raw = FALSE, fix.errors = TRUE)

#function to parse the text files
autoParse <- function(x){
  paste(data[x,9], collapse = "") %>% # Step 1: check the column number of input here
    readLines(encoding = "UTF-8") %>% # Step 2
    str_c(collapse = " ") %>% # Step 3
    str_extract(pattern = "(?s)(?m)<TYPE>10-K.*?(</TEXT>)") %>% # Step 4
    str_replace(pattern = "((?i)<TYPE>).*?(?=<)", replacement = "") %>% # Step 5
    str_replace(pattern = "((?i)<SEQUENCE>).*?(?=<)", replacement = "") %>% # Step 6
    str_replace(pattern = "((?i)<FILENAME>).*?(?=<)", replacement = "") %>%
    str_replace(pattern = "((?i)<DESCRIPTION>).*?(?=<)", replacement = "") %>%
    str_replace(pattern = "(?s)(?i)<head>.*?</head>", replacement = "") %>%
    str_replace(pattern = "(?s)(?i)<(table).*?(</table>)", replacement = "") %>%
    str_replace_all(pattern = "(?s)(?i)(?m)> +Item|>Item|^Item", replacement = ">°Item") %>% # Step 7
    str_replace_all(pattern = "(?s)<.*?>", replacement = " ") %>% # Step 8
    str_replace_all(pattern = "&(.{2,6});", replacement = " ") %>% # Step 9
    str_replace_all(pattern = "(?s) +", replacement = " ")  # Step 10
}


Relocated=matrix(NA,nrow(data),50) #null matrix
#new matching 1
count=0
for(i in 1:1000){ #nrow(data)
  texts=autoParse(i)
  #texts <- readLines(as.character(data[i,9]),encoding = "UTF-8")
  #texts <- readLines("C:/Users/KUTHURU/Downloads/Laptop/Semester 3/RA work/Iteration-3/17.txt")
  h=unlist(strsplit(texts, "(?<=\\.)\\s(?=[A-Z])", perl = T))
  #h=unlist(strsplit(texts, "(?<=[[:punct:]])\\s(?=[A-Z])", perl=T)) 
  #\\.[[:space:]]+"
  k=0
  for(j in 1:length(h)){
    if(length(h[[j]])>0){
      if(grepl("relocat[^\\.,!?:;]*headquarter|headquarter[^\\.,!?:;]*relocat",h[[j]])==T){
        Relocated[i,5+k]=h[[j]]
        k=k+1
      }
    }
  }
  if(k>0){
    Relocated[i,4]=as.character(data[i,7])
    Relocated[i,3]=as.character(data[i,3])
    Relocated[i,2]=as.character(data[i,5])
    Relocated[i,1]=as.character(data[i,1])
    count=count+1
  }
}
#delete the missing obs rows in relocated dataset
relocated1=Relocated[complete.cases(Relocated[ ,1:4]),]
#relocated1=na.omit(Relocated[1:nrow(data),7:10])
#sorting by cik
relocated1[order(relocated1[,2],relocated1[,3]),]
write.csv(relocated1, file = "matches_50000.csv", row.names = F,col.names = T)






################################################
#calculate map distance
maps=read.csv("C:/Users/KUTHURU/Desktop/test.csv", header = TRUE)
#setting up api
register_google(key="AIzaSyCI3EIr5qn9O1wx_mqxLVoc_Vg4Cvjg2tY")

dist=mapdist(from = dQuote(maps[1,1]), to = dQuote(maps[1,2]))
dist=gmapsdistance(origin=dQuote(maps[1,1]), destination = dQuote(maps[1,2]),mode="driving")
results = gmapsdistance(origin = "38.1621328+24.0029257",
                        destination = "37.9908372+23.7383394",
                        mode = "walking",key="AIzaSyCI3EIr5qn9O1wx_mqxLVoc_Vg4Cvjg2tY")