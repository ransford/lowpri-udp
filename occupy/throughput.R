library(ggplot2)

args <- commandArgs(TRUE)
csvfile <- args[[1]]
interval <- as.double(args[[2]])
pdffile <- args[[3]]

df <- read.csv(csvfile, header=T)
df$time_s <- seq(0, 10000, by=0.5)[1:length(df$tput)]
summary(df)

p <- ggplot(df, aes(x=time_s, y=tput)) +
  geom_point() +
  geom_line() +
  xlab("Time since start of trace (seconds)") +
  ylab("Throughput (bytes/second)") +
  ggtitle(paste("Throughput vs. Time for", csvfile))

ggsave(p, filename=pdffile, width=6, height=4, units='in')
