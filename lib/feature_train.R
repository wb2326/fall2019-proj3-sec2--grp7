########################
### Select features ###
#######################
## https://mlr.mlr-org.com/articles/tutorial/feature_selection.html

feature_train <- function(feature_df = pairwise_data){
  ### Applies SFS algorithm for feature selection from all features from training images
  
  ### Input:
  ### - a data frame containing features
  ### Output: subset of features that have been determined to be relevant
  
  ### load libraries
  library(mlr)
  
  ### Select with SFS
  sfs_feature <- sfs(feature_df,method="lda",repet=50)
  
  return(feature_selected = sfs_feature)
}

