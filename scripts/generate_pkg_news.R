# e.g., full string
# * A new version (`v0.8.0`) of `bold` is on CRAN - interface to Bold Systems (<http://www.boldsystems.org/>) API. See the [release notes](https://github.com/ropensci/bold/releases/tag/v0.8.0) for changes. Checkout the [vignette](https://cran.rstudio.com/web/packages/bold/vignettes/bold_vignette.html) to get started. {{ "bold" | image_cran }} {{ "bold" | image_github }}
# > `bold_identify_parents()` improvements, and `bold_specimens()` bug fix
suppressPackageStartupMessages(library(glue))
suppressPackageStartupMessages(library(readr))
suppressPackageStartupMessages(library(dplyr))
suppressPackageStartupMessages(library(tidyselect))

read_csv_quiet <- function(x) suppressMessages(readr::read_csv(x))
add_release_urls <- function(x) {
  x <- suppressMessages(left_join(x, metad))
  mutate(x, release_url = as.character(glue(template_release)))
}
check_release_urls <- function(x) {
  release_urls <- unlist(unname(Map(function(a, b, c) {
    z <- if (crul::ok(a)) a else sprintf(news_release, b, c)
    z <- if (crul::ok(z)) z else sprintf(news2_release, b, c)
    if (!crul::ok(z)) {
      z <- ""
      warning("no news file found for ", c)
    }
    return(z)
  }, x$release_url, x$owner, x$pkg)))
  x$release_url <- release_urls
  return(x)
}
make_news_items <- function(x) {
  x <- mutate(x, description =
    sprintf(template_sprintf, ver, pkg, pkg_brief_description,
        release_url, docs_name, docs_url, pkg, pkg))
  cat(x$description, sep = "\n")
}

template_sprintf <- '* A new version (`v%s`) of `%s` is on CRAN - %s. See the [release notes](%s) for changes. Checkout the [%s](%s) to get started. {{ "%s" | image_cran }} {{ "%s" | image_github }}
> xxx'
template_release <- 'https://github.com/{owner}/{pkg}/releases/tag/v{ver}'
news_release <- 'https://github.com/%s/%s/blob/master/NEWS.md'
news2_release <- 'https://github.com/%s/%s/blob/master/NEWS'

# pkg metadata
metad <- read_csv_quiet("data/pkg_metadata.csv")

## New pkgs
dat_new_pkgs <- read_csv_quiet("data/newpkgs.csv")
dat_new_pkgs <- rename(dat_new_pkgs, ver = version)
if (NROW(dat_new_pkgs) == 0) {
  cat("no new packages", sep = "\n")
} else {
  dat_new_pkgs <- add_release_urls(dat_new_pkgs)
  dat_new_pkgs <- check_release_urls(dat_new_pkgs)
  make_news_items(dat_new_pkgs)
}

## New versions
dat_new_vers <- read_csv_quiet("data/newversions.csv")
dat_new_vers <- rename(dat_new_vers, ver = name)
if (NROW(dat_new_vers) == 0) {
  cat("no new versions", sep = "\n")
} else {
  dat_new_vers <- add_release_urls(dat_new_vers)
  if (any(is.na(dat_new_vers$owner))) {
    z <- dat_new_vers[is.na(dat_new_vers$owner), "pkg"]$pkg
    stop("pkg_metadata.csv missing data for:\n", paste0(z, collapse = ","), call.=FALSE)
  }
  dat_new_vers <- check_release_urls(dat_new_vers)
  make_news_items(dat_new_vers)
}
