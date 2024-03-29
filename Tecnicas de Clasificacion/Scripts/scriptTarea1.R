########################################################################################################
## Class Date: 08/11/2019
## Author:     José María Álvarez Silva
## School:     CUNEF
## Class:      Clasification Techniques
## Assigment:  Tarea 1
## Language:   Spanish
##
########################################################################################################
## Técnicas de clasificación
########################################################################################################
## Tarea 1 #############################################################################################
##     Análisis Discriminante y Árboles de Clasificación

## Propósito ###########################################################################################
##     Análisis Discriminante y Árboles de Clasificación para clasificar las solicitudes de crédito

## Paquetes ############################################################################################
##
library(ggplot2)
library(dplyr)
library(corrplot)
library(gridExtra)
library(ggpubr)
library(car)
library(MASS)
library(tree)
library(rpart)
library(rpart.plot)


install.packages("remotes")
remotes::install_github("PeterVerboon/lagnetw")
library(lagnetw)



## Dataset #############################################################################################
##
datos <- read.csv("Data/Datos tarea1.csv")[,-c(10,11)]

## data wrangling

datosNum <- datos

tipoFunct <- function(x){
  switch(as.character(x), 
         "Bajo riesgo" = {
           return(1)
         },
         "Riesgo medio" = {
           return(2)
         },
         "Alto riesgo" =
         {
           return(3)
         }
  )
}

datosNum$TIPO <- sapply(datos$TIPO, tipoFunct)

sexoFunct <- function(x){
  switch(as.character(x), 
         "HOMBRE" = {
           return(1)
         },
         {
           return(2)
         }
  )
}

datosNum$Sexo <- sapply(datos$Sexo, sexoFunct)

ecFunct <- function(x){
  switch(as.character(x), 
         "CASADO" = {
           return(1)
         },
         {
           return(2)
         }
  )
}

datosNum$EC <- sapply(datos$EC, ecFunct)

aversionFunct <- function(x){
  switch(as.character(x), 
         "BAJO" = {
           return(1)
         },
         "MEDIO" = {
           return(2)
         },
         {
           return(3)
         }
  )
}

datosNum$A <- sapply(datos$A, aversionFunct)
  
  

## Código ##############################################################################################
##

## Análisis descriptivo ################################################################################


## Funcion Graficar
analisisGrafico <- function(data, Character, column, binw = 1){
  
  data <- data[,c(1,column)]
  colnames(data) <- c("TIPO", "I")
  
  p1 <- ggplot(data = data) +
    geom_boxplot(aes(TIPO, I, color = TIPO)) +
    ylab(Character) + xlab("") +
    theme(axis.text.x = element_text(angle = 90))
  p2 <- ggplot(data = data, aes(I)) +
    geom_histogram(aes(y = ..density.., fill = ..count..), binwidth = binw, color = "white") +
    xlab(Character) +
    geom_density(fill = "steelblue", alpha = 0.5, color = "white") + 
    theme(legend.position = "None") 
  p3 <- ggplot(data = data, aes(color = TIPO, fill = TIPO)) +
    geom_density(data = (filter(data, TIPO == "Alto riesgo")), aes(I), alpha = 0.5) +
    geom_density(data = (filter(data, TIPO == "Bajo riesgo")), aes(I), alpha = 0.5) +
    geom_density(data = (filter(data, TIPO == "Riesgo medio")), aes(I), alpha = 0.5) +
    xlab(Character) + 
    theme(legend.position = "None")
  
  grid.arrange(
    p1, p2, p3,
    widths = c( 1, 1),
    top = text_grob(Character),
    layout_matrix = rbind(c(1, 2),
                          c(1, 3))
  )
}

##### 

str(datos)

scatterplotMatrix(datosNum[,-c(1,4,5,9)]) ## sólo variables numéricas

## Tipo
ggplot(data = datos) + geom_bar(aes(TIPO, color = TIPO, fill = TIPO))

table(datos$TIPO)

prop.table(table(datos$TIPO))

## Ingreso - I (miles de euros)
analisisGrafico(data = datos, "Ingreso", 2, binw = 1)

t.test(filter(datos, TIPO == "Alto riesgo")$I, filter(datos, TIPO == "Bajo riesgo")$I)
t.test(filter(datos, TIPO == "Alto riesgo")$I, filter(datos, TIPO == "Riesgo medio")$I)
t.test(filter(datos, TIPO == "Riesgo medio")$I, filter(datos, TIPO == "Bajo riesgo")$I)

