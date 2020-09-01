library(glue)
library(crayon)
library(cli)
library(xml2)
library(fs)
suppressPackageStartupMessages(library(dplyr))

# helper functions
stract <- function(str, pattern) regmatches(str, regexpr(pattern, str))
color_numbers <- function(x) {
  stopifnot(is.numeric(x))
  if (x == 0) cli::symbol$circle_cross else crayon::red(x)
}
cl_cat_line <- function(before, after, symbol = TRUE) {
  sym <- if (symbol) crayon::magenta(cli::symbol$pointer) else ""
  cli::cat_line(paste(sym, paste(before, after, sep=": ")))
}
cl_cat_line_break <- function(before, after) {
  sym <- crayon::magenta(cli::symbol$pointer)
  cli::cat_line(paste(sym, before))
  cli::cat_line("    ", after)
}
reed_csv <- function(path) {
  suppressMessages(readr::read_csv(path))
}

# preparation
## metadata prep
posts <- dir_info("_posts/", regexp = "[0-9]{4}.+")
paths <- select(posts, path) %>% arrange(desc(path)) %>% .$path
last_few_posts <- paths[1:3]
last_few_posts_dates <- parsedate::parse_date(vapply(last_few_posts, function(z) stract(z, "[0-9]{4}-[0-9]{2}-[0-9]{2}"), ""))
if (last_few_posts_dates[1] == parsedate::parse_date(Sys.Date())) {
  last_post <- paths[2]
} else {
  last_post <- paths[1]
}
lines <- readLines(as.character(last_post), n = 5)[2:5]
title <- grep("title", lines, value = TRUE)
last_post_date <- parsedate::parse_date(stract(title, "[0-9]{4}-[0-9]{2}-[0-9]{2}"))

## packages prep
### run via makefile

## software review prep
### labels aren't used consistently and on time, so not sure much can be done progromatically

## blog prep
### blog
rss_blog <- "https://ropensci.org/blog/index.xml"
xml <- read_xml(rss_blog)
blog_dates <- parsedate::parse_date(xml_text(xml_find_all(xml, "//item//pubDate")))
blog_titles <- xml_text(xml_find_all(xml, "//item//title"))
blog_posts <- list()
if (any(blog_dates > last_post_date)) {
  blog_posts <- blog_titles[blog_dates > last_post_date]
}
### technotes
rss_technotes <- "https://ropensci.org/technotes/index.xml"
xml_tech <- read_xml(rss_technotes)
tech_dates <- parsedate::parse_date(xml_text(xml_find_all(xml_tech, "//item//pubDate")))
tech_titles <- xml_text(xml_find_all(xml_tech, "//item//title"))
tech_posts <- list()
if (any(tech_dates > last_post_date)) {
  tech_posts <- tech_titles[tech_dates > last_post_date]
}

## citations prep
newsletter_rss <- "https://news.ropensci.org/feed.xml"
xml_nl <- read_xml(newsletter_rss)
desc <- xml_text(xml_find_first(xml_nl, "//item//description"))
html_nl <- read_html(desc)
xml_find_all(html_nl, "//h2[@id=\"citations\"]")
xml_find_all(html_nl, "//ul")
fnotes <- xml_text(xml_find_all(html_nl, "//div[@class=\"footnotes\"]//li/p"))

## forum prep
suppressPackageStartupMessages(library(discgolf))
topics <- category_latest_topics("usecases")
tops <- tibble::as_tibble(topics$topic_list$topics)
tops$created_at <- parsedate::parse_date(tops$created_at)
tops <- arrange(tops, desc(created_at)) %>% select(id, title, created_at)
forum_topics <- list()
if (any(tops$created_at > last_post_date)) {
  forum_topics <- tops$title[tops$created_at > last_post_date]
}


# entries for glue
hq <- crayon::italic("Any rOpenSci announcements? Check for issues at https://github.com/ropensci/biweekly/issues")
new_packages <- color_numbers(NROW(reed_csv("data/newpkgs.csv")))
new_versions <- color_numbers(NROW(reed_csv("data/newversions.csv")))
software_review <- "Check https://github.com/ropensci/software-review/issues manually"
blog <- color_numbers(sum(length(blog_posts), length(tech_posts)))
citations <- sprintf("%s citations in the last newsletter; use citations after: %s",
  length(fnotes),
  paste0(substring(fnotes[length(fnotes)], 1, 80), " ..."))
forum <- color_numbers(length(forum_topics))
call4maintainers <- crayon::italic("Any packages need a new maintainer? If so, add them to the list in this section")
in_the_news <- crayon::italic("Any must read (non-rOpensci) blog posts we should tell readers about?")
# glue(txt)

# say it
cli::cat_line(crayon::bold(crayon::blue("\nrOpenSci News Checklist")))
cl_cat_line_break("rOpenSci HQ", glue("{hq}"))
cl_cat_line("Packages", "")
cl_cat_line("   new packages", glue("{new_packages}"), symbol = FALSE)
cl_cat_line("   new versions", glue("{new_versions}"), symbol = FALSE)
cl_cat_line_break("Software review (new submissions/approved)", glue("{software_review}"))
cl_cat_line("On the blog (new posts)", glue("{blog}"))
cl_cat_line_break("Citations (new schol articles)", glue("{citations}"))
cl_cat_line("From the forum (new topics)", glue("{forum}"))
cl_cat_line_break("Call for maintainers", glue("{call4maintainers}"))
cl_cat_line_break("In the news", glue("{in_the_news}"))
