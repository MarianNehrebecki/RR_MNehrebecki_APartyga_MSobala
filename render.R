# render

setwd("/Users/magda/Desktop/uni/Masters/IV semester/RR/RRproject/RR_MNehrebecki_APartyga_MSobala")

# We need to load the necessary packages if we're operating through an R script.

library(rmarkdown)

# See https://www.rdocumentation.org/packages/rmarkdown/versions/2.6/topics/render for more

centries=21
for(i in 4:centries)
{
  rmarkdown::render('Report_new.Rmd',
                    output_file = paste0('Report_Century_', i, '.html'),   
                    params = list(centries = i))
}

