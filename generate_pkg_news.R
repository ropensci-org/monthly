# e.g., full string
# * A new version (`v0.8.0`) of `bold` is on CRAN - interface to Bold Systems (<http://www.boldsystems.org/>) API. See the [release notes](https://github.com/ropensci/bold/releases/tag/v0.8.0) for changes. Checkout the [vignette](https://cran.rstudio.com/web/packages/bold/vignettes/bold_vignette.html) to get started. {{ "bold" | image_cran }} {{ "bold" | image_github }} 
# > `bold_identify_parents()` improvements, and `bold_specimens()` bug fix
library(glue)
library(dplyr)
library(tidyselect)

# template <- '* A new version (`v{ver}`) of `{pkg}` is on CRAN - {pkg_brief_description}. See the [release notes](https://github.com/{owner}/{pkg}/releases/tag/v{ver}) for changes. Checkout the [{docs_name}]({docs_url}) to get started. {{ "{pkg}" | image_cran }} {{ "{pkg}" | image_github }} 
# > xxx'
# template <- '* A new version (`v{ver}`) of `{pkg}` is on CRAN - {pkg_brief_description}. See the [release notes]({release_url}) for changes. Checkout the [{docs_name}]({docs_url}) to get started. \\{\\{ "{pkg}" | image_cran \\}\\} \\{\\{ "{pkg}" | image_github \\}\\}
# > xxx'
template_sprintf <- '* A new version (`v%s`) of `%s` is on CRAN - %s. See the [release notes](%s) for changes. Checkout the [%s](%s) to get started. {{ "%s" | image_cran }} {{ "%s" | image_github }}
> xxx'
template_release <- 'https://github.com/{owner}/{pkg}/releases/tag/v{ver}'
news_release <- 'https://github.com/%s/%s/blob/master/NEWS.md'

# dat_new_pkgs <- readr::read_csv("data/newpkgs.csv")
dat_new_vers <- readr::read_csv("data/newversions.csv")
# dat_new_pkgs <- rename(dat_new_pkgs, ver = version)
(dat_new_vers <- rename(dat_new_vers, ver = name))

metad <- readr::read_csv("data/pkg_metadata.csv")

tmp <- dat_new_vers %>%
  left_join(metad) %>% 
  mutate(release_url = as.character(glue(template_release)))

release_urls <- unlist(unname(Map(function(a, b, c) {
  if (crul::ok(a)) a else sprintf(news_release, b, c)
}, tmp$release_url, tmp$owner, tmp$pkg)))
tmp$release_url <- release_urls

tmp %>% 
  mutate(description = glue(template)) %>% 
  .$description
# copy from the above

tmp %>% 
  mutate(description = sprintf(template_sprintf, ver, pkg, pkg_brief_description, release_url, docs_name, docs_url, pkg, pkg)) %>% 
  .$description %>% 
  cat(sep = "\n")
