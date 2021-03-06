Skip to content
Search or jump to…

Pull requests
Issues
Marketplace
Explore
 
@deekshaaswal 
Learn Git and GitHub without any code!
Using the Hello World guide, you’ll start a branch, write comments, and open a pull request.


deekshaaswal
/
DonorOrg
1
10
 Code Issues 0 Pull requests 0 Actions Projects 0 Wiki Security Insights Settings
DonorOrg/MachineFaultPrediction
@deekshaaswal deekshaaswal Create MachineFaultPrediction
ad44245 on Nov 17, 2019
113 lines (105 sloc)  5.14 KB
  
#We try to predict the machine faults using SVM (Support Vector Machines)
#While we are happy to achieve an accurcy of more than 99% from our code, we would like
#to add that this isn't the complete power of SVM.
#SVM has been proven excellent classifier mechanism by many data scientists. Although it's
#high accuracy comes with high computational costs since we work in multi-dimensional planes,
#and mostly end up entering more dimensions than we started with. This is done to ensure a
#satisfactory hyperplane is achieved.
#Lucky for us Kernel functions come to our rescue. Over time many Kernel functions have been
#developed and choosing the right kernel function to deploy is a trivial task.
#The accuray of the model can be increased by choosing appropriate Kernel function.
#In our trial we compared 3 functions - "svmLinear", "svmRdaial" and "svm..."
#We got the highest accuarcy with "svmLinear" function.
#Kindly note that the accuracy of the model can be increased by using diffeerent kernel functions,
#exploring more cost values and train control list. Due to the timely nature of this competition
#we weren't able to explore as many options as we have wanted to. Hope you like our solution.
#Find the code along with comments attached below.
#Thanks and Gig'em


#We upload the required libraries.
library("caret")
library("kernlab")
library("e1071")
library("outliers")
#Setting the seed to a particular value to ensure reproducible results
set.seed(1234)
#We create a new data frame to clean the data.
clean_data <- data.frame(Try = c(1:60000))

#Changing into numeric values
for (i in c(1:172)) {
  clean_data[,i] <- as.numeric(unlist(equip_failures_training_set[,i]))
}
#Making the column headers same
colnames(clean_data) <- colnames(equip_failures_training_set)
#Replacing all NA values in columns with 0. (Except th sensor2_measure column
#because it has 77% NA values. Addingg so many imaginary value would affect the
#accuracy of the prediction model.)
for (i in c(3:172)) {
  if (i== 4){
    next()
  }
  clean_data[,i][is.na(clean_data[,i])] <- 0
}
#Taking out Id column because we don't require it in prediction model
#clean_data$id <- NULL
#We remove all the NULL values in the sensor2_measure columns.
#clean_data <- clean_data[complete.cases(clean_data),]
clean_data$sensor2_measure <- NULL

#Finding out columns with near 0 variance to take out of prediction model, as they would have least
#affect on the prediction model.
nearZeroVarianceList <- nearZeroVar(clean_data)
nearZeroVarianceList <- nearZeroVarianceList[-1]
clean_data <- clean_data[,-nearZeroVarianceList]
clean_data_1 <- clean_data[1,]
 for ( i in c(3:124)) {
   outliers <- boxplot(clean_data[,4])$out
   #x <- head(outliers[order(outliers, decreasing = T)], 5)
   clean_data_2 <- clean_data[which(clean_data[,4] %in% outliers),]
   clean_data_1 <- rbind(clean_data_1,clean_data_2)
   clean_data_1 <- clean_data_1 %>% distinct(id, .keep_all = TRUE)
   i
   length(clean_data_1$target)
 }
#We split the data into test and train dataset to first evaluate the accuracy of
#prediction model
#90% is used to train the predictive model, and 10% is used for testing processes.
trainset <- createDataPartition(y = clean_data$target, p=0.9 , list = F)
training <- clean_data[trainset,]
testing <- clean_data[-trainset,]
#Making the target column as a factor in both training and test dataset as
#required by the SVM.
training[["target"]] <- factor(training[["target"]])
testing[["target"]] <- factor(testing[["target"]])

trainControlList <- trainControl(method = "repeatedcv", number = 4, repeats = 2)
#Setting different Cost values to compare different values and select the one with highest accuracy
grid <- expand.grid(C = seq(0,1,0.25))


#Training the SVM linear model.
svm_Linear_Grid <- train(target ~., data = training, method = "svmLinear",
                         trControl=trainControlList,
                         preProcess = c("center", "scale"),
                         #tuneGrid = grid,
                         tuneLength = 10)
svm_Linear_Grid

#Predicting the test dataset, using the SVM model trained.
test_pred <- predict(svm_Linear_Grid, newdata = testing)
#Trying to find out rough accuracy of the model across the test dataset.
rough_accuracy <- confusionMatrix(test_pred, testing$target)
rough_accuracy
#Creating a new data frame to maintain consistency among the training and actual test dataset.
#Make the data transformation, which made to training dataset.
test_clean_data <- data.frame(Try = c(1:16001))
#Converting the columns to numeric values
for (i in c(1:171)) {
  test_clean_data[,i] <- as.numeric(unlist(equip_failures_test_set[,i]))
}
#Making the column headers same
colnames(test_clean_data) <- colnames(equip_failures_test_set)
#Again setting the values of NULL entries to 0.
for (i in c(2:171)) {
  test_clean_data[,i][is.na(test_clean_data[,i])] <- 0
}
#Predicting the value of the test dataset given using the trained SVM model
test_pred <- predict(svm_Linear_Grid, newdata = test_clean_data)
#Saving the results into a datarame with their respective IDs.
Ans <- data.frame(Id = c(1:16001), Target = test_pred)
#Exporting the table as csv to local machine to upload.
write.table(Ans, file = "Test_ans.csv", sep = ',', row.names = F)
© 2020 GitHub, Inc.
Terms
Privacy
Security
Status
Help
Contact GitHub
Pricing
API
Training
Blog
About
