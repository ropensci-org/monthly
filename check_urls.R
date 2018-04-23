options(stringsAsFactors = FALSE)

# helper functions
stract <- function(str, pattern) regmatches(str, regexpr(pattern, str))
last <- function(x) x[length(x)]

# get most recent news file path
f <- list.files("_site", full.names = TRUE, pattern = "[0-9]{4}-[0-9]{2}-[0-9]{2}")
fdates <- stract(f, "[0-9]{4}-[0-9]{2}-[0-9]{2}")
path <- file.path(grep(last(sort(fdates)), f, value = TRUE), "index.html")
cat("\nchecking ", path, "\n")

# extract URLs

require(xml2, quietly = TRUE, warn.conflicts = FALSE)
html <- read_html(path)
bod <- xml_find_all(html, "//body")
urls <- unique(xml_attr(xml_find_all(bod, '//a[contains(@href, "http")]'), "href"))
cat("found", length(urls), "URLs", "\n")

# check URLs

library(crul, quietly = TRUE, warn.conflicts = FALSE)
conn <- crul::Async$new(urls = urls)
res <- conn$get()
stats <- vapply(res, "[[", numeric(1), "status_code")
df <- data.frame(url = urls, code = stats)
bad <- df[df$code >= 400 | df$code < 200, ]
if (NROW(bad) == 0) {
  cat("all good :)", "\n")
} else {
  # cat("check the following:\n", paste0(urls[1:2], collapse = "\n "), "\n")
  cat("check the following:", "\n")
  print(bad)
}
