library(tidyverse)
library(readr)
library(prophet)
library(tidyquant)
library(forecast)
library(timetk)
library(googlesheets)
##################################################################################################################  
####### Function make_holiday_list   #############################################################################
##################################################################################################################  

# import the Prophet analysis module
# make a holiday list for Prophet model
make_holiday_list <- function(year_in_dat) {
  # get the first/last day of each year
  first_day_of_years <- ymd(c(sapply(year_in_dat, function(x) (as.character(paste0(x, "-01-01"))))))
  last_day_of_years  <- ymd(c(sapply(year_in_dat, function(x) (as.character(paste0(x, "-12-31"))))))
  
  # base on the first/last day of each year, get the holiday list
  holidays_of_years_start <- as.Date(unlist(map(first_day_of_years, function(x) ymd(x+days(0:1)))), origin="1970-01-01")
  holidays_of_years_end   <- as.Date(unlist(map(last_day_of_years, function(x) ymd(x+days(-1:0)))), origin="1970-01-01")
  holiday_names <- c(rep("hol_MLK", 6), 
                     rep("hol_President's Day", 6), 
                     #rep("Easter", 6), 
                     rep("hol_Memorial Day", 6*3),
                     rep("hol_Independence Day", 6), 
                     rep("hol_Independence Week", 6*5), 
                     rep("hol_Ferragosto", 6), 
                     rep("hol_Labor Day", 6*3), 
                     #rep("Columbus Day", 6), 
                     #rep("hol_Veteran Day", 6), 
                     rep("hol_International Labor Day", 6), 
                     rep("hol_Germany Unity", 6), 
                     rep("hol_Thanksgiving", 6), 
                     rep("hol_Thanksgiving Week", 6*3), 
                     rep("hol_Christmas Eve", 6),
                     rep("hol_Christmas", 6),
                     rep("hol_New Year Eve", 6),
                     rep("hol_New Year", 6), 
                     rep("hol_Chr_NY", 12)
                     #rep("Independence Day", 3), 
                     #rep("Thanksgiving", 5), 
                     #rep("Christmas Wnd", 6), 
                     #rep("NewYear Wnd", 5)
  )
  other_holidays <-         c('01/20/2014', '01/19/2015', '01/18/2016', '01/16/2017','01/15/2018','01/21/2019', # Martin Luther King, Jr.
                              '02/17/2014', '02/16/2015', '02/15/2016', '02/20/2017','02/19/2018','02/18/2019', # Washington's Birthday
                              #'04/20/2014', '04/05/2015', '03/27/2016', '04/16/2017','04/01/2018','04/21/2019', # Easter
                              '05/22/2014', '05/23/2015', '05/28/2016', '05/27/2017','05/26/2018','05/25/2019', # Memorial long weekend
                              '05/23/2014', '05/24/2015', '05/29/2016', '05/28/2017','05/27/2018','05/26/2019', # Memorial long weekend
                              '05/24/2014', '05/25/2015', '05/30/2016', '05/29/2017','05/28/2018','05/27/2019', # Memorial long weekend
                              '07/04/2014', '07/04/2015', '07/04/2016', '07/04/2017','07/04/2018','07/04/2019', # Independence day weekend
                              '07/02/2014', '07/02/2015', '07/02/2016', '07/02/2017','07/02/2018','07/02/2019', # Independence day weekend
                              '07/03/2014', '07/03/2015', '07/03/2016', '07/03/2017','07/03/2018','07/03/2019', # Independence day weekend
                              '07/05/2014', '07/05/2015', '07/05/2016', '07/05/2017','07/05/2018','07/05/2019', # Independence day weekend
                              '07/06/2014', '07/06/2015', '07/06/2016', '07/06/2017','07/06/2018','07/06/2019', # Independence day weekend
                              '07/07/2014', '07/07/2015', '07/07/2016', '07/07/2017','07/07/2018','07/07/2019', # Independence day weekend
                              '08/15/2014', '08/15/2015', '08/15/2016', '08/15/2017','08/15/2018','08/15/2019', # Ferragosto day 
                              '08/30/2014', '09/05/2015', '09/03/2016', '09/02/2017','09/01/2018','08/31/2019', # Labor day weekend
                              '08/31/2014', '09/06/2015', '09/04/2016', '09/03/2017','09/02/2018','09/01/2019', # Labor day weekend
                              '09/01/2014', '09/07/2015', '09/05/2016', '09/04/2017','09/03/2018','09/02/2019', # Labor day weekend
                              #'10/12/2014', '10/11/2015', '10/10/2016', '10/09/2017','10/08/2018','10/14/2019', # Columbus Day
                              #'11/11/2014', '11/11/2015','11/11/2016', '11/11/2017', '11/11/2018','11/11/2019', # Veteran Day
                              '05/01/2014', '05/01/2015','05/01/2016', '05/01/2017','05/01/2018','05/01/2019', # International Labor Day
                              '10/03/2014', '10/03/2015','10/03/2016', '10/03/2017','10/03/2018','10/03/2019', # Day of Germany Unity
                              '11/27/2014', '11/26/2015', '11/24/2016', '11/23/2017','11/22/2018','11/28/2019', # Thanksgiving week
                              '11/28/2014', '11/26/2015', '11/25/2016', '11/24/2017','11/23/2018','11/29/2019', # Thanksgiving week
                              '11/29/2014', '11/26/2015', '11/26/2016', '11/25/2017','11/24/2018','11/30/2019', # Thanksgiving week
                              '11/30/2014', '11/26/2015', '11/27/2016', '11/26/2017','11/25/2018','12/01/2019',  # Thanksgiving week
                              '12/24/2014', '12/24/2015', '12/24/2016', '12/24/2017', '12/24/2018', '12/24/2019', # Christmas eve
                              '12/25/2014', '12/25/2015', '12/25/2016', '12/25/2017', '12/25/2018', '12/25/2019', # Christmas
                              '12/31/2014', '12/31/2015', '12/31/2016', '12/31/2017', '12/31/2018', '12/31/2019', # new Year eve
                              '01/01/2014', '01/01/2015', '01/01/2016', '01/01/2017', '01/01/2018', '01/01/2019', # new Year
                              '12/26/2017', '12/27/2017', '12/28/2017', '12/29/2017', 
                              '12/26/2018', '12/27/2018', '12/28/2018', '12/29/2018', 
                              '12/26/2019', '12/27/2019', '12/28/2019', '12/29/2019' # Christmas_NewYear 
                              #'06/29/2019', '06/30/2019', '07/01/2019', # extra for independence day
                              #'11/23/2019', '11/24/2019', '11/25/2019', '11/26/2019', '11/27/2019', # extra Thanksgiving day
                              #'12/23/2017', '12/22/2018', '12/23/2018', '12/21/2019', '12/22/2019', '12/23/2019', # Christmas weekend
                              #'12/30/2017', '12/29/2018', '12/30/2018', '12/28/2019', '12/29/2019' # NewYear weekend
                              
  )
  other_holidays <- mdy(other_holidays)
  
  # combine holidays into a list
  holiday_list <- c(other_holidays)
  holidays <- data.frame(ds = as.Date(holiday_list), 
                         holiday = holiday_names)
  # %>% mutate(holiday = paste0("off_day_", seq_along(1:length(ds))))
  holidays
}
##################################################################################################################  
##################################################################################################################  
##################################################################################################################  

