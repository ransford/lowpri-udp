library(ggplot2)

args <- commandArgs(TRUE)
csvfile <- args[[1]]
pdffile <- args[[2]]

tstampfn <- function (stampstr) {
  # input is like "32:03:03.000111"
  parts <- lapply(strsplit(stampstr, ":"), as.double)[[1]]
  return((parts[1] * 60 * 60) + (parts[2] * 60) + parts[3])
}

df <- read.csv(csvfile, header=T, stringsAsFactors=F)
df <- as.data.frame(apply(df, 1:2, tstampfn))
mean_interpkt <- mean(df$since_prev)
df$jitter <- df$since_prev - mean_interpkt
summary(df)

p <- ggplot(df, aes(x=since_start, y=jitter)) +
  geom_point() +
  geom_line() +
  geom_hline(y=0, colour="red") +
  geom_rug(sides="b", alpha=0.5, size=1.5, colour="blue") +
  xlab("Time since start of trace (seconds)") +
  ylab("Jitter (seconds)") +
  ggtitle(paste("Jitter vs. Time for", csvfile))

ggsave(p, filename=pdffile, width=6, height=4, units='in')
