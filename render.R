# render

setwd("/Users/nehrebeckiwp.pl/Desktop/RR/RR_MNehrebecki_APartyga_MSobala")

# We need to load the necessary packages if we're operating through an R script.

library(rmarkdown)

# See https://www.rdocumentation.org/packages/rmarkdown/versions/2.6/topics/render for more

centries=21
for(i in 4:centries)
{
  rmarkdown::render('project.Rmd',
                    output_file = paste0('project.Rmd_centries_', i, '.html'),   
                    params = list(centries = i))
}