# to get the best parameters settings for Prophet model based on ProphetGrid (as listed in function below)
find_best_model_params <- function(data, holidays, growth, show_best_param_results = TRUE) {
  library(tidyverse)
  # to get the correct forecast days as forecast_period and range (last_history_date, end_forecast_date]
  last_history_date <- max(data$ds)
  first_history_date <- min(data$ds)
  # allowing one change point per quarter
  n_quarters = (as.yearqtr(ymd(last_history_date))-as.yearqtr(ymd(first_history_date)))*4
  # split the training dataset and 31-day interval validation dataset with range [begin_of_cv_dataset, last_history_date]
  # we are going to select the best tuning parameters based on fitting validation dataset with training model
  begin_of_cv_dataset <- last_history_date+days(-181)
  predict_dat <- data %>% filter(ds < begin_of_cv_dataset) 
  validate_dat <- data %>% filter(ds >= begin_of_cv_dataset & ds <= last_history_date)
  
  
  # Search grid. The parameters that require some tuning are related to the flexibility that we want to 
  # give the model to fit change points, seasonality and holidays. A non-exhaustive grid search is done
  # just to have a vague idea of the best values for the parameters. This step can be skipped if the user
  # has some expert knowledge about the task at hand.
  if (growth == "linear") {
    prophetGrid <- expand.grid(changepoint_prior_scale = c(0.5, 0.25, 0.1, 0.05, 0.01), # run from 0.05, 0.01, 0.005, 0.001 
                               # changepoint_prior_scale, by default 0.05, increase it will make the trend more flexible, 
                               # decrease it make the trend less flexible
                               seasonality_prior_scale = c(0.5, 0.25, 0.1, 0.05, 0.01),
                               holidays_prior_scale = c(0.5, 0.25, 0.1, 0.05, 0.01),
                               n_changepoints = n_quarters, # or number of month/quarter in the data 
                               capacity = 5*max(predict_dat$y),
                               growth = growth) 
  }else{
    prophetGrid <- expand.grid(changepoint_prior_scale = c(0.5, 0.25, 0.1, 0.05, 0.01),
                               seasonality_prior_scale = c(0.5, 0.25, 0.1, 0.05, 0.01),
                               holidays_prior_scale = c(0.5, 0.25, 0.1, 0.05, 0.01),
                               n_changepoints = n_quarters, # or number of month/quarter in the data 
                               capacity = c(10,20)*max(predict_dat$y),
                               growth = growth)  
  }
  
  # create a place to store the search grid result
  results <- matrix(0, nrow=nrow(prophetGrid), ncol=3) # we are going to store "MAE", "MPE", and "MAPE" in to results
  colnames(results) <- c("MAE", "MPE", "MAPE")
  
  # Search best parameters
  for (i in seq_len(nrow(prophetGrid))) {
    parameters <- prophetGrid[i, ]
    if (parameters$growth == 'logistic') {predict_dat$cap <- parameters$capacity}
    
    m <- prophet(predict_dat, 
                 growth = parameters$growth, 
                 holidays = holidays,
                 n.changepoints = parameters$n_changepoints, 
                 seasonality.prior.scale = parameters$seasonality_prior_scale, 
                 changepoint.prior.scale = parameters$changepoint_prior_scale,
                 holidays.prior.scale = parameters$holidays_prior_scale,
                 yearly.seasonality = TRUE, # yearly seasonal component using Fourier series
                 weekly.seasonality = TRUE, # weekly seasonal component using dummy variables
                 daily.seasonality = FALSE #  daily seasonal component using dummy variables only when subdaily data available
    )
    
    future <- make_future_dataframe(m, periods = nrow(validate_dat), include_history = FALSE)
    if (parameters$growth == 'logistic') {future$cap <- parameters$capacity}
    forecast_dat <- predict(m, future) %>% select(ds, yhat) %>% mutate(ds = ymd(ds))
    common_dat <- tibble(ds = as.Date(intersect(forecast_dat$ds, validate_dat$ds))) # in case some data missing
    tmp_forecast <- forecast_dat %>% filter(ds %in% common_dat$ds)
    results[i,] <- forecast::accuracy(tmp_forecast[, 'yhat'], validate_dat$y)[ , c('MAE', 'MPE', 'MAPE')]
  }
  
  # attach the result to each parameters setting
  prophetGrid <- cbind(prophetGrid, results)
  # select the best parameters setting with the smallest MAPE
  best_params <- prophetGrid[prophetGrid[,"MAPE"] == min(results[,"MAPE"]), ]
  list(best_params=best_params, all_params = prophetGrid)
}



