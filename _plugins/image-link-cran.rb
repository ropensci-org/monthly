# Title: image-link-cran.rb
# Author: Scott Chamberlain, @sckottie
# Licence: CC0
# Description: Creates image with a hyperlink to the package on CRAN.
# 
# Configuration:
#   Specify your package name below in the filter
# 
# Example use:
#
# {{ "rdflib" | image_cran }} # <a target="_blank" href="https://cran.rstudio.com/web/packages/rdflib"><img src="../assets/img/octicon-package.png" width="25" style="border-radius: 6px 6px 6px 6px"></a>

module Jekyll
  module CranImageUrl
    def image_cran(input)
      x = input.to_s
      "<a target='_blank' href='https://cran.rstudio.com/web/packages/"+ x + "'><img src='../assets/img/octicon-package.png' width='25' style='border-radius: 6px 6px 6px 6px'></a>"
    end
  end
end
Liquid::Template.register_filter(Jekyll::CranImageUrl)
