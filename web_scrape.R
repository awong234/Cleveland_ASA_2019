library(XML)
library(RCurl)
library(dplyr)

# Billboard top 100 -- scrape from date

url_text = "https://www.billboard.com/charts/hot-100/1991-08-05"

getURL(url = url_text) %>% 
  htmlParse %>% 
  xpathSApply(path = "//*/div[@class='chart-list-item__title']/span[@class='chart-list-item__title-text']",
              xmlValue)


# NPS example -- scrape mailing address

url_text = "https://www.nps.gov/cuva/index.htm"

getURL(url = url_text) %>% 
  htmlParse %>% 
  xpathSApply(path = "//*/span[@itemprop='streetAddress']",
              xmlValue)

# Get all available park pages

url_ref = "https://www.nps.gov/findapark/index.htm"


# The @class or @id etc. works interchangeably and order, as long as it
# identifies the group properly
all_codes = getURL(url = url_ref) %>% 
  htmlParse %>% 
  xpathSApply(path = "//*/select[@class=' js-multiselect-findapark']/optgroup/option",
              xmlGetAttr, "value")

all_codes

# Reference from source:

# <select size='2' id='alphacode' name='alphacode' class=' js-multiselect-findapark'  data-nonSelectedText='Park Name' data-enableFiltering='true' >
#   <optgroup label='A'>
#   <option value='abli'>Abraham Lincoln Birthplace National Historical Park</option>

# loop over each of these

getAddr = function(code){
  
  url_text = paste0("https://www.nps.gov/", code, "/index.htm")
  
  item = tryCatch(expr = {
    getURL(url = url_text) %>% 
    htmlParse %>% 
    xpathSApply(path = "//*/span[@itemprop='streetAddress']",
                xmlValue)
  }, error = function(m){message(m); return(NULL)}
  )
  
  return(item)
}

sapply(X = all_codes, FUN = getAddr)