### for data with less than 2 years, better reduce the flexibility to avoid overfitting current data 
# to get the best parameters settings for Prophet model based on ProphetGrid (as listed in function below)
find_best_model_params_few <- function(data, holidays, growth, show_best_param_results = TRUE) {
  # to get the correct forecast days as forecast_period and range (last_history_date, end_forecast_date]
  last_history_date <- max(data$ds)
  first_history_date <- min(data$ds)
  # allowing one change point per quarter
  n_quarters = (as.yearqtr(ymd(last_history_date))-as.yearqtr(ymd(first_history_date)))*4
  # split the training dataset and 31-day interval validation dataset with range [begin_of_cv_dataset, last_history_date]
  # we are going to select the best tuning parameters based on fitting validation dataset with training model
  begin_of_cv_dataset <- last_history_date+days(-181)
  predict_dat <- data %>% filter(ds < begin_of_cv_dataset) 
  validate_dat <- data %>% filter(ds >= begin_of_cv_dataset & ds <= last_history_date)
  
  # Search grid. The parameters that require some tuning are related to the flexibility that we want to 
  # give the model to fit change points, seasonality and holidays. A non-exhaustive grid search is done
  # just to have a vague idea of the best values for the parameters. This step can be skipped if the user
  # has some expert knowledge about the task at hand.
  if (growth == "linear") {
    prophetGrid <- expand.grid(changepoint_prior_scale = c( 0.3, 0.2, 0.1, 0.05, 0.01), 
                               # changepoint_prior_scale, by default 0.05, increase it will make the trend more flexible, 
                               # decrease it make the trend less flexible
                               seasonality_prior_scale = c(0.5, 0.25, 0.1, 0.05, 0.01),
                               holidays_prior_scale = c(0.5, 0.25, 0.1, 0.05, 0.01),
                               n_changepoints = n_quarters, # or number of month/quarter in the data 
                               capacity = 5*max(predict_dat$y),
                               growth = growth) 
  }else{
    prophetGrid <- expand.grid(changepoint_prior_scale = c(0.3, 0.2, 0.1, 0.05), 
                               seasonality_prior_scale = c(0.5, 0.25, 0.1, 0.05, 0.01),
                               holidays_prior_scale = c(0.5, 0.25, 0.1, 0.05, 0.01),
                               n_changepoints = n_quarters, # or number of month/quarter in the data 
                               capacity = c(10,20)*max(predict_dat$y),
                               growth = growth)  
  }
  
  # create a place to store the search grid result
  results <- matrix(0, nrow=nrow(prophetGrid), ncol=3) # we are going to store "MAE", "MPE", and "MAPE" in to results
  colnames(results) <- c("MAE", "MPE", "MAPE")
  
  # Search best parameters
  for (i in seq_len(nrow(prophetGrid))) {
    parameters <- prophetGrid[i, ]
    if (parameters$growth == 'logistic') {predict_dat$cap <- parameters$capacity}
    
    m <- prophet(predict_dat, 
                 growth = parameters$growth, 
                 holidays = holidays,
                 n.changepoints = parameters$n_changepoints, 
                 seasonality.prior.scale = parameters$seasonality_prior_scale, 
                 changepoint.prior.scale = parameters$changepoint_prior_scale,
                 holidays.prior.scale = parameters$holidays_prior_scale,
                 yearly.seasonality = TRUE, # yearly seasonal component using Fourier series
                 weekly.seasonality = TRUE, # weekly seasonal component using dummy variables
                 daily.seasonality = FALSE #  daily seasonal component using dummy variables only when subdaily data available
    )
    future <- make_future_dataframe(m, periods = nrow(validate_dat), include_history = FALSE)
    if (parameters$growth == 'logistic') {future$cap <- parameters$capacity}
    forecast_dat <- predict(m, future) %>% select(ds, yhat) %>% mutate(ds = ymd(ds))
    common_dat <- tibble(ds = as.Date(intersect(forecast_dat$ds, validate_dat$ds))) # in case some data missing
    tmp_forecast <- forecast_dat %>% filter(ds %in% common_dat$ds)
    results[i,] <- forecast::accuracy(tmp_forecast[, 'yhat'], validate_dat$y)[ , c('MAE', 'MPE', 'MAPE')]
  }
  
  # attach the result to each parameters setting
  prophetGrid <- cbind(prophetGrid, results)
  # select the best parameters setting with the smallest MAPE
  best_params <- prophetGrid[prophetGrid[,"MAPE"] == min(results[,"MAPE"]), ]
  list(best_params=best_params, all_params = prophetGrid)
}

