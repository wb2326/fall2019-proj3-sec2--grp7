#############################################################
### Construct features and responses for training images  ###
#############################################################

feature_train <- function(input_list = fiducial_pt_list, index){
  
  ### Construct process features for training images 
  
  ### Input: a list of images or fiducial points; index: train index or test index
  
  ### Output: a data frame containing: 3003 features, with column names is the points and a column of label
  
  ### here is an example of extracting pairwise distances between fiducial points
  
  ### Step 1: Write a function pairwise_distance to calculate pairwise distance of items in a vector
  ### input: a 78*2 matrix(e.g. fiducial_pt_list[[1]]), output: a vector(length 78*77/2)
  pairwise_distance <- function(fiducialpoint){
    distance <- as.matrix(dist(fiducialpoint))
    pairwise_dist_feature <- c()
    for (i in 1:77) {
      pairwise_dist_feature <- c(pairwise_dist_feature,as.vector(distance[i,c((i+1):78)]))
    }
    return(pairwise_dist_feature)
  }

  ### Step 2: Apply function in Step 1 to selected index of input list, output: a feature matrix with ncol = n(n-1)/2 = 78*77/2 = 3003
  pairwise_dist_feature <- t(sapply(input_list[index], pairwise_distance))
  dim(pairwise_dist_feature) 
  
  ### Step 3: construct a dataframe containing features and label with nrow = length of index
  ### column bind feature matrix in Step 3 and corresponding features
  pairwise_data <- cbind(pairwise_dist_feature, info$emotion_idx[index])
  
  ### add column names
  column_name <- c()
  for(i in 1:77) {
    for(j in (i+1):78){
      column_name <- c(column_name,paste("point",i,"to point",j))
    }
  }
  colnames(pairwise_data) <- c(column_name, "emotion_idx")
  ### convert matrix to data frame
  pairwise_data <- as.data.frame(pairwise_data)
  ### convert label column to factor
  pairwise_data$emotion_idx <- as.factor(pairwise_data$emotion_idx)
  
  return(distance_df = pairwise_data)
}
