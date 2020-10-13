library(dplyr)
library(jsonlite)
library(xml2)
library(parsedate)
library(glue)

last <- function(x) x[[length(x)]]

# get latest 2months/2min post
blog_feed <- "https://ropensci.org/blog/index.xml"
blogs <- read_xml(blog_feed)
kids <- xml_find_all(blogs, "//item")
df_all_blogs <- dplyr::bind_rows(
  lapply(xml2::as_list(kids), unlist, recursive=FALSE))
df_all_blogs$pubDate <- parse_date(df_all_blogs$pubDate)
df_2m2m <- filter(df_all_blogs, grepl("2 Months", title))
date_last_2m2m <- df_2m2m[1,]$pubDate

# todays date of writing/publishing 2months2min post
## assumes you want todays date - change for other date desired
date_today <- parse_date(Sys.Date()) 

# gather newsletters since last 2months2min post
news_feed <- "https://news.ropensci.org/feed.xml"
news <- read_xml(news_feed)
kidz <- xml_find_all(news, "//item")
df_news <- dplyr::bind_rows(
  lapply(xml2::as_list(kidz), unlist, recursive=FALSE))
df_news$pubDate <- parse_date(df_news$pubDate)
news_to_include <- filter(df_news, pubDate >= date_last_2m2m)
news_to_include$html <- lapply(news_to_include$description, read_html)

# 2month2min sections: new packages
# filter(news_to_include, xml_find_all(description))
new_pkgs <- lapply(news_to_include$html, xml_find_all, xpath="//h3[@id='new-packages']")
# xml_find_all(new_pkgs[[1]], "//li/preceding::h3[@id='new-packages']")
pkg_name <- function(w) {
  # z <- xml_find_all(w, "//ul/li[contains(text(), 'first version')]/a[contains(@href,'_blank')]")
  z <- xml_find_all(w, "//ul/li[contains(text(), 'first version')]/a[contains(@target, '_blank')]")
  links <- xml_attr(z, "href")
  unique(unlist(lapply(links, function(m) last(strsplit(m, "/")[[1]]))))
}
pkgs_new <- unlist(lapply(new_pkgs, pkg_name))
deets <- lapply(pkgs_new, function(z) {
  tmp <- fromJSON(file.path("http://crandb.r-pkg.org", z))
  auth <- gsub("\\s$", "", gsub("<.+", "", tmp$Maintainer))
  desc <- tmp$Title
  data.frame(pkg = z, auth = auth, desc = desc)
})
pkg_auth <- bind_rows(deets)

template_software_header <-
'## Software

{length(pkgs_new)} new peer-reviewed packages from the community are on CRAN.\n\n'
template_software_each <-
'* **[{pkg}](https://docs.ropensci.org/{pkg}/)** - {desc}. Author: {auth}'
text_new_pkgs <- paste(
  glue(template_software_header),
  paste0(glue_data(pkg_auth, template_software_each), collapse="\n")
)
cat(text_new_pkgs, sep="\n")


cat("\n\n")

# on the blog
## add main blog post technotes
df_all_blogs_latest <- filter(df_all_blogs, pubDate > date_last_2m2m)
all_posts_feed <- "https://ropensci.org/index.xml"
all_posts <- read_xml(all_posts_feed)
kids <- xml_find_all(all_posts, "//item")
df_all_posts <- dplyr::bind_rows(
  lapply(xml2::as_list(kids), unlist, recursive=FALSE))
df_all_posts$pubDate <- parse_date(df_all_posts$pubDate)
techs <- filter(df_all_posts, grepl("technotes", link), pubDate > date_last_2m2m)
posts <- bind_rows(df_all_blogs_latest, techs)

template_blog_header <- '## On the Blog\n\n'
template_blog_each <-
'* [{title}]({sub("https://ropensci.org", "", link)}) by [Jonathan Keane](/author/jonathan-keane/)'
text_blog <- paste(
  template_blog_header,
  paste0(glue_data(posts, template_blog_each), collapse="\n")
)
cat(text_blog, sep="\n")



# 2month2min sections: software review
