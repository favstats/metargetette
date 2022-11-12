
source("utils.R")
# ?get_targeting
# get_targeting("41459763029", timeframe = "LAST_90_DAYS")
# debugonce(get_targeting)

library(httr)
library(tidyverse)

tstamp <- Sys.time()

# source("utils.R")

last90days <- read_csv("data/FacebookAdLibraryReport_2022-11-07_US_last_90_days_advertisers.csv") %>%
  janitor::clean_names() %>%
  arrange(desc(amount_spent_usd)) %>%
  mutate(spend_upper = amount_spent_usd %>% as.numeric()) %>%
    arrange(-spend_upper) %>%
    mutate_all(as.character)
last90days2 <- read_csv("data/FacebookAdLibraryReport_2022-11-09_US_last_90_days_advertisers.csv") %>%
    janitor::clean_names() %>%
    arrange(desc(amount_spent_usd)) %>%
    mutate(spend_upper = amount_spent_usd %>% as.numeric()) %>%
    arrange(-spend_upper) %>%
    mutate_all(as.character)
# midterms <- readRDS("data/midterms.rds")
#
# rest <- readRDS("data/additional_page_ids.rds") %>%
#   mutate(page_id = as.numeric(page_id))
#
#
#
# internal_page_ids <- midterms %>%
#   # arrange(desc(spend_upper)) %>%
#   drop_na(funding_entity) %>%
#   group_by(page_name, page_id) %>%
#   summarize(spend_upper = sum(spend_upper)) %>%
#   ungroup() %>%
#   bind_rows(last90days) %>%
#   bind_rows(rest %>%
#               filter(cntry == "US")) %>%
#   distinct(page_id, .keep_all = T) %>%
#   arrange(-spend_upper)
#   # filter(spend_upper>=10000)
#
# get_targeting <- possibly(get_targeting, otherwise = NULL, quiet = F)
#
# already_there <- dir("midterms", full.names = T) %>%
#   str_remove_all("\\.rds|midterms/")
#
# internal_page_ids <- internal_page_ids %>% #count(cntry, sort  =T) %>%
#   filter(!(page_id %in% already_there))
# #
# saveRDS(internal_page_ids, file = "data/internal_page_ids.rds")

internal_page_ids <- readRDS("data/internal_page_ids.rds") %>%
    mutate_all(as.character) %>%
      bind_rows(last90days)  %>%
    bind_rows(last90days2) %>%
      distinct(page_id, .keep_all = T)

### save seperately
internal_page_ids %>% #count(cntry, sort  =T) %>%
  # filter(!(page_id %in% already_there)) %>%
  # filter(cntry == "GB") %>%
  # slice(1:10) %>%
  split(1:nrow(.)) %>%
  walk(~{
    try({


      print(paste0(.x$page_name,": ", round(which(internal_page_ids$page_id == .x$page_id)/nrow(internal_page_ids)*100, 2)))

      yo <- get_targeting(.x$page_id, timeframe = "LAST_90_DAYS") %>%
        mutate(tstamp = tstamp)

      if(nrow(yo)!=0){
        path <- paste0("midterms/",.x$page_id, ".rds")
        # if(file.exists(path)){
        #   ol <- read_rds(path)
        #
        #   saveRDS(yo %>% bind_rows(ol), file = path)
         # } else {

          saveRDS(yo, file = path)
        # }
      }

      print(nrow(yo))
    })


  })
