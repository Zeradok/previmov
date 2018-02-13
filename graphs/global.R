# Load packages
if (!require("pacman")) install.packages("pacman")
pacman::p_load(data.table, extremevalues, ggplot2, plotly)

## Load data
data <- read.csv("../imoveis_pel13022018.csv", sep = ";", dec = ",")
data <- data.table(data)

## Remove some NAs
data <- data[area != "NA"]
data <- data[,preco := preco/1000]
data[,cidade := "Pelotas"]
data <- data[,cidade := droplevels(cidade)]

## Remove outliers
outs <- apply(data[,.(preco,quartos,suites,vagas,area)], 2, getOutliers)
outs_ind <- list()
for (i in 1:length(outs)) {
  outs_ind[[i]] <- outs[[i]]$iRight
}
outs_ind <- unique(unlist(outs_ind))
data <- data[!outs_ind]
data[,bairro := toupper(bairro)]
pel <- subset(data, bairro %in% names(which(table(bairro) >= 60)))

#helper function (convert vector to named list)
namel<-function (vec){
		tmp<-as.list(vec)
		names(tmp)<-as.character(unlist(vec))
		tmp
	}