##################################################################################################################  
##################################################################################################################  
##################################################################################################################  
ci.calculation <- function(model, file_path, file_name, test_parameters, last_history_date) {
  # now we need to calculate Credible intervals for MA28 (end on 2018/12/31)
  if(test_parameters$growth == "linear") {
    df <- data.frame(ds = seq(from=as.Date("2018-12-31")-27, to = as.Date("2018-12-31"), by = 1))
  }else{
    df <- data.frame(ds = seq(from=as.Date("2018-12-31")-27, to = as.Date("2018-12-31"), by = 1), 
                     cap = test_parameters$capacity)
  }
  # it returns a list with item "trend" and "yhat", each with dimension (number of days)*1000
  pred.samples <- predictive_samples(prophet_model, df) 
  ma28.reps<- apply(pred.samples$yhat,2, mean) # returns the 28dMA for each of these 1000 columns (ie.returns 1000 samples of 28d MA)
  # a list of CI that of interest
  ci.prop <- c(0.7, 0.8, 0.9, 0.95, 0.99)
  ci.a <- do.call(rbind, lapply(ci.prop, function(ci) {
    x <- format(quantile(ma28.reps, c( (1-ci)/2, 1- (1-ci)/2)),big.mark=",")
    data.frame(ciprop = ci, ma28.20181231.low = x[1], ma28.20181231.high=x[2])
  }))
  
  # now we need to calculate Credible intervals for MA28 (end on 2019/12/31)
  if(test_parameters$growth == "linear") {
    df <- data.frame(ds = seq(from=as.Date("2019-12-31")-27, to = as.Date("2019-12-31"), by = 1))
  }else{
    df <- data.frame(ds = seq(from=as.Date("2019-12-31")-27, to = as.Date("2019-12-31"), by = 1), 
                     cap = test_parameters$capacity)
  }
  pred.samples <- predictive_samples(prophet_model, df)
  ma28.reps<- apply(pred.samples$yhat,2, mean)
  ci.prop <- c(0.7, 0.8, 0.9, 0.95, 0.99)
  ci.b <- do.call(rbind, lapply(ci.prop, function(ci) {
    x <- format(quantile(ma28.reps, c( (1-ci)/2, 1- (1-ci)/2)),big.mark=",")
    data.frame(ciprop = ci, ma28.20191231.low = x[1], ma28.20191231.high=x[2])
  }))
  
  # now we need to calculate Credible intervals for MA91 (end on 2018/12/31)
  if(test_parameters$growth == "linear") {
    df <- data.frame(ds = seq(from=as.Date("2018-12-31")-90, to = as.Date("2018-12-31"), by = 1))
  }else{
    df <- data.frame(ds = seq(from=as.Date("2018-12-31")-90, to = as.Date("2018-12-31"), by = 1), 
                     cap = test_parameters$capacity)
  }
  pred.samples <- predictive_samples(prophet_model, df)
  ci.prop <- c(0.7,0.8,0.90,0.95, 0.99)
  ma91.reps<- apply(pred.samples$yhat,2, mean)
  ci.c <- do.call(rbind,lapply(ci.prop,function(ci){
    x <- format(quantile(ma91.reps, c( (1-ci)/2, 1- (1-ci)/2)),big.mark=",")
    data.frame(ciprop = ci, ma91.20181231.low = x[1], ma91.20181231.high=x[2])
  }))
  
  # now we need to calculate Credible intervals for MA91 (end on 2019/12/31)
  if(test_parameters$growth == "linear") {
    df <- data.frame(ds = seq(from=as.Date("2019-12-31")-90, to = as.Date("2019-12-31"), by = 1))
  }else{
    df <- data.frame(ds = seq(from=as.Date("2019-12-31")-90, to = as.Date("2019-12-31"), by = 1), 
                     cap = test_parameters$capacity)
  }
  pred.samples <- predictive_samples(prophet_model, df)
  ci.prop <- c(0.7,0.8,0.90,0.95, 0.99)
  ma91.reps<- apply(pred.samples$yhat,2, mean)
  ci.d <- do.call(rbind,lapply(ci.prop,function(ci){
    x <- format(quantile(ma91.reps, c( (1-ci)/2, 1- (1-ci)/2)),big.mark=",")
    data.frame(ciprop = ci, ma91.20191231.low = x[1], ma91.20191231.high=x[2])
  }))
  ### cbine all ci together
  
  ci.rst <- cbind(ci.a, ci.b[,2:3], ci.c[,2:3], ci.d[,2:3])
  write.csv(ci.rst, file=paste0(file_path, file_name, "upto_", last_history_date, "_", test_parameters$growth, "_yearend_ci.csv"))
  ci.rst
  ############ ############ ############ ############################################################ 
} #end of ci.calculation function    


