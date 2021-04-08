library(rvest)
library(xml2)
library(XML)
library(Rcrawler) #above 4 packages for web scraping
library(tidyverse)
library(RCurl)
library(stringr)
library(edgarWebR)
library(readtext)
library(stringr)
library(stringi)
library(lubridate)
library(data.table)
library(ggplot2)
library(vars) #VAR
library(expm)
library(Matrix) #for matrices
library(lattice) #for matrices
library(reshape2)
library(xtable) #prints LaTeX tables
library(dplyr)
library(sandwich) #HH std errors


setwd("C:/Users/KUTHURU/Downloads/Laptop/Semester 3/RA work/Darren Kisgen")

#Install PhantomJS webdriver
#install_browser(version = "2.1.1",baseURL = "https://github.com/wch/webshot/releases/download/v0.3.1/")
#LS<-browser_path()
#"C:\Users\KUTHURU\AppData\Roaming\PhantomJS"

url <- "https://sheet2site-staging.herokuapp.com/api/v3/index.php?key=1F7gLiGZP_F4tZgQXgEhsHMqlgqdSds3vO0-4hoL6ROQ&g=1&e=1"
table <- ContentScraper(Url = url, XpathPatterns = '//*[@id="example"]', asDataFrame = TRUE, browser = LS)
#   
# table <- ContentScraper(Url = url, XpathPatterns = c('//*[@id="example"]'),asDataFrame = TRUE,browser = LS)
# 
# 
# #data=read.csv("C:/Users/KUTHURU/Downloads/Laptop/Semester 3/RA work/Iteration-3/data2.csv", header = TRUE)
# 
# table <-Rcrawler(Website = url,ExtractXpathPat =c('//*[@id="example"]'))
# 
# 
# #second url
# url2 <-"https://warrants.tech/"
# table <- ContentScraper(Url = url2, XpathPatterns = c("/html/body/div[1]/div/div[2]/div[1]/div[2]/div/div[2]/div/div/div/table"),
#                         asDataFrame = TRUE,browser = LS)


#save the html table elements in html file in the directory

table1 <- as.data.frame(read_html("table1.html") %>% html_table(fill=TRUE))
table2 <- as.data.frame(read_html("table2.html") %>% html_table(fill=TRUE))
table3 <- as.data.frame(read_html("table3.html") %>% html_table(fill=TRUE))
table4 <- as.data.frame(read_html("table4.html") %>% html_table(fill=TRUE))

write.csv(table1, file = "table1.csv", row.names = F,col.names = T)
write.csv(table2, file = "table2.csv", row.names = F,col.names = T)
write.csv(table3, file = "table3.csv", row.names = F,col.names = T)