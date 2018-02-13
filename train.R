# Instalar e carregar pacotes necessarios
if (!require("pacman")) install.packages("pacman")
pacman::p_load(data.table, ggplot2, Metrics, caret, neuralnet, nnet, kernlab, xgboost)

# Carregar dados e regressoes
source("dados.R")
#source("dados_novos.R")

# Separar conjuntos train e test
set.seed(4321)
trainIndex <- createDataPartition(aptos$preco, p=.7, list=F)
trainData <- aptos[trainIndex, ]
testData <- aptos[-trainIndex, ]

# Criar variaveis do conjunto train e escalonar dados
dummiesTrain <- predict(dummyVars(~ bairro, data = trainData), newdata = trainData)
dataTrain <- data.frame(preco = trainData$preco, area = trainData$area, area2 = trainData$area^2, area3 = trainData$area^3, quartos = trainData$quartos, quartos2 = trainData$quartos^2, quartos3 = trainData$quartos^3, suites = trainData$suites, suites2 = trainData$suites^2, suites3 = trainData$suites^3, vagas = trainData$vagas, vagas2 = trainData$vagas^2, vagas3 = trainData$vagas^3, dummiesTrain[,2:ncol(dummiesTrain)])
maxs <- apply(dataTrain, 2, max)
mins <- apply(dataTrain, 2, min)
scaledTrain <- as.data.frame(scale(dataTrain, center = mins, scale = maxs - mins))
adj1 <- (max(dataTrain$preco)-min(dataTrain$preco))
adj2 <- min(dataTrain$preco)

# Funcao para computar MAE utilizando train
maeSummary <- function (data,
                        lev = NULL,
                        model = NULL) {
   out <- mae(data$obs, data$pred)  
   names(out) <- "MAE"
   out
}

# Formulas a serem utilizadas
formula1 <- preco ~ area + quartos + suites + vagas + bairro.CENTRO + bairro.FRAGATA + bairro.PORTO + bairro.TRES.VENDAS + bairro.ZONA.NORTE
formula2 <- preco ~ area + area2 + area3 + quartos + quartos2 + quartos3 + suites + suites2 + suites3 + vagas + vagas2 + vagas3 + bairro.CENTRO + bairro.FRAGATA + bairro.PORTO + bairro.TRES.VENDAS + bairro.ZONA.NORTE

# Metodo de cross validacao da funcao train
fitControl <- trainControl(method = "repeatedcv", number = 10, repeats = 10, summaryFunction = maeSummary, savePredictions = "final")

# Regressao sem polinomios
set.seed(21)
reg.linear <- train(formula1, data = scaledTrain, method = "lm", trControl = fitControl, metric = "MAE", maximize = FALSE)
reg.linear
(mse.reglinear <- mse(reg.linear$pred$obs*adj1+adj2, reg.linear$pred$pred*adj1+adj2))
(mae.reglinear <- mae(reg.linear$pred$obs*adj1+adj2, reg.linear$pred$pred*adj1+adj2))

# Regressao com polinomios
set.seed(21)
reg.poly <- train(formula2, data = scaledTrain, method = "lm", trControl = fitControl, metric = "MAE", maximize = FALSE)
reg.poly
(mse.regpoly <- mse(reg.poly$pred$obs*adj1+adj2, reg.poly$pred$pred*adj1+adj2))
(mae.regpoly <- mae(reg.poly$pred$obs*adj1+adj2, reg.poly$pred$pred*adj1+adj2))

# Rede neural com nnet
my.grid <- expand.grid(.decay = c(0.003, 0.001, 5e-4), .size = c(2, 3, 4, 5))
set.seed(21)
nnetfit <- train(formula1, data = scaledTrain, method = "nnet", maxit = 100, tuneGrid = my.grid, trace = F, lineout = 1, trControl = fitControl, metric = "MAE", maximize = FALSE)
nnetfit
plot(nnetfit)
(mse.nnet <- mse(nnetfit$pred$obs*adj1+adj2, nnetfit$pred$pred*adj1+adj2))
(mae.nnet <- mae(nnetfit$pred$obs*adj1+adj2, nnetfit$pred$pred*adj1+adj2))

# Rede neural com neuralnet (mais de uma hiden layers)
my.grid2 <- expand.grid(.layer1 = c(2, 3, 4), .layer2 = c(4, 5), .layer3 = c(0))
set.seed(21)
neuralnetfit <- train(formula1, data = scaledTrain, method = "neuralnet", tuneGrid = my.grid2, trControl = fitControl, metric = "MAE", maximize = FALSE)
neuralnetfit
plot(neuralnetfit)
(mse.neuralnet <- mse(neuralnetfit$pred$obs*adj1+adj2, neuralnetfit$pred$pred*adj1+adj2))
(mae.neuralnet <- mae(neuralnetfit$pred$obs*adj1+adj2, neuralnetfit$pred$pred*adj1+adj2))

# Linear support vector regression
set.seed(21)
svm.linear1 <- train(formula1, data = scaledTrain, method = "svmLinear", trControl=fitControl, metric = "MAE", maximize = FALSE)
svm.linear1
(mse.svmlinear1 <- mse(svm.linear1$pred$obs*adj1+adj2, svm.linear1$pred$pred*adj1+adj2))
(mae.svmlinear <- mae(svm.linear1$pred$obs*adj1+adj2, svm.linear1$pred$pred*adj1+adj2))

