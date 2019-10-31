test <- function(model, dat_test){

  tm_test = NA
  if(run.test){
    load(file = "C:/Users/tony/Desktop/train_final_model_rf.RData")
    tm_test <- system.time(pred <- predict(model, dat_test))
  }
  accu <- mean(dat_test$emotion_idx == pred)
  cat("The accuracy of model is:", accu*100, "%.\n")
  confusionMatrix(pred, dat_test$emotion_idx)
  
  return(pred)
}