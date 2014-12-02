#!/usr/bin/env Rscript

library(ggplot2)

# http://www.cookbook-r.com/Manipulating_data/Summarizing_data/
## Summarizes data.
## Gives count, mean, standard deviation, standard error of the mean, and
## confidence interval (default 95%).
##   data: a data frame.
##   measurevar: the name of a column that contains the variable to be
##               summarized
##   groupvars: a vector containing names of columns that contain grouping
##              variables
##   na.rm: a boolean that indicates whether to ignore NA's
##   conf.interval: the % range of the confidence interval (default is 95%)
summarySE <- function(data=NULL, measurevar, groupvars=NULL, na.rm=FALSE,
                      conf.interval=.95, .drop=TRUE) {
  require(plyr)

  # New version of length which can handle NA's: if na.rm==T, don't count them
  length2 <- function (x, na.rm=FALSE) {
    if (na.rm) sum(!is.na(x))
    else       length(x)
  }

  # This does the summary. For each group's data frame, return a vector with
  # N, mean, and sd
  datac <- ddply(data, groupvars, .drop=.drop,
                 .fun = function(xx, col) {
                   c(N      = length2(xx[[col]], na.rm=na.rm),
                     mean   = mean   (xx[[col]], na.rm=na.rm),
                     median = median (xx[[col]], na.rm=na.rm),
                     sd     = sd     (xx[[col]], na.rm=na.rm)
                   )
                 },
                 measurevar
  )

  # Rename the "mean" column
  datac <- rename(datac, c("mean" = measurevar))

  datac$se <- datac$sd / sqrt(datac$N)  # Calculate standard error of the mean

  # Confidence interval multiplier for standard error
  # Calculate t-statistic for confidence interval:
  # e.g., if conf.interval is .95, use .975 (above/below), and use df=N-1
  ciMult <- qt(conf.interval/2 + .5, datac$N-1)
  datac$ci <- datac$se * ciMult

  return(datac)
}

udpalt <- as.data.frame(read.csv('occupancy.csv'))

ds <- summarySE(data=udpalt, measurevar="occupancy_pcnt", groupvars=c("interpkt_us", "ifaces"))

p <- ggplot(ds, aes(x=interpkt_us, y=occupancy_pcnt, colour=factor(ifaces))) +
  geom_errorbar(aes(ymin=occupancy_pcnt-se, ymax=occupancy_pcnt+se)) +
  geom_line() +
  geom_point(data=udpalt, aes(x=interpkt_us, y=occupancy_pcnt, colour=factor(ifaces))) +
  scale_colour_brewer(name="# interfaces", palette="Set1") +
  facet_wrap(~distance, ncol=2) +
  ylab('Occupancy (%)') +
  xlab('Inter-packet delay')


ggsave(p, filename='occupancy.pdf', width=6, height=6, units="in")
