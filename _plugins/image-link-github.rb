# Title: image-link-github.rb
# Author: Scott Chamberlain, @sckottie
# Licence: CC0
# Description: Creates image with a hyperlink to the package on CRAN.
# 
# Configuration:
#   Specify your package name below in the filter
# 
# Example use:
#
# {{ "rdflib" | image_github }} # <a target="_blank" href="https://github.com/ropensci/rdflib"><img src="../assets/img/github-alt.png" width="25" style="border-radius: 6px 6px 6px 6px"></a>

module Jekyll
  module ImageUrl
    def image_github(input, owner = "ropensci")
      x = input.to_s
      "<a target='_blank' href='https://github.com/" + owner + "/"+ x + "'><img src='../assets/img/github-alt.png' width='25' style='border-radius: 6px 6px 6px 6px'></a>"
    end
  end
end
Liquid::Template.register_filter(Jekyll::ImageUrl)
