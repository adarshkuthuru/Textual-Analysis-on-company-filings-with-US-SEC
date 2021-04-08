#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Thu Oct 29 08:59:19 2020

@author: r0k01ir
"""


import pandas as pd
from bs4 import BeautifulSoup
import requests as r

url_link = "https://sheet2site-staging.herokuapp.com/api/v3/index.php/?key=1F7gLiGZP_F4tZgQXgEhsHMqlgqdSds3vO0-4hoL6ROQ"

response = r.get(url_link)


def get_sec_url(row):
    try:
        if row.text.strip() == "SEC Filings":
            return row.find('a').get("href")
        else:
            return ""
    except:
        return ""
    
def get_spac_url(row):
    try:
        if row.text.strip() == "SPAC Website":
            return row.find('a').get("href")
        else:
            return ""
    except:
        return ""
   

## Unit Link         Warrant Link
        
def get_unit_link(row):
    try:
        if row.text.strip() == "Unit Link":
            return row.find('a').get("href")
        else:
            return ""
    except:
        return ""
    
def get_warrant_link(row):
    try:
        if row.text.strip() == "Warrant Link":
            return row.find('a').get("href")
        else:
            return ""
    except:
        return ""    


soup = BeautifulSoup(response.text, "lxml")
table = soup.find("table", attrs={"id" : "example"})
table_records = table.find_all("tr")
list_records = []
for each_record in table_records[1:]:
    new_dict = dict()
    table_data = each_record.find_all("td")
    new_dict["SPAC Ticker Symbol"] = table_data[0].text.strip()
    new_dict["Name"] = table_data[1].text.strip()
    new_dict["Status"] = table_data[2].text.strip()
    new_dict["Target Focus"] = table_data[3].text.strip()
    new_dict["Target Co (if Announced)"] = table_data[4].text.strip()
    new_dict["IPO Size (M)"] = table_data[5].text.strip()
    new_dict["Trust Value (from last filing)"] = table_data[6].text.strip()
    new_dict["Market Cap"] = table_data[7].text.strip()
    new_dict["Common Price"] = table_data[8].text.strip()
    new_dict["% Change"] = table_data[9].text.strip()
    new_dict["Unit & Warrant Details"] = table_data[10].text.strip()
    new_dict["Unit Link"] = get_unit_link(table_data[11])
    new_dict["Est. Days Until Unit Separation"] = table_data[12].text.strip()
    new_dict["Warrant Link"] = get_warrant_link(table_data[13])
    new_dict["Warrant Intrinsic Value"] = table_data[14].text.strip()
    new_dict["IPO Date"] = table_data[15].text.strip()
    new_dict["Estimated Completion Deadline Date"] = table_data[16].text.strip()
    new_dict["Prominent Leadership / Directors / Advisors"] = table_data[17].text.strip()
    new_dict["Underwriter(s)"] = table_data[18].text.strip()
    new_dict["SEC Filings"] = get_sec_url(table_data[19])
    new_dict["SPAC Website"] = get_spac_url(table_data[20])
    new_dict["Tags (SPAC or Target Industry/ Other Tags)"] = table_data[21].text.strip()
    new_dict["% Time to Deadline"] = table_data[22].text.strip()
    list_records.append(new_dict)


frame = pd.DataFrame(list_records)
frame.to_csv("/Users/r0k01ir/Downloads/data.csv", sep = "\t", index = False)



    


