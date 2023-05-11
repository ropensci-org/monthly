rOpenSci Newsletter
===================

See now
- https://ropensci.org/news/ for the newsletter;
- https://github.com/ropensci/roweb3#newsletter for the instructions;
- https://ropensci.org/blog/2021/06/24/news-meta/ for some narrative;
- https://docs.ropensci.org/roblog/reference/create_newsletter_content.html that puts the content for Sendgrid on the clipboard.

------

## Old README

The rOpenSci newsletter is a Jekyll site. Each newsletter entry is in `_posts/`, with name pattern like `2020-04-02-update-2020-04-02.md`. 

Note that we're constantly moving towards more automation; the below process will be updated as changes occur.

Steps for producing each newsletter entry:

1. Copy last weeks post and change the date in the file name and yaml header for the current day.
2. Keep headers for each section but delete last weeks content.
3. "rOpenSci HQ" section: hand curated. "big" things to announce: community calls, new hires, new grants, etc.
4. "Software" section
    a. Run `make pkg_versions_prep` to prepare data for new packages and new package versions. Once that's done it updates the files in `data/newpkgs.csv` and `data/newversions.csv`. 
    b. Run `make pkg_news` to prepare actual text for package news section. The output is put in the console - copy/paste that to the appropriate section in the newsletter. A few edits may have to be made, and if there's no entry for the package in question in `data/pkg_metadata.csv` an entry will have to be made.
6. "Software Review" section: Scan through https://github.com/ropensci/software-review/issues/ and list any new submissions and any newly approved packages. See previous posts for how to format these.
7. "On the blog" section: Scan through https://ropensci.org/blog/ and https://ropensci.org/technotes/ and list any new blog posts, with author and a short description of what the post was about. Include an image if there's an obvious image to include. See previous posts for how to format these.
8. "Use Cases" section: gather new citations from https://github.com/ropenscilabs/ropensci_citations repo, put them in `data/citations-to-use.txt` (making sure to use tab-indentation, then run `make citations_prep`, which spits out a bulleted list of citations
9. "From the Forum" section: optional section to include with any links to interesting blog posts. I subscribe to a number of newsletter for different programming languages, and get ideas from those.
9. "Call For Maintainers" section: mostly stays the same; updated if any new packages that need maintainers
10. "Get involved with rOpenSci" section: stays the same, leave as is
11. "Keep up with rOpenSci" section: stays the same, leave as is
12. Before posting the newsletter, run `make check` to check the URLs. the command automatically checks the most recent post that you just created to make sure the urls are okay in the post

The `makefile` has the following make commands:

```
- check
- citations_count
- citations_prep
- pkg_versions_prep
- pkg_news
- pkg_narrative
- checklist
```

make checklist

```
rOpenSci News Checklist
❯ rOpenSci HQ
    Any rOpenSci announcements? Check for issues at https://github.com/ropensci/biweekly/issues
❯ Packages:
    new packages: ⓧ
    new versions: 12
❯ Software review (new submissions/approved)
    Check https://github.com/ropensci/software-review/issues manually
❯ On the blog (new posts): 3
    post title: 2 Months in 2 Minutes - rOpenSci News, August 2020
    post title: Developing dittodb
    post title: Scientific Name Parsing: rgnparser and namext
❯ Citations (new schol articles)
    22 citations in the last newsletter; use citations after: Davis, Z. (2020). Leaf the kids outdoors: approaches and enquiries in quantifyin ...
❯ From the forum (new topics): 1
    topic: Bar chart portraits
❯ Call for maintainers
    Any packages need a new maintainer? If so, add them to the list in this section
❯ In the news
    Any must read (non-rOpensci) blog posts we should tell readers about?
```