##################################################################################################################  
##################################################################################################################  
##################################################################################################################  

ci.gen.calculation <- function(model, start_date, end_date, ci.prop, file_path, file_name, test_parameters) {
  
  # now we need to calculate Credible intervals for MA91 (end on 2019/12/31)
  if(test_parameters$growth == "linear") {
    df <- data.frame(ds = seq(from=as.Date(start_date), to = as.Date(end_date), by = 1))
  }else{
    df <- data.frame(ds = seq(from=as.Date(start_date), to = as.Date(end_date), by = 1), 
                     cap = test_parameters$capacity)
  }
  # get 1000 posterior predictive samples on yhat
  pred.samples <- predictive_samples(prophet_model, df)$yhat
  history.length <- nrow(hist_data)
  
  # calculate posterior predictive sample for 91d MA 
  ma91d.rep <- apply(pred.samples, 2, function(x) rollapply(c(hist_data$y, x), list(-90:0), mean, fill=NA))
  future.ma91d.rep <- ma91d.rep[c((history.length+1):nrow(ma91d.rep)),] 
  
  # get the CI for 91d MA
  # ci.prop <- c(0.7, 0.8, 0.90, 0.95, 0.99)
  ci <- do.call(rbind,lapply(ci.prop,function(ci){
    temp.ci <- apply(future.ma91d.rep, 1, function(x) quantile(x, c( (1-ci)/2, 1- (1-ci)/2)))
    data.frame(ciprop = ci, ma.low = temp.ci[1,], ma.high=temp.ci[2,], date = df$ds)
  }))
  ci
  ############ ############ ############ ############################################################ 
} #end of ci.calculation function    

