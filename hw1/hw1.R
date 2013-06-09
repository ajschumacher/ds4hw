
###
# Step one: Load and process data
###

# Pull in the data from github at the command line:
# git clone git@github.com:ajschumacher/NYCattends.git

# Load this package to parse XML:
# install.packages("XML")
library(XML)

filenames <- list.files(path="NYCattends", pattern="2013[0-9]{4}\\.xml$")
attd <- NULL
for (filename in filenames) {
  # where are we in this process?
  print(filename)
  # read file as text
  raw_xml <- readLines(paste("NYCattends/", filename, sep=''))
  # remove non-printing characters
  sane_xml <- gsub('[^[:graph:]]', ' ', raw_xml)
  # transform to data.frame
  day_attd <- xmlToDataFrame(sane_xml, stringsAsFactors=FALSE)
  # select just total row
  day_total <- subset(day_attd, DBN=='TOTAL')
  # keep track of how many schools reported
  day_total$reporting <- nrow(day_attd)
  # attach another day's citywide average attendance data
  attd <- rbind(attd, day_total)
}

# add column with numeric (and missing) values
attd$pct <- as.numeric(attd$ATTN_PCT)

# add date, week, and day-of-week columns
attd$date <- strptime(attd$ATTN_DATE_YMD, format='%Y%m%d')
attd$week <- as.numeric(strftime(attd$date, '%W'))
attd$day <- as.numeric(strftime(attd$date, '%w'))  # 1 is Monday

# Filter out unreasonable data
# (exclude days reported in error)
good_attd <- subset(attd, day %in% 1:5 & reporting > 1000)


###
# Step two: Visualize data
###

# Load this package to create nice graphs:
# install.packages("ggplot2")
library(ggplot2)
# And this package to make nice labels:
# install.packages("scales")
library(scales)

p <- ggplot(data=good_attd) + aes(x=as.factor(day)) + aes(y=pct/100)
p <- p + geom_violin(color="white", fill="grey", alpha=0.6)
p <- p + geom_point(position=position_jitter(width=0.1, height=0))
p <- p + ylim(c(0.82, 0.94))
p <- p + scale_y_continuous(limits=c(0.82, 0.94), breaks=seq(from=0.82, to=0.94, by=0.04), labels=percent)
p <- p + scale_x_discrete(labels=c("Monday","Tuesday","Wednesday","Thursday","Friday"))
p <- p + xlab("") + ylab("") + ggtitle("NYC Citywide Public School Attendance\n2013 March 15 - 2013 June 7")
p <- p + theme_bw()
p

# Write to disk
png(filename="hw1.png", width=600, height=480)
p
dev.off()
