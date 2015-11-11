library(ggplot2)
library(tidyr)

data <- read.table("timeouts.csv", header=T, sep=",")

theme_set(theme_bw())
g <- ggplot(data, aes(x=x, y=y))
g <- g + geom_point(size=1) 
quartz(type="pdf", file="timeouts.pdf", dpi=100, width=6, height=4.5)
plot(g)
dev.off()