shapiro.test(datos$I)

shapiro.test(filter(datos, TIPO == "Alto riesgo")$I)
shapiro.test(filter(datos, TIPO == "Bajo riesgo")$I)
shapiro.test(filter(datos, TIPO == "Riesgo medio")$I)

## Edad
analisisGrafico(data = datos, "Edad", 3, binw = 5)

t.test(filter(datos, TIPO == "Alto riesgo")$Edad, filter(datos, TIPO == "Bajo riesgo")$Edad)
t.test(filter(datos, TIPO == "Alto riesgo")$Edad, filter(datos, TIPO == "Riesgo medio")$Edad)
t.test(filter(datos, TIPO == "Riesgo medio")$Edad, filter(datos, TIPO == "Bajo riesgo")$Edad)

shapiro.test(datos$Edad)

shapiro.test(filter(datos, TIPO == "Alto riesgo")$Edad)
shapiro.test(filter(datos, TIPO == "Bajo riesgo")$Edad)
shapiro.test(filter(datos, TIPO == "Riesgo medio")$Edad)

## Sexo
ggplot(datos, aes(x = Sexo, fill = TIPO)) +
  geom_bar(position = "dodge")

table(datos$TIPO, datos$Sexo)

prop.table(table(datos$TIPO, datos$Sexo))

## Estado Civil - EC
ggplot(datos, aes(x = EC, fill = TIPO)) +
  geom_bar(position = "dodge")

table(datos$TIPO, datos$EC)

prop.table(table(datos$TIPO, datos$EC))

## Hijos - H
analisisGrafico(data = datos, "Hijos", 6, binw = 1)

t.test(filter(datos, TIPO == "Alto riesgo")$H, filter(datos, TIPO == "Bajo riesgo")$H)
t.test(filter(datos, TIPO == "Alto riesgo")$H, filter(datos, TIPO == "Riesgo medio")$H)
t.test(filter(datos, TIPO == "Riesgo medio")$H, filter(datos, TIPO == "Bajo riesgo")$H)

shapiro.test(datos$H)

shapiro.test(filter(datos, TIPO == "Alto riesgo")$H)
shapiro.test(filter(datos, TIPO == "Bajo riesgo")$H)
shapiro.test(filter(datos, TIPO == "Riesgo medio")$H)

## Patrimonio - P (miles de euros)
analisisGrafico(data = datos, "Patrimonio", 7, binw = 5)

t.test(filter(datos, TIPO == "Alto riesgo")$P, filter(datos, TIPO == "Bajo riesgo")$P)
t.test(filter(datos, TIPO == "Alto riesgo")$P, filter(datos, TIPO == "Riesgo medio")$P)
t.test(filter(datos, TIPO == "Riesgo medio")$P, filter(datos, TIPO == "Bajo riesgo")$P)

shapiro.test(datos$P)

shapiro.test(filter(datos, TIPO == "Alto riesgo")$P)
shapiro.test(filter(datos, TIPO == "Bajo riesgo")$P)
shapiro.test(filter(datos, TIPO == "Riesgo medio")$P)

## Ratio (endeudamiento/patrimonio) - R
analisisGrafico(data = datos, "Ratio Deuda/Pat", 8, binw = 5)

t.test(filter(datos, TIPO == "Alto riesgo")$R, filter(datos, TIPO == "Bajo riesgo")$R)
t.test(filter(datos, TIPO == "Alto riesgo")$R, filter(datos, TIPO == "Riesgo medio")$R)
t.test(filter(datos, TIPO == "Riesgo medio")$R, filter(datos, TIPO == "Bajo riesgo")$R)

shapiro.test(datos$R)

shapiro.test(filter(datos, TIPO == "Alto riesgo")$R)
shapiro.test(filter(datos, TIPO == "Bajo riesgo")$R)
shapiro.test(filter(datos, TIPO == "Riesgo medio")$R)

## Aversión al Riesgo - A
ggplot(datos, aes(x = A, fill = TIPO)) +
  geom_bar(position = "dodge")

table(datos$TIPO, datos$A)

prop.table(table(datos$TIPO, datos$A))


## Correlación

corrplot.mixed(cor(datosNum))

