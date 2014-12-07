#!/usr/bin/env Rscript

library(ggplot2)
library(reshape2)

args <- commandArgs(TRUE)
csvfile <- args[[1]]
pdfprefix <- args[[2]]

df <- as.data.frame(read.csv(csvfile))
df$n <- seq(length(df[[1]]))
m <- melt(df, id=c("n"))

p <- ggplot(m, aes(x=n, y=value, colour=variable)) + geom_point() +
  facet_wrap(~variable, ncol=1, nrow=length(df)-1) +
  ylab('Occupied (%)') +
  scale_color_discrete(guide=FALSE) +
  ggtitle(csvfile)

h <- ggplot(m, aes(x=value, fill=variable)) +
  geom_histogram(binwidth=1) +
  facet_wrap(~variable, ncol=1, nrow=length(df)-1) +
  xlab('Occuped (%)') +
  scale_color_discrete(guide=FALSE) +
  ggtitle(csvfile)

ggsave(p, filename=paste(pdfprefix, '_raw.pdf', sep=''))
ggsave(h, filename=paste(pdfprefix, '_histo.pdf', sep=''))
