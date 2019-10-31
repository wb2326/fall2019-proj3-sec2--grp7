library(caret)
load("C:/distance_train_selected_stand.RData")
load("C:/distance_test_selected_stand.RData")
load("C:/distance_train_selected_stand55.RData")
load("C:/distance_ratio_train.RData")
load("C:/distance_ratio_test.RData")
load("C:/distance_train.Rdata")

train <- function(feature_df = pairwise_data, par = NULL){

  trControl <- trainControl(method = "cv",
                          number = 20,
                          search = 'grid')

  rf_default <- train(emotion_idx ~ .,
                    data = dat_train_selected_ratio_stand55,
                    method = "rf",
                    metric = "Accuracy",
                    tuneLength = 15,
                    trControl = trControl)
  print(rf_default)


  plot(rf_default)

  grid_tuned <- expand.grid(.mtry = (1:15)) 

  rf_gridsearch <- train(emotion_idx ~ ., 
                       data = dat_train_selected_ratio_stand55,
                       method = 'rf',
                       metric = 'Accuracy',
                       tuneGrid = grid_tuned)
  print(rf_gridsearch)

  best_mtry <- 2
  store_maxnode <- list()
  tuneGrid <- expand.grid(.mtry = best_mtry)
  for (maxnodes in c(1: 10)) {
  set.seed(2305)
  rf_maxnode <- train(emotion_idx ~ .,
                      data = dat_train_selected_ratio_stand55,
                      method = "rf",
                      metric = "Accuracy",
                      tuneGrid = tuneGrid,
                      trControl = trControl,
                      importance = TRUE,
                      nodesize = 14,
                      maxnodes = maxnodes,
                      ntree = 300)
  current_iteration <- toString(maxnodes)
  store_maxnode[[current_iteration]] <- rf_maxnode
  }
  results_mtry <- resamples(store_maxnode)
  summary(results_mtry)

  store_maxtrees <- list()
  for (ntree in c(25, 50, 100, 150, 200, 300, 400, 500)) {
  set.seed(2305)
  rf_maxtrees <- train(survived~.,
                       data = data_train,
                       method = "rf",
                       metric = "Accuracy",
                       tuneGrid = tuneGrid,
                       trControl = trControl,
                       importance = TRUE,
                       nodesize = 14,
                       maxnodes = 24,
                       ntree = ntree)
  key <- toString(ntree)
  store_maxtrees[[key]] <- rf_maxtrees
  }
  results_tree <- resamples(store_maxtrees)
  summary(results_tree)

  trControl <- trainControl(method = "cv",
                          number = 20,
                          search = 'grid')
  grid_tuned <- expand.grid(.mtry = 2) 
  store_maxtrees <- list()

  rf_maxtrees <- train(emotion_idx ~ .,
                     data = dat_train_selected_ratio_stand55,
                     method = "rf",
                     metric = "Accuracy",
                     tuneGrid = grid_tuned,
                     trControl = trControl,
                     importance = TRUE,
                     nodesize = 6,
                     tuneLength = 12,
                     ntree = 300)

  print(rf_maxtrees)

#Based on the accuracy table, the accuracy rate and Kappa reache the highest when ntree = 300, trueLength = 12, nodeside = 6 and mtry = 2 which around 42% accuracy.

  set.seed(2305)
  tm_train = NA
  trControl <- trainControl(method = "cv",
                          number = 20,
                          search = 'grid')
  grid_tuned <- expand.grid(.mtry = 2) 
  tm_train <- system.time(train_final_model_rf <- train(emotion_idx ~ .,
                                                      data = dat_train_selected_ratio_stand55,
                                                      method = "rf",
                                                      metric = "Accuracy",
                                                      tuneGrid = grid_tuned,
                                                      trControl = trControl,
                                                      importance = TRUE,
                                                      nodesize = 6,
                                                      tuneLength = 12,
                                                      ntree = 300))
  save(train_final_model_rf, file="C:/Users/tony/Desktop/train_final_model_rf.RData")
  print(tm_train)

  tm_test = NA
  if(run.test){
  load(file = "C:/Users/tony/Desktop/train_final_model_rf.RData")
  tm_test <- system.time(pred <- predict(train_final_model_rf, dat_test_selected_stand_test))
  }
  accu <- mean(dat_test_selected_stand_test$emotion_idx == pred)
  cat("The accuracy of model is:", accu*100, "%.\n")
  confusionMatrix(pred, dat_test_selected_stand_test$emotion_idx)

return(model = train_final_model_rf)

}
