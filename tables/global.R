# Load packages
if (!require("pacman")) install.packages("pacman")
pacman::p_load(data.table, extremevalues)

## Load data
data <- read.csv("../imoveis_pel.csv", sep = ";", dec = ",")
data <- data.table(data)

## Remove some NAs
data$preco <- as.numeric(as.character(data[,preco]))
data$quartos <- as.numeric(as.character(data[,quartos]))
data$suites <- as.numeric(as.character(data[,suites]))
data$vagas <- as.numeric(as.character(data[,vagas]))
data$area <- as.numeric(as.character(data[,area]))
data <- data[preco != "NA"]
data <- data[area != "NA"]
data <- data[suites == "NA", suites := 0]
data <- data[vagas == "NA", vagas := 0]
data <- data[,preco := preco/1000]

# Remove outliers
outs <- apply(data[,.(preco,quartos,suites,vagas,area)], 2, getOutliers)
outs_ind <- list()
for (i in 1:length(outs)) {
  outs_ind[[i]] <- outs[[i]]$iRight
}
outs_ind <- unique(unlist(outs_ind))
data <- data[!outs_ind]

preco_bairro <- data[,.(
  media=mean(preco),
  minimo=min(preco),
  maximo=max(preco),
  N=length(preco)),
  by=bairro]
