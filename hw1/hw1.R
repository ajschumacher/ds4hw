###
# Step one: Load and process data
###

# Pull in the data at the command line:
# git clone git@github.com:ajschumacher/NYCattends.git

# Load this package to parse XML:
# install.packages("XML")
library(XML)

filenames <- list.files(pattern="NYCattends/[0-9]{8}\\.xml$")
attd <- NULL
for (filename in filenames) {
  # where are we in this process?
  print(filename)
  # read file as text
  raw_xml <- readLines(filename)
  # remove non-printing characters
  sane_xml <- gsub('[^[:graph:]]', ' ', raw_xml)
  # transform to data.frame
  day_attd <- xmlToDataFrame(sane_xml, stringsAsFactors=FALSE)
  # attach new data (this is not memory-efficient but I don't care)
  attd <- rbind(attd, day_attd)
}

# add column with numeric (and missing) values
attd$pct <- as.numeric(attd$ATTN_PCT)

# add date, week, and day-of-week columns
attd$date <- strptime(attd$ATTN_DATE_YMD, format='%Y%m%d')
attd$week <- as.numeric(strftime(attd$date, '%W'))
attd$day <- as.numeric(strftime(attd$date, '%w'))

###
# Step two: Visualize data
###