# Linear support vector regression com polinomios
set.seed(21)
svm.linear2 <- train(formula2, data = scaledTrain, method = "svmLinear", trControl=fitControl, metric = "MAE", maximize = FALSE)
svm.linear2
(mse.svmlinear2 <- mse(svm.linear2$pred$obs*adj1+adj2, svm.linear2$pred$pred*adj1+adj2))
(mae.svmlinear2 <- mae(svm.linear2$pred$obs*adj1+adj2, svm.linear2$pred$pred*adj1+adj2))

# Support vector regression com radial kernel
svmGrid <- expand.grid(sigma= 2^c(-10, -5, 0), C= 2^c(0:5))
set.seed(21)
svm.radial1 <- train(formula1, data = scaledTrain, method = "svmRadial", trControl=fitControl, metric = "MAE", maximize = FALSE, tuneGrid = svmGrid)
svm.radial1
plot(svm.radial1)
(mse.svmradial1 <- mse(svm.radial1$pred$obs*adj1+adj2, svm.radial1$pred$pred*adj1+adj2))
(mae.svmradial1 <- mae(svm.radial1$pred$obs*adj1+adj2, svm.radial1$pred$pred*adj1+adj2))

# Support vector regression com radial kernel e polinomios
svmGrid <- expand.grid(sigma= 2^c(-10, -5, 0), C= 2^c(0:5))
set.seed(21)
svm.radial2 <- train(formula2, data = scaledTrain, method = "svmRadial", trControl=fitControl, metric = "MAE", maximize = FALSE, tuneGrid = svmGrid)
svm.radial2
plot(svm.radial2)
(mse.svmradial2 <- mse(svm.radial2$pred$obs*adj1+adj2, svm.radial2$pred$pred*adj1+adj2))
(mae.svmradial2 <- mae(svm.radial2$pred$obs*adj1+adj2, svm.radial2$pred$pred*adj1+adj2))

# Avaliar criterios para diferentes modelos
rValues <- resamples(list(reglinear=reg.linear, regpoly=reg.poly, nnet=nnetfit, neuralnet=neuralnetfit, svmlinear=svm.linear1, svmlinear_poly=svm.linear2, svmradial=svm.radial1, svmradial_poly=svm.radial2))
rValues$values
summary(rValues)
pred_eval <- data.frame(reglinear=c(mse.reglinear, mae.reglinear),
                   regpoly=c(mse.regpoly, mae.regpoly),
                   nnet=c(mse.nnet, mae.nnet),
                   neuralnet=c(mse.neuralnet, mae.neuralnet),
                   svmlinear=c(mse.svmlinear1, mae.svmlinear1),
                   svmlinear_poly=c(mse.svmlinear2, mae.svmlinear2),
                   svmradial=c(mse.svmradial1, mae.svmradial1),
                   svmradial_poly=c(mse.svmradial2, mae.svmradial2))
rownames(pred_eval) <- c("MSE", "MAE")
pred_eval

# Criar variaveis do conjunto test e escalonar dados
dummiesTest <- predict(dummyVars(~ bairro, data = testData), newdata = testData)
dataTest <- data.frame(preco = testData$preco, area = testData$area, area2 = testData$area^2, area3 = testData$area^3, quartos = testData$quartos, quartos2 = testData$quartos^2, quartos3 = testData$quartos^3, suites = testData$suites, suites2 = testData$suites^2, suites3 = testData$suites^3, vagas = testData$vagas, vagas2 = testData$vagas^2, vagas3 = testData$vagas^3, dummiesTest[,2:6])
scaledTest <- as.data.frame(scale(dataTest, center = mins, scale = maxs - mins))

# Avaliar resultado do melhor modelo no conjunto test
pred_test <- predict(svm.radial2, newdata = scaledTest)
pred_test <- pred_test*adj1+adj2
mse(pred_test, testData$preco)
mae(pred_test, testData$preco)
View(cbind(pred_test, testData$preco))

# Observar maiores erros de previsao
## Conjunto train
pred_train <- predict(svm.radial2, newdata = scaledTrain)
pred_train <- pred_train*adj1+adj2
mse(pred_train, trainData$preco)
mae(pred_train, trainData$preco)
erro_train <- abs(pred_train - trainData$preco)
errortrain <- cbind(erro_train, pred_train, trainData)
View(errortrain[order(erro_train, decreasing = TRUE),])

## Conjunto test
erro_test <- abs(pred_test - testData$preco)
errortest <- cbind(erro_test, pred_test, testData)
View(errortest[order(erro_test, decreasing = TRUE),])


## xgboost model
   
fitControl <- trainControl(method = "repeatedcv", number = 10, repeats = 10)

Train <- as.matrix(dataTrain)[, c(-1, -3, -4, -6, -7, -9, -10, -12, -13)]
xgb_grid <- expand.grid(nrounds = 100, max_depth = 4, eta = 0.05, gamma = 0, colsample_bytree = 1, min_child_weight = 3)
set.seed(21)
xgboost_model <- train(x = Train, y = dataTrain[, "preco"], method = "xgbTree", trControl = fitControl, tuneGrid = xgb_grid)

library(mlr)
library(Matrix)
lrn = makeLearner("regr.xgboost", predict.type = "response", nrounds = 2000, max_depth = 10, eta = 0.01, min_child_weight = 5)
df <- dataTrain[, c(-3, -4, -6, -7, -9, -10, -12, -13)]
train_task = makeRegrTask(data = df, target ="preco")
fit = train(lrn, train_task)
imp = xgb.importance(fit$features, model = fit$learner.model)
# make partial dependence plot for most important feature
pd = generatePartialPredictionData(fit, train_task, imp$Feature, gridsize = 10)
plotPartialPrediction(pd)
