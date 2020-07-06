suppressPackageStartupMessages(library(dplyr))
suppressPackageStartupMessages(library(glue))
suppressPackageStartupMessages(library(readr))

new_pkg <- suppressMessages(readr::read_csv("data/newpkgs.csv"))
new_ver <- suppressMessages(readr::read_csv("data/newversions.csv"))

# make sure no packages in new_pkg that are also in new_ver
if (any(new_pkg$pkg %in% new_ver$pkg)) {
  toremove <- new_ver$pkg[new_ver$pkg %in% new_pkg$pkg]
  new_ver <- dplyr::filter(new_ver, pkg != toremove)
}

# counts
new_pkg_count <- NROW(new_pkg)
new_ver_count <- NROW(new_ver)

# make narrative
pkg_ending <- function(x) {
  if (x == 0) return("s")
  if (x == 1) return("")
  if (x > 1) return("s")
}
pkg_count <- function(x) {
  if (x == 0) "no" else as.character(x)
}
strg <- "We've got {pkg_count(new_pkg_count)} new package{pkg_ending(new_pkg_count)} on CRAN, 
{new_ver_count} new package versions"
cat(as.character(glue::glue(gsub("\n", "", strg))))
