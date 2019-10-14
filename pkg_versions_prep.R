if (!requireNamespace("rostats")) remotes::install_github("ropensci/rostats")
if (!requireNamespace("dplyr")) install.packages("dplyr")
if (!requireNamespace("readr")) install.packages("readr")
library("rostats")
suppressPackageStartupMessages(library("readr"))
suppressPackageStartupMessages(library("dplyr"))

# get list of package names to get stats for
url <- "https://raw.githubusercontent.com/ropensci/roregistry/gh-pages/registry.json"
df <- jsonlite::fromJSON(url)
pkgs <- tbl_df(df$packages) %>%
  filter(on_cran | on_bioc) %>%
  .$name

# get first date on CRAN for each pkg
# FIXME: make this step faster
res <- gather_crans(pkgs)
alldat <- dplyr::bind_rows(res)

# calculate the dates of the last news
dates <- sort(as.Date(gsub("-update.+", "", list.files("_posts"))))
last_news_date <- dates[length(dates)]
if (last_news_date == Sys.Date()) last_news_date <- dates[length(dates) - 1]

# get new packages on CRAN, arranged by date
alldat %>%
    cran_first_date() %>%
    arrange(desc(date)) %>%
    filter(date > last_news_date) %>%
    readr::write_csv("data/newpkgs.csv")

# get new packages & new versions on CRAN, arranged by date
alldat %>%
    arrange(desc(date)) %>%
    filter(date > last_news_date) %>%
    readr::write_csv("data/newversions.csv")
