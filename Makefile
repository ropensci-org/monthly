RSCRIPT = Rscript --no-init-file

check:
	${RSCRIPT} -e 'source("scripts/check_urls.R")'

citations_count:
	${RSCRIPT} -e 'source("scripts/count_citations.R")'

citations_prep:
	${RSCRIPT} -e 'source("scripts/citations-prep.R")'

pkg_versions_prep:
	${RSCRIPT} -e 'source("scripts/pkg_versions_prep.R")'

pkg_news:
	${RSCRIPT} -e 'source("scripts/generate_pkg_news.R")'

pkg_narrative:
	${RSCRIPT} -e 'source("scripts/generate_pkg_narrative.R")'