##################################################################################################################  
##################################################################################################################  
##################################################################################################################  
### to get/plot the cdf of 28dMA and 91dMA for the end of 2018 and 2019
cdf.calculation <- function(prophet_model, file_path, file_name, test_parameters, last_history_date) {
  library(lattice)
  
  df  <-  data.frame(ds = seq(from=as.Date("2018-12-31")-27, to=as.Date("2018-12-31"),by=1))
  pred.samples <- predictive_samples(prophet_model, df)
  ma28.reps<- apply(pred.samples$yhat,2, mean)
  ma28perc <- quantile(ma28.reps, p <- seq(0,1,length=1001))
  cdf.ma28.20181231 <- data.frame( proportion = p*100, percentile = p, value = ma28perc, date = "2018-12-31", cat="MA_28d")
  png(paste0(file_path, file_name, "_MA28_on_20181231.png"))
  xyplot( value /1e6~  percentile, data=cdf.ma28.20181231,type=c('l','g'),asp=1, xlab='Proportion', ylab='MA28 ending on 2018-12-31 (millions)')
  dev.off()
  
  df  <-  data.frame(ds = seq(from=as.Date("2019-12-31")-27, to=as.Date("2019-12-31"),by=1))
  pred.samples <- predictive_samples(prophet_model, df)
  ma28.reps<- apply(pred.samples$yhat,2, mean)
  ma28perc <- quantile(ma28.reps, p <- seq(0,1,length=1001))
  cdf.ma28.20191231 <- data.frame( proportion = p*100,  percentile = p, value = ma28perc, date = "2019-12-31", cat="MA_28d")
  png(paste0(file_path, file_name, "_MA28_on_20191231.png"))
  xyplot( value /1e6~  percentile, data=cdf.ma28.20191231,type=c('l','g'),asp=1, xlab='Proportion', ylab='MA28 ending on 2019-12-31 (millions)')
  dev.off()
  
  df  <-  data.frame(ds = seq(from=as.Date("2018-12-31")-90, to=as.Date("2018-12-31"),by=1))
  pred.samples <- predictive_samples(prophet_model, df)
  ma91.reps<- apply(pred.samples$yhat,2, mean)
  ma91perc <- quantile(ma91.reps, p <- seq(0,1,length=1001))
  cdf.ma91.20181231 <- data.frame( proportion = p*100,  percentile = p, value = ma91perc, date = "2018-12-31", cat="MA_91d")
  png(paste0(file_path, file_name, "_MA91_on_20181231.png"))
  xyplot( value /1e6~  percentile, data=cdf.ma91.20181231,type=c('l','g'),asp=1, xlab='Proportion', ylab='MA91 ending on 2018-12-31 (millions)')
  dev.off()
  
  df  <-  data.frame(ds = seq(from=as.Date("2019-12-31")-90, to=as.Date("2019-12-31"),by=1))
  pred.samples <- predictive_samples(prophet_model, df)
  ma91.reps<- apply(pred.samples$yhat,2, mean)
  ma91perc <- quantile(ma91.reps, p <- seq(0,1,length=1001))
  cdf.ma91.20191231 <- data.frame( proportion = p*100,  percentile = p, value = ma91perc, date = "2019-12-31", cat="MA_91d")
  png(paste0(file_path, file_name, "_MA91_on_20191231.png"))
  xyplot( value /1e6~  percentile, data=cdf.ma28.20181231,type=c('l','g'),asp=1, xlab='Proportion', ylab='MA91 ending on 2019-12-31 (millions)')
  dev.off()
  
  all_quantile <- rbind(cdf.ma28.20181231, cdf.ma28.20191231, cdf.ma91.20181231, cdf.ma91.20191231)
  write.csv(all_quantile, file=paste0(file_path, file_name, "_quantiles_for_cdf.csv"))
  all_quantile
} # end of function for cdf calculation

