##--------------------------------------------
##
## Final Project
##
## Class: PCE Data Science Methods Class
##
## Name: Hua (Edward) Zeng
##
##--------------------------------------------

##----Import Libraries-----

require(logging)
library(rgdal)
library(ggplot2)
library(dplyr)
library(gridExtra)
library(ggmap)
library(data.table)
library(tm)
library(wordcloud)
library(class)
library(kknn)
library(caret)

##-----Declare Functions Here-----

get_log_filename = function(){
  log_file_name = format(Sys.time(), format="Final_Project_log_%Y_%m_%d_%H%M%S.log")
  return(log_file_name)
}

# Declare the loading data function
load_data = function(datafile, logger=NA){
  data = read.csv(datafile, stringsAsFactors=FALSE)
  loginfo("Loaded Data.", logger="data_logger")
  
  # Check if any data was loaded
  if(nrow(data)==0){
    logwarn("No Data Loaded", logger="data_logger")
  }
  return(data)
}

##----Run Main Function Here----
if(interactive()){
  
  ##----Setup Test Logger-----
  log_file_name = get_log_filename()
  basicConfig()
  addHandler(writeToFile, file=log_file_name, level='INFO')

  # Set working director and load data
  loginfo("Setting wd and loading data.", logger="data_logger")
  setwd('C:/Users/Hua/Desktop/DS Course/DS350/Final Project')
  datafile = 'Restaurant_Scores_-_LIVES_Standard.csv'
  data = load_data(datafile)

  # Check for duplicates!
  duplicated(data) 
  which(duplicated(data))
  unique_data = unique(data)
  
  # Explore the dataset
  head(unique_data)
  str(unique_data)
  summary(unique_data)
  
  unique(unique_data$risk_category)
  unique(unique_data$violation_description)
  
  
  # Re-categorize  
  risk<-function(x){
    if(x==""){
      return('No Risk')
    }
    else return(as.character(x))
  }
  
  violation<-function(y){
    if(y==""){
      return('No violation')
    }
    else return(as.character(y))
  }

  
  unique_data$year<-as.numeric(format(as.Date(unique_data$inspection_date,'%m/%d/%Y'),'%Y'))
  unique_data$month<-as.numeric(format(as.Date(unique_data$inspection_date,'%m/%d/%Y'),'%m'))
  unique_data$day<-as.numeric(format(as.Date(unique_data$inspection_date,'%m/%d/%Y'),'%g'))
  unique_data$risk_category<-sapply(unique_data$risk_category,risk)
  unique_data$violation_description<-sapply(unique_data$violation_description,violation)
  
  summary(unique_data)
  hist(unique_data$inspection_score, main="SF Resturant Health Score", xlab="Health Score")
  aov1 <- aov(inspection_score ~ risk_category, data=unique_data)
  summary(aov1)
  model.tables(aov1, "means")
  TukeyHSD(aov1)
  
  #aggregate by (year,month,risk) --> count the rows
  unique_data2 = as.data.frame(unique_data %>% group_by(year, month, risk_category) %>% summarise(number = n()))
  #aggregate by year and risk --> sum the # of risk
  perYear = as.data.frame(unique_data2 %>% group_by(risk_category, year) %>% select(number) %>% summarise(tot=sum(number))) 
  ggplot(data=perYear, aes(x=year, y=tot, fill=risk_category)) + geom_bar(stat="identity",position="dodge") + ylab("Number of violations") + geom_text(aes(label=tot), position=position_dodge(width=0.9), vjust=-0.25)
  
  as.data.frame(unique_data2 %>% group_by(year) %>% filter(risk_category!='No Risk') %>% select(number) %>% summarise(tot_risk=sum(number)))

  unique_data2$month_name<-month.abb[unique_data2$month]
  lev<-unique(unique_data2$month_name)
  unique_data2$ordered_month_name <- factor(unique_data2$month_name, levels = lev)
  #heatmap per year
  ggplot(data=unique_data2, aes(year,ordered_month_name)) + geom_tile(aes(fill = number),colour = "white") + scale_fill_gradient(low = "white",high = "red") + facet_grid(~risk_category)
  
  tt<-map_data('county', 'california,san francisco')
  sfMap<-ggplot() + geom_polygon(data=tt, aes(x=long, y=lat, group = group),colour='white',alpha=.5)
 
  highRisk<-filter(unique_data,risk_category=='High Risk')
  highRisk<-na.omit(highRisk)
  sfMap + stat_density2d(aes(x = business_longitude, y = business_latitude, fill = ..level..),size = 1, bins = 10, data = highRisk) + geom_point(data=highRisk, aes(x = business_longitude, y = business_latitude)) + facet_wrap(~year)

  noRisk<-filter(unique_data,risk_category=='No Risk')
  noRisk<-na.omit(noRisk)
  sfMap + stat_density2d(aes(x = business_longitude, y = business_latitude, fill = ..level..),size = 1, bins = 10, data = noRisk) + geom_point(data=noRisk, aes(x = business_longitude, y = business_latitude)) + facet_wrap(~year)
  
  
  # Create dummies
  unique_data$High_Risk = ifelse(unique_data$risk_category == "High Risk", 1, 0)
  unique_data$Moderate_Risk = ifelse(unique_data$risk_category == "Moderate Risk", 1, 0)
  unique_data$Low_Risk = ifelse(unique_data$risk_category == "Low Risk", 1, 0)
  unique_data$No_Risk = ifelse(unique_data$risk_category == "No Risk", 1, 0)
  
  df = unique_data[!is.na(unique_data["inspection_score"]),]
  df2 = data.table(df)
  sum_data = df2[, list(Health_Score=mean(inspection_score),
                                     HR_total=sum(High_Risk),
                                     MR_total=sum(Moderate_Risk),
                                     LR_total=sum(Low_Risk),
                                     NR_total=sum(No_Risk)),
                              by=business_name]  
  sum_data$Total_N_Risk = sum_data$HR_total + sum_data$MR_total +sum_data$LR_total 
  summary(sum_data)
  attach(sum_data)
  
  
  qplot(Health_Score, data=sum_data, geom="histogram")
  h <- ggplot(sum_data, aes(x=Health_Score))
  h + geom_histogram(binwidth=1.5, aes(fill = ..count..)) +
    scale_fill_gradient("Count", low = "grey", high = "blue")
  
  r <- ggplot(sum_data, aes(x=Total_N_Risk))
  r + geom_histogram(binwidth=1.5, aes(fill = ..count..)) +
    scale_fill_gradient("Count", low = "grey", high = "blue")
  
  par(mfrow=c(2,2)) 
  hist(sum_data$HR_total)
  hist(sum_data$MR_total)
  hist(sum_data$LR_total)
  hist(sum_data$NR_total)

  par(mfrow=c(1,1)) 
  df=data.frame(sum_data)
  head(df[order(-df["Health_Score"],df["Total_N_Risk"]),], 200)
  perfect_list = filter(filter(df, Health_Score == 100), Total_N_Risk==0)
  dim(perfect_list)
  
  # linear regression:
  health_score_model = lm(Health_Score ~ Total_N_Risk, data = sum_data)
  summary(health_score_model)

  x = sum_data$Total_N_Risk
  y = sum_data$Health_Score
  
  plot(x ,y, main="Total Number of Risk Events vs. Health Score", 
       xlab = "Total Number of Risk Events", ylab = "Health Score", pch = 16)
  
  best_fit1 = lm(y ~ x)
  abline(best_fit1, lwd = 2, col = "red") 
  
  # Health score vs location
  sum_data_loc = df2[, list(Health_Score=mean(inspection_score),
                        latitude=mean(business_latitude),
                        longitude=mean(business_longitude),
                        HR_total=sum(High_Risk),
                        MR_total=sum(Moderate_Risk),
                        LR_total=sum(Low_Risk),
                        NR_total=sum(No_Risk)
  ),
  by=business_name]  
  sum_data_loc$Total_N_Risk = sum_data_loc$HR_total + sum_data_loc$MR_total +sum_data_loc$LR_total 
  sum_data_loc = sum_data_loc[complete.cases(sum_data_loc),]
  summary(sum_data_loc)
  attach(sum_data_loc)

  health_score_loc_model = lm(Health_Score ~ latitude + longitude, data = sum_data_loc)
  summary(health_score_loc_model)

  # Time Series Autoregressive  
  # Create linear model:
  myvars <- c("inspection_score", "High_Risk", "Moderate_Risk", "Low_Risk", "No_Risk", "month")
  newdata <- unique_data[myvars]
  all_unique_data =  data.table(newdata[complete.cases(newdata),])
  sum_data_month = all_unique_data[, list(Health_Score=mean(inspection_score),
                        HR_total=sum(High_Risk),
                        MR_total=sum(Moderate_Risk),
                        LR_total=sum(Low_Risk),
                        NR_total=sum(No_Risk)),
                 by=month]
  sum_data_month=sum_data_month[order(sum_data_month$month),]
  
  HC_1_periods_ago2 = sapply(1:nrow(sum_data_month), function(x){
    if(x <= 1){
      return(sum_data_month$Health_Score[1])
    }else{
      return(sum_data_month$Health_Score[x-1])
    }
  })
  sum_data_month$one_month_ago = HC_1_periods_ago2
  
  hc_model = lm(Health_Score ~ HR_total + MR_total + LR_total+ NR_total + one_month_ago + month 
                  , data = sum_data_month)
  summary(hc_model)
  
  avg_error <- function(x) 
    sqrt(mean(x$residuals^2))
  
  avg_error(summary(hc_model))
  
  # Look at plot
  plot(sum_data_month$month, sum_data_month$Health_Score, type="l", lwd=2, main="Health Score",
       xlab="Month", ylab="Health Score")
  lines(sum_data_month$month, hc_model$fitted.values, lwd=2, lty=8, col="red")
  
  all_unique_data1 =  data.table(unique_data[complete.cases(unique_data),])
  all_unique_data1$risk_category = factor(all_unique_data1$risk_category)
  m = nrow(all_unique_data1)
  imp = sample(1:m, m/3, prob = rep(1/m,m)) 
  all_unique_data1.train = all_unique_data1[-imp,] 
  all_unique_data1.test = all_unique_data1[imp,]

  model = train.kknn(risk_category ~ inspection_score+business_latitude+business_longitude, data = all_unique_data1, kmax = 20)
  model

  myvars = c("risk_category", "inspection_score", "business_latitude", "business_longitude")
  all_unique_data1.test2=data.frame(all_unique_data1.test)[myvars]
  prediction = predict(model, all_unique_data1.test2)
  prediction
  xtab = table(all_unique_data1.test$risk_category, prediction)
  xtab
  confusionMatrix(xtab)
  
  
  ##-----Text Corpus-----
  # tell R that our collection of reviews is really a corpus.
  violation_corpus = Corpus(VectorSource(unique_data$violation_description))
  
  # The following takes another minute to run.
  violation_document_matrix = TermDocumentMatrix(violation_corpus)
  violation_term_matrix = DocumentTermMatrix(violation_corpus)
  
  # These two matrices are transposes of each other
  dim(violation_term_matrix)
  dim(violation_document_matrix)
  
  # Too large to write out, so look at a part of it
  inspect(violation_term_matrix[1:5,1:5])
  
  # Too large and too sparse, so we remove sparse terms:
  violation_term_small = removeSparseTerms(violation_term_matrix, 0.995) # Play with the % criteria, start low and work up
  dim(violation_term_small)
  inspect(violation_term_small[1:5,1:5])
  
  # Look at frequencies of words across all documents
  word_freq = sort(colSums(as.matrix(violation_term_small)))
  hist(word_freq[word_freq<10000], breaks=35)
  
  # Most common:
  tail(word_freq, n=10)
  
  # Least Common:
  head(word_freq, n=10)
  
  
  ##-----Word Clouds------
  set.seed(42)
  words_for_cloud = tail(word_freq, n= 50)
  
  wordcloud(names(words_for_cloud), words_for_cloud, colors=brewer.pal(6, "Dark2"))
  
  
  loginfo(paste('The p-value of the ANOVA test of health score by risk category is:', 0.0001265))
  loginfo(paste('The residual standard error of monthly average health score model is:', 0.2825))
  loginfo(paste('The average error by month of monthly average health score is:', avg_error(summary(hc_model))))
  loginfo(paste('The estimated slope of linear regression of total number of risk vs. health score is',
                summary(health_score_model)$coefficients[2]))
  loginfo(paste('The p value of estimated slope of linear regression of total number of risk vs. health score is:',
                'less than', 2e-16))
  loginfo(paste('The estimated slope of linear regression of latitude vs. health score is',
                summary(health_score_loc_model)$coefficients[2]))
  loginfo(paste('The p value of estimated slope of linear regression of latitude vs. health score is:',
                2.48e-05))
  loginfo(paste('The estimated slope of linear regression of longitude vs. health score is',
                summary(health_score_loc_model)$coefficients[3]))
  loginfo(paste('The p value of estimated slope of linear regression of longitude vs. health score is:',
                2.55e-05))
}
