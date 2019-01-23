options(stringsAsFactors = FALSE)

# helper functions
stract <- function(str, pattern) regmatches(str, regexpr(pattern, str))
last <- function(x) x[length(x)]

# get most recent news file path
f <- list.files("_site", full.names = TRUE, pattern = "[0-9]{4}-[0-9]{2}-[0-9]{2}")
fdates <- stract(f, "[0-9]{4}-[0-9]{2}-[0-9]{2}")
paths <- file.path(grep("2018-", f, value = TRUE), "index.html")
# cat("\nchecking ", path, "\n")

# extract URLs
require(xml2, quietly = TRUE, warn.conflicts = FALSE)
extract <- function(x) {
  html <- read_html(x)
  # foot <- xml_find_first(html, "//div[@class=\"footnotes\"]")
  n <- length(xml_find_all(html, "//div[@class=\"footnotes\"]/ol/li"))
  cat("for ", x, " found", n, " citations", "\n")
  return(n)
}
cites <- lapply(paths, extract)
total <- sum(unlist(cites))
cat("\n total citations for 2018: ", total, "\n")
