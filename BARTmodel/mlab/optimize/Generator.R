# Generate results

# Read in data
setwd(dir = "Desktop/Sleep Lab/BARTmodel/mlab/optimize/")
merged <- read.csv("merge_original.csv")
merged <- merged[-451, ]

subs <- unique(merged$sub)
blocks <- unique(merged$block)
for (sub in subs) {
  sub_ind <- (merged$sub == sub)
  for (block in blocks) {
    block_ind <- (merged$block == block)
    target <- merged[sub_ind & block_ind, ]
    target$sub <- 1
    fileName <- paste0("sub", sub, "_", "block", block, ".csv")
    write.csv(x = target, file = fileName, row.names = F)
  }
}
