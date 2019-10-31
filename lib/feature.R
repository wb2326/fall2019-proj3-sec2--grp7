########################################################################
### Feature construction and feature selection for  training images  ###
########################################################################


#################################################################
### Construct 6006 distance feature from fiducial point list  ###
#################################################################

feature <- function(input_list = fiducial_pt_list, index){
  
  ### Construct process features for training images 
  
  ### Input: a list of images or fiducial points; index: train index or test index

  ### Output: a data frame containing: features and a column of label
  
  ### here is an example of extracting pairwise distances between fiducial points
  ### Step 1: Write a function pairwise_dist to calculate pairwise distance of items in a vector
  pairwise_dist <- function(vec){
    ### input: a vector(length n), output: a vector containing pairwise distances(length n(n-1)/2)
    return(as.vector(dist(vec)))
  }
  
  ### Step 2: Write a function pairwise_dist_result to apply function in Step 1 to column of a matrix 
  pairwise_dist_result <-function(mat){
    ### input: a n*2 matrix(e.g. fiducial_pt_list[[1]]), output: a vector(length n(n-1))
    return(as.vector(apply(mat, 2, pairwise_dist))) 
  }
  
  ### Step 3: Apply function in Step 2 to selected index of input list, output: a feature matrix with ncol = n(n-1) = 78*77 = 6006
  pairwise_dist_feature <- t(sapply(input_list[index], pairwise_dist_result))
  dim(pairwise_dist_feature) 
  
  ### Step 4: construct a dataframe containing features and label with nrow = length of index
  ### column bind feature matrix in Step 3 and corresponding features
  pairwise_data <- cbind(pairwise_dist_feature, info$emotion_idx[index])
  ### add column names
  colnames(pairwise_data) <- c(paste("feature", 1:(ncol(pairwise_data)-1), sep = ""), "emotion_idx")
  ### convert matrix to data frame
  pairwise_data <- as.data.frame(pairwise_data)
  ### convert label column to factor
  pairwise_data$emotion_idx <- as.factor(pairwise_data$emotion_idx)
  
  return(feature_df = pairwise_data)
}


#################################################################
### Construct 3003 distance feature from fiducial point list  ###
#################################################################

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
  pairwise_data <- t(sapply(input_list[index], pairwise_distance))
  dim(pairwise_data) 
  
  ### Step 3: construct a dataframe containing features and label with nrow = length of index

  ### add column names
  column_name <- c()
  for(i in 1:77) {
    for(j in (i+1):78){
      column_name <- c(column_name,paste("point",i,"to point",j))
    }
  }
  colnames(pairwise_data) <- column_name
  ### convert matrix to data frame
  pairwise_data <- as.data.frame(pairwise_data)

  return(distance_df = pairwise_data)
}

####################################
###### Feature Normalization  ######
####################################

feature_normalization <- function(dataset){
  ### Normalize all columns in the data frame
  
  ### Input: a data.frame 
  
  ### Output: z-score normalized data frame 
  
  dataset_stand <-as.data.frame(scale(dataset))
  
  return(dataset_stand)
}

####################################
### Feature selection Round one  ###
####################################

feature_selection <- function(dataset,class){
  library(FSelectorRcpp)
  library(mlr)
  
  ### Select important features using filtering and warper from train image
  
  ### Input: a data.frame include all the possible feature (in this case the distance) and the column name of the class
  
  ### Output: column name of important features
  
  ### Step 1: Filtering
  colnames(dataset)<-make.names(colnames(dataset),unique=T)
  dat.task <- makeClassifTask(data = dataset , target = class)
  
  filtered.task <- filterFeatures(dat.task, method = "FSelectorRcpp_information.gain", abs = 500)
  
  ## Step 2: Wrapper, SFFS
  ctrl <-  makeFeatSelControlSequential(method = "sffs", alpha = 0.02)
  rdesc <- makeResampleDesc("CV", iters = 5)
  
  sfeats <- selectFeatures(learner = "classif.ksvm", task = filtered.task, resampling = rdesc, control = ctrl,show.info = FALSE)
  sfeats$x
  
  return(sfeats$x)
}

