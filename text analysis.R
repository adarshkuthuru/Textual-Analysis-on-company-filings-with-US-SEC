library(rvest)
library(tidyverse)
library(RCurl)
library(XML)
library(stringr)
library(edgarWebR)
library(rvest)
library(readtext)
require(stringr)
require(stringi)

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

#enter row number in data dataset in place of x
h=autoParse(17)

Relocated=matrix(NA,nrow(data),50) #null matrix
#new matching 1
count=0
for(i in 1:100000){ #nrow(data)
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
write.csv(relocated1, file = "matches_300000.csv", row.names = F,col.names = T)

#new matching 2
count=0
for(i in 1:nrow(data)){
  h=gsub(".*?([^\\.]*(relocat*headquarter|headquarter*relocat)[^\\.]*).*","\\1",readLines(as.character(data[i,9])), ignore.case=T, fixed=F)
  if(any(h, na.rm=F)==T){
    Relocated[i,10]=as.character(data[i,7])
    Relocated[i,8]=as.character(data[i,3])
    Relocated[i,9]=as.character(data[i,5])
    Relocated[i,7]=as.character(data[i,1])
    count=count+1
  }
}


#new matching
count=0
for(i in 1:nrow(data)){
  h=grepl("relocat[^\\.,!?:;]*headquarter|headquarter[^\\.,!?:;]*relocat",readLines(as.character(data[i,9])))
  if(any(h, na.rm=F)==T){
    Relocated[i,4]=as.character(data[i,7])
    Relocated[i,3]=as.character(data[i,3])
    Relocated[i,2]=as.character(data[i,5])
    Relocated[i,1]=as.character(data[i,1])
    count=count+1
  }
}




#old matching
count4=0
for(i in 1:nrow(data)){
h=grep("relocat", readLines(as.character(data[i,9])), ignore.case =T, value=T, fixed=F)
if(length(h)!=0){
  Relocated[i,1]=as.character(data[i,7])
  Relocated[i,2]=as.character(data[i,3])
  Relocated[i,3]=as.character(data[i,5])
  count4=count4+1
  }
}

count3=0
for(l in 1:nrow(Relocated)){
    h=grep("move", readLines(as.character(data[l,9])), ignore.case =T, value=T, fixed=F)
    if(length(h)!=0){
      Relocated[l,4]=as.character(data[l,7])
      count3=count3+1
   } 
}

count1=0
for(j in 1:nrow(Relocated)){
  if(is.na(Relocated[j,1])==F || is.na(Relocated[j,4])==F){
    h=grep("headquarter", readLines(as.character(data[j,9])), ignore.case =T, value=T, fixed=F)
    if(length(h)!=0){
      Relocated[j,5]=as.character(data[j,7])
      count1=count1+1
    } 
  }
}
  

count2=0
for(k in 1:nrow(Relocated)){
  if(is.na(Relocated[k,1])==F || is.na(Relocated[k,4])==F){
    h=grep("office", readLines(as.character(data[k,9])), ignore.case =T, value=T, fixed=F)
    if(length(h)!=0){
      Relocated[k,6]=as.character(data[k,7])
      count2=count2+1
    } 
  }
}

colnames(Relocated)=c('relocat','cik','date','move','headquarter','office','a','b','c','d')

#delete the missing obs rows in relocated dataset
relocated1=na.omit(Relocated[1:nrow(data),1:6])
#sorting by cik
relocated2=relocated1[order(relocated1[,2],relocated1[,3]),]


#New method
require(quanteda)
for(z in 1:nrow(Relocated)){
  if(is.na(Relocated[z,1])==F){
  if(length(kwic(corpus(readLines(as.character(data[z,9]))), "relocat|headquarter"))>7){
    Relocated[z,10]=1
    }
  }
}

Text <- c("On March 12, 1996, the Company's Board of Directors approved a restructuring plan which involves a relocation of the Company's corporate headquarters to Atlanta, Georgia. The Company has signed a five-year lease, providing for monthly rental payments of approximately $44,000, on the new headquarters and sales and distribution facility in Atlanta which is scheduled for completion in late 1996. The Company has recognized a restructuring charge of $2.3 million and believes that, when completed, the restructuring will result in improvements in operational efficiency.")
stringr::str_subset(Text, "relocat.*headquarter")
