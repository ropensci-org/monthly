RSCRIPT = Rscript --no-init-file

check:
	${RSCRIPT} -e 'source("check_urls.R")'

citations_count:
	${RSCRIPT} -e 'source("count_citations.R")'

citations_prep:
	${RSCRIPT} -e 'source("citations-prep.R")'

pkg_versions_prep:
	${RSCRIPT} -e 'source("pkg_versions_prep.R")'

pkg_news:
	${RSCRIPT} -e 'source("generate_pkg_news.R")'