####################################
########## Calculate size  #########
####################################

feature_selection_size <- function(inputset){
  
  ### Calculate all sizes (distance*distance)
  
  inputlength <- dim(inputset)[2]
  dat_double <- c()
  column_name <- c()
  for(i in 1:(inputlength-1)){
    for (j in (i+1):inputlength){
      dat_double <- cbind(dat_double,inputset[,i]*inputset[,j])
      column_name <- c(column_name,paste("distance",i,"times distance",j))
    }
  }
  colnames(dat_double) <- column_name
  

  
  return(dat_double)
}

###############################################
########## Manually selected feature  #########
###############################################

manually_feature <- function(input_list = fiducial_pt_list,index){
  ### Manually select feature from image include the slope of eyebrow and lip
  
  ### Input: a list of images or fiducial points; index: train index or test index
  
  ### Output: a data frame containing:manually select feature features and a column of label
  
  eye_browratio_computation <- function(fiducialpoint,number1,number2,number3){
    a <- (fiducialpoint[number1,1] + fiducialpoint[number2,1])/2
    b <- (fiducialpoint[number1,2] + fiducialpoint[number2,2])/2
    if (a - fiducialpoint[number3,1] == 0) {
      ratio <- 1
    }
    else{
      ratio <- (b-fiducialpoint[number3,2])/(a-fiducialpoint[number3,1])
    }
    return(ratio)
  }
  
  ratio_computation <- function (fiducialpoint,number1,number2){
    if (fiducialpoint[number1,1]-fiducialpoint[number2,1] == 0) {
      ratio <- 1
    }
    else{
      ratio <- (fiducialpoint[number1,2]-fiducialpoint[number2,2])/(fiducialpoint[number1,1]-fiducialpoint[number2,1])
    }
    return(ratio)
  }
  
  ratio_all <- function (fiducialpoint){
    righteyebrow1<- eye_browratio_computation(fiducialpoint,20,26,19) 
    righteyebrow2<- eye_browratio_computation(fiducialpoint,21,25,19)
    righteyebrow3<- eye_browratio_computation(fiducialpoint,22,24,19) 
    righteyebrow4<- ratio_computation(fiducialpoint,23,19) 
    lefteyebrow1<- eye_browratio_computation(fiducialpoint,30,32,31) 
    lefteyebrow2<- eye_browratio_computation(fiducialpoint,29,33,31)
    lefteyebrow3<- eye_browratio_computation(fiducialpoint,28,34,31) 
    lefteyebrow4<- ratio_computation(fiducialpoint,27,31) 
    upperlip1 <- ratio_computation(fiducialpoint,52,50)
    upperlip2 <- ratio_computation(fiducialpoint,54,52)
    lowerlip1 <- ratio_computation(fiducialpoint,56,50)
    lowerlip2 <- ratio_computation(fiducialpoint,54,56)
    noseright <- ratio_computation(fiducialpoint,42,44)
    noseleft <- ratio_computation(fiducialpoint,44,46)
    return(c(righteyebrow1,righteyebrow2,righteyebrow3,righteyebrow4,
             lefteyebrow1,lefteyebrow2,lefteyebrow3,lefteyebrow4,
             upperlip1,upperlip2,lowerlip1,lowerlip2,noseright,noseleft))
  }
  
  ratio_for_all <- t(sapply(input_list[index], ratio_all))
  dim(ratio_for_all)
  column_name <- c("righteyebrow1","righteyebrow2","righteyebrow3","righteyebrow4",
                     "lefteyebrow1","lefteyebrow2","lefteyebrow3","lefteyebrow4",
                     "upperlip1","upperlip2","lowerlip1","lowerlip2","noseright","noseleft")
  colnames(ratio_for_all) <- column_name
  ### convert matrix to data frame
  ratio_for_all <- as.data.frame(ratio_for_all)

  return(ratio_for_all)
}
  