corrplot.mixed(cor(datosNum[,-c(1,4,5,9)])) ## sólo variables númericas

## Análisis Dsicriminante ###########################################################################
##

## Modelo 1 con todas las variable 

ldaModel1 <- lda(TIPO ~ . ,datosNum)

ldaModel1

ldaModel1$scaling

## Matriz de Confusión
matConf1 <- table(predict(ldaModel1)$class, datosNum$TIPO)
matConf1
sum(diag(matConf1))/sum(matConf1)

## Histograma de LDA
lda.values1 <- predict(ldaModel1)

ldahist(data = lda.values1$x[,1], g = datosNum$TIPO) ## LDA1
ldahist(data = lda.values1$x[,2], g = datosNum$TIPO) ## LDA2

plot(x[,2]~x[,1], col = addTrans(class,100), pch = 19, cex = 2, data = lda.values1,
     ylab = "LDA2", xlab = "LDA1") 
text(x[,2]~x[,1], labels = datosNum$TIPO, data = lda.values1, cex = 0.9, font = 2, pos = 4)

## Modelo 2 con variables numericas  

ldaModel2 <- lda(TIPO ~ . ,datosNum[,-c(4,5,9)])

ldaModel2

ldaModel2$scaling

## Matriz de Confusión
matConf2 <- table(predict(ldaModel2)$class, datosNum$TIPO)
matConf2
sum(diag(matConf2))/sum(matConf2)

## Histograma de LDA
lda.values2 <- predict(ldaModel2)

ldahist(data = lda.values2$x[,1], g = datosNum$TIPO) ## LDA1
ldahist(data = lda.values2$x[,2], g = datosNum$TIPO) ## LDA2

plot(x[,2]~x[,1], col = addTrans(class,100), pch = 19, cex = 2, data = lda.values2,
     ylab = "LDA2", xlab = "LDA1") 
text(x[,2]~x[,1], labels = datosNum$TIPO, data = lda.values2, cex = 0.9, font = 2, pos = 4)

## Modelo 3 con variables numericas (medias distintas) 

ldaModel3 <- lda(TIPO ~ . ,datosNum[,c(1,2,3,8)])
## las variables que más se diferencian en medias por tipo son I, Edad y R.

ldaModel3

ldaModel3$scaling
  
## Matriz de Confusión
matConf3 <- table(predict(ldaModel3)$class, datosNum$TIPO)
matConf3
sum(diag(matConf3))/sum(matConf3)

## Histograma de LDA
lda.values3 <- predict(ldaModel3)

ldahist(data = lda.values3$x[,1], g = datosNum$TIPO) ## LDA1
ldahist(data = lda.values3$x[,2], g = datosNum$TIPO) ## LDA2

plot(x[,2]~x[,1], col = addTrans(class,100), pch = 19, cex = 2, data = lda.values3,
     ylab = "LDA2", xlab = "LDA1") 
text(x[,2]~x[,1], labels = datosNum$TIPO, data = lda.values3, cex = 0.9, font = 2, pos = 4)


## Árbol de clasificación #############################################################################
##

set.seed(1234)

## Definimos una muestra aleatoria de aprendizaje del árbol

train <- sample(nrow(datosNum), 0.8*nrow(datosNum))

## Data frame para la muestra de aprendizaje y otro para la muestra de validación

datos.train <- datosNum[train,]
datos.valid <- datosNum[-train,]

## Vemos la distribución de ambas muestras y comprobamos que están balanceadas

prop.table(table(datos.train$TIPO))
prop.table(table(datos.valid$TIPO))

## Árbol

treeTIPO <- rpart(TIPO ~ ., data = datos.train, method = "class",
                  parms = list(split = "information"))
summary(treeTIPO)

treeTIPO$cptable

prp(treeTIPO, type = 2, extra = 104,
    fallen.leaves = TRUE, main = "Decision Tree")

## Podado del arbol - no hay necesidad de podar el árbol ya el minino xerror + xstd (correspondiente)
##  no supera al siguente xerror.

# Prediccion con la muestra de validaci?n

arbol.pred <- predict(treeTIPO, datos.valid, type = "class")

arbol.perf <- table(datos.valid$TIPO, arbol.pred,
                    dnn = c("Actual", "Predicted"))

arbol.perf

sum(diag(arbol.perf))/sum(arbol.perf)
