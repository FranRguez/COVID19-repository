
# install.packages("remotes")
# remotes::install_github("marchtaylor/sinkr")
library(sinkr)

# Streamgraph
set.seed(1)
plotStream(x, y, xlim = c(100, 400),
           ylim = c(-125, 125),
           col = hcl.colors(30, "Blues 3"),
           border = "white", lwd = 1, lty = 1)
