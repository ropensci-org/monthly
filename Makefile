check:
	Rscript -e 'source("check_urls.R")'

citations_count:
	Rscript -e 'source("count_citations.R")'

citations_prep:
	Rscript -e 'source("citations-prep.R")'
