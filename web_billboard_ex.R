library(XML)
library(RCurl)
library(dplyr)

url_text = "https://www.billboard.com/charts/hot-100/1991-08-05"

getURL(url = url_text) %>% 
  htmlParse %>% 
  xpathSApply(path = "//*/div[@class='chart-list-item__title']/span[@class='chart-list-item__title-text']",
              xmlValue)
