suppressPackageStartupMessages(library(dplyr))
suppressPackageStartupMessages(library(glue))
suppressPackageStartupMessages(library(readr))

file <- "data/citations-to-use.txt"
z <- suppressMessages(readr::read_tsv(file, col_names = FALSE))
names(z) <- c("name", "doi", "citation", "img_path", "research_snippet")

# look for duplicates
if (any(duplicated(z$citation))) {
  z <- z %>% group_by(citation) %>% mutate(name = paste0(name, collapse = ",")) %>% ungroup()
  z <- z[!duplicated(z),]
}

# assign rows
z$row <- 1:NROW(z)

# make footnotes
template_fn <- '[^{row}]: {citation}'
z <- z %>% mutate(fn = glue(template_fn))

# make "Use cases" section bits
template_usecase <- '* {aut_short} used {pkg_ref} in their paper [{title}]({url}) [^{row}]'

# parse citation do author short bit
# x = z$citation[4]
parse_citation <- function(x) {
  # cat(x, sep = "\n", file = "stuff.txt")
  # on.exit(unlink("stuff.txt"))
  # json <- system("anystyle --stdout -f csl parse stuff.txt", intern = TRUE)
  json <- system(sprintf("ruby anystyle.rb '%s'", x), intern = TRUE)
  res <- jsonlite::fromJSON(json, flatten = TRUE)
  res$doi <- NULL
  res
}
parsed_citations <- lapply(z$citation, parse_citation)
pc_df <- bind_rows(parsed_citations)
pc_df$aut_short <- lapply(pc_df$author, function(w) {
  if (NROW(w) == 1) {
    w[["family"]]
  } else if (NROW(w) == 2) {
    paste(apply(w, 1, function(r) r[["family"]]), collapse = " & ")
  } else if (NROW(w) > 2) {
    paste(w[1,"family"], "_et al_.")
  }
})
# add package reference link thing
z$pkg_ref <- lapply(z$name, function(w) {
  if (!grepl(",", w)) return(sprintf("[%s][]", w))
  if (grepl(",", w)) {
    w <- strsplit(w, ",")[[1]]
    paste(vapply(w, function(x) sprintf("[%s][]", x), ""), collapse = " and ")
  }
})

# bind 2 data.frame's
z <- cbind(z, pc_df)

# fill in any missing URL's
strxt <- function(string, pattern) regmatches(string, gregexpr(pattern, string))
for (i in seq_len(NROW(z))) {
  if (is.na(z[i,"url"])) {
    z[i,"url"] <- strxt(z$citation[i], "https?://.+")[[1]]
  }
}

# make use case strings
z <- z %>% mutate(use_case = as.character(glue(template_usecase)))

# print for use
for (i in z$use_case) cat(i, sep = "\n")
for (i in z$fn) cat(i, sep = "\n")

# make package links for bottom of news
metad <- readr::read_csv("data/pkg_metadata.csv")
lnks <- unique(unlist(lapply(z$pkg_ref, function(w) {
  if (grepl("and", w)) w <- strsplit(w, " and ")[[1]]
  w <- sub("\\[\\]$", "", w)
  pkg <- gsub("\\[|\\]", "", w)
  owner <- metad[metad$pkg %in% pkg, "owner"][[1]]
  sprintf("%s: https://github.com/%s/%s", w, owner, pkg)
})))
cat(lnks, sep = "\n")
