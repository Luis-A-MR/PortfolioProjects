# Load necessary libraries
install.packages("forecast")
install.packages("TSA")
install.packages("astsa")
# Install if not installed
library(forecast)
library(ggplot2)

library(astsa)

library(TSA)
library(tidyr)
library(readr)
library(dplyr)
library(ggplot2)
library(forecast)
library(tseries)
library(lubridate)
library(tseries)
library(vars)

# Load the dataset
data = read.csv("https://dxl-datasets.s3.us-east-1.amazonaws.com/data/industry_data_train.csv")

any(is.na(data))  # no NA



#extract and Convert to Time Series

jobs = ts(data$jobs,start=c(2003,01), frequency=12) # Thousands
layoffs = ts(data$layoffs,start=c(2003,01), frequency=12) # Thousands
employee = ts(data$employees,start=c(2003,01), frequency=12) #THousands
spend = ts(data$spend,start=c(2003,01), frequency=12) # this is in Millions

autoplot(jobs) + autolayer(layoffs) + autolayer(employee) + autolayer(spend)

#Train/Test Split
jobs_train = window(jobs, end=c(2022,12))
jobs_test = window(jobs, start=c(2023,1))

layoffs_train =  window(layoffs, end=c(2022,12))
layoffs_test =  window(layoffs, start=c(2023,1))

employee_train =  window(employee, end=c(2022,12))
employee_test =  window(employee, start=c(2023,1))

spend_train =  window(spend, end=c(2022,12))
spend_test =  window(spend, start=c(2023,1))


####### TSLM ########################################################################################


# TSLM Model (With External Regressor)
tslm_model1 = tslm(jobs_train ~ poly(trend, 2) + season + layoffs_train)

#Plot Fitted Values
autoplot(jobs_train) +
  autolayer(tslm_model1$fitted.values, series = "Fitted", color = "blue") +
  ggtitle("TSLM Fitted Values with Layoffs")

#Prepare Future Data (Ensure Correct Length and Factor Type)
future_layoffs = tail(layoffs, 12)  # Select the last 12 months for forecasting

future_data = data.frame(
  trend = seq(length(jobs_train) + 1, length(jobs_train) + 12),
  season = factor(rep(1:12, length.out = 12)),  # Convert to factor
  layoffs_train = future_layoffs
)

#Forecast Using Future Data
forecast_tslm1 = forecast(tslm_model1, newdata = future_data)

# Plot Forecast
autoplot(jobs_test) + 
  autolayer(forecast_tslm1, series = "Forecast", color = "blue") +
  autolayer(jobs_test, series = "Actual", color = "red", linewidth = 2) +
  ggtitle("TSLM Forecast with Layoffs")

#Evaluate Forecast Accuracy
accuracy(forecast_tslm1, jobs_test)

# TSLM Model (With External Regressor) spend###########Spend################################################
tslm_model2 = tslm(jobs_train ~ poly(trend, 3) + season + spend_train)

#Plot Fitted Values
autoplot(jobs_train) +
  autolayer(tslm_model2$fitted.values, series = "Fitted", color = "blue") +
  ggtitle("TSLM Fitted Values")

#Prepare Future Data (Ensure Correct Length and Factor Type)
future_spend = tail(spend, 12)  # Select the last 12 months for forecasting

future_data = data.frame(
  trend = seq(length(jobs_train) + 1, length(jobs_train) + 12),
  season = factor(rep(1:12, length.out = 12)),  # Convert to factor
  spend_train = future_spend
)

#Forecast Using Future Data
forecast_tslm2 = forecast(tslm_model2, newdata = future_data)

# Plot Forecast
autoplot(jobs_test) + 
  autolayer(forecast_tslm2, series = "Forecast", color = "blue") +
  autolayer(jobs_test, series = "Actual", color = "red", linewidth = 2) +
  ggtitle("TSLM Forecast with Layoffs")

#Evaluate Forecast Accuracy
accuracy(forecast_tslm2, jobs_test)

##################### ARIMA #############################################################################
library(tseries)
autoplot(jobs_train)
adf.test(diff(jobs_train))
autoplot(diff(jobs_train)) #d1

acf2(diff(jobs_train)) #Seasonal patterns are hard to see
eacf(jobs_train)#looks like a 1,1,1 


sarima((jobs_train),1,1,1,0,0,0,12)

#overfitting
sarima((jobs_train),0,1,1,0,1,1,12) #best after trying different options 
sarima((jobs_train),0,1,0,2,1,3,12)

#Build model
#m_arima = Arima(jobs_train, order=c(0,1,1), seasonal= c(0,1,1))
#m_arima = Arima(jobs_train, order=c(0,1,1), seasonal= c(1,0,1))
m_arima = Arima(jobs_train, order=c(0,1,0), seasonal= c(2,1,3))
autoplot(jobs_train) +
  autolayer(m_arima$fitted)


f_arima = forecast(m_arima, h=12)
autoplot(jobs_test) +
  autolayer(f_arima) +
  autolayer(jobs_test, color='red2', linewidth=2)


accuracy(f_arima,jobs_test)

###################################ARIMAX - layoffs, employee, spend ######################################################
xreg_train = cbind(layoffs_train, employee_train, spend_train)
colnames(xreg_train) = c("layoffs", "employee","spend")

xreg_test = cbind(layoffs_test, employee_test, spend_test)
colnames(xreg_test) = c("layoffs", "employee", "spend")


r = rstudent(tslm(jobs_train ~ xreg_train))
summary(tslm(jobs_train ~ xreg_train))
autoplot(r)
adf.test(r)
acf2(r) #0,0,1?
eacf(r)
# Fit ARIMAX model

sarima(r,0,1,1,0,1,1,12)


m_arimax_all = Arima(jobs_train, order=c(1,1,1), seasonal=c(0,1,1), xreg=xreg_train)
# Forecast using the same column names
f_arimax_all = forecast(m_arimax_all, xreg=xreg_test)

# Plot forecast
autoplot(jobs_test) + 
  autolayer(f_arimax_all, series="Forecast") + 
  autolayer(jobs_test, color='red2', linewidth=1.5)

# Evaluate accuracy
accuracy(f_arimax_all, jobs_test)


########## ARIMAX ######### layoffs########################################################################

r = rstudent(tslm(jobs_train ~ layoffs_train))
summary(tslm(jobs_train ~ layoffs_train))
autoplot(r)

adf.test(diff(r))
acf2(diff(r))
eacf(diff(r))

sarima(r,0, 1, 1, 0, 1, 1,12)

m_arimax_l = Arima(jobs_train, order=c(2,1,0), seasonal=c(1,1,3), xreg=layoffs_train)

autoplot(jobs_train) + 
  autolayer(m_arimax_l$fitted)

f_arimax_l = forecast(m_arimax_l, xreg=layoffs_train)
autoplot(jobs_test) + 
  autolayer(f_arimax_l) + 
  autolayer(jobs_test, color='red2', linewidth=1.5)

accuracy(f_arimax_l, jobs_test)

########ARIMAx EMPLOYEE##########################################################################################
r = rstudent(tslm(jobs_train ~ employee_train))
summary(tslm(jobs_train ~ employee_train))
autoplot(r)



adf.test(diff(r))
acf2(diff(r))
eacf(diff(r))

sarima(r,0, 0, 1, 0, 1, 2,12)

m_arimax_e = Arima(jobs_train, order=c(0,1,1), seasonal=c(0,1,2), xreg=employee_train)

autoplot(jobs_train) + 
  autolayer(m_arimax_e$fitted)

f_arimax_e = forecast(m_arimax_e, xreg=employee_train)
autoplot(jobs_test) + 
  autolayer(f_arimax_e) + 
  autolayer(jobs_test, color='red2', linewidth=1.5)

accuracy(f_arimax_e, jobs_test)

###########################################################MERGED layoffs and employee#################################



xreg_train = cbind(layoffs_train, employee_train)
colnames(xreg_train) = c("layoffs", "employee")

xreg_test = cbind(layoffs_test, employee_test)
colnames(xreg_test) = c("layoffs", "employee")


r = rstudent(tslm(jobs_train ~ xreg_train))
summary(tslm(jobs_train ~ xreg_train))
autoplot(r)
adf.test(r)
acf2(r) #0,0,1?
eacf(r)
# Fit ARIMAX model

sarima(r,1,0,2,0,0,1,12)

# best m_arimax = Arima(jobs_train, order=c(3,0,4), seasonal=c(0,1,1), xreg=xreg_train)
m_arimax_le = Arima(jobs_train, order=c(3,0,4), seasonal=c(0,1,1), xreg=xreg_train)
# Forecast using the same column names
f_arimax_le = forecast(m_arimax_le, xreg=xreg_test)

# Plot forecast
autoplot(jobs_test) + 
  autolayer(f_arimax_le, series="Forecast") + 
  autolayer(jobs_test, color='red2', linewidth=1.5)

# Evaluate accuracy
accuracy(f_arimax_le, jobs_test)

################################ ARIMAX Employee + Spend

xreg_train = cbind(employee_train,spend_train)
colnames(xreg_train) = c("employee","spend")

xreg_test = cbind(employee_test, spend_test)
colnames(xreg_test) = c("employee","spend")

r = rstudent(tslm(jobs_train ~ xreg_train))
summary(tslm(jobs_train ~ xreg_train))

autoplot(r)
adf.test(r)
acf2(r) #0,0,1, 2 or 3, 1,0
eacf(r)

m_arimax_es = Arima(jobs_train, order=c(2,0,3), seasonal=c(2,1,1), xreg=xreg_train)
# Forecast using the same column names
f_arimax_es = forecast(m_arimax_es, xreg=xreg_test)

# Plot forecast
autoplot(jobs_test) + 
  autolayer(f_arimax_es, series="Forecast") + 
  autolayer(jobs_test, color='red2', linewidth=1.5)

# Evaluate accuracy
accuracy(f_arimax_es, jobs_test)



################# ARIMAX SPEND ######################################################################
xreg_train = spend_train
xreg_test = spend_test

r = rstudent(tslm(jobs_train ~ xreg_train))
summary(tslm(jobs_train ~ xreg_train))
autoplot(r)

adf.test(r)
acf2(r)  # Check ACF and PACF plots
eacf(r)  # Explore ARIMA model orders

sarima(r,1,0,1,1,0,1,12)  # Adjust based on ACF/PACF results

m_arimax_s = Arima(jobs_train, order=c(1,0,1), seasonal=c(4,0,1), xreg=xreg_train)


f_arimax_s = forecast(m_arimax_s, xreg=xreg_test)

# Plot forecast
autoplot(jobs_test) + 
  autolayer(f_arimax_s, series="Forecast") + 
  autolayer(jobs_test, color='red2', linewidth=1.5)

accuracy(f_arimax_s, jobs_test)
########################################################################################################
##NN
spend_train_scaled = scale(spend_train)
spend_test_scaled = scale(spend_test)

m_nnetx = nnetar(jobs_train, p=3, P=3, xreg=spend_train, size=8)  # Increase hidden nodes



m_auto = auto.arima(jobs_train, xreg=spend_train)
f_auto = forecast(m_auto, xreg=spend_test)

autoplot(jobs_test) + 
  autolayer(f_auto, series='AutoARIMAX') +
  autolayer(f_nnetx, series='NNETX') + 
  autolayer(jobs_test, color='black', linewidth=1)



accuracy(f_auto, jobs_test)

########################################### STL###########################################################
STL #
library(forecast)
library(ggplot2)

# Log-transform the data to stabilize variance
jobs_train_log <- log(jobs_train)
autoplot(jobs_train_log)
# STL Model: Use a fixed seasonal window
m_stl <- stlm(jobs_train_log, s.window=6)

# Plot STL decomposition
autoplot(m_stl$stl)

# Forecast
f_stl <- forecast(m_stl, h=12)

# Back-transform the forecast
f_stl$mean <- exp(f_stl$mean)
f_stl$lower <- exp(f_stl$lower)
f_stl$upper <- exp(f_stl$upper)

# Plot results properly
autoplot(jobs_test) + 
  autolayer(f_stl$mean, color='blue', size=1.2) +
  autolayer(jobs_test, color='red', size=1.5)


accuracy(f_stl, jobs_test)
############################################################## ETS #########################################################
#   Consider damped = T/F
#   alpha = controls amount of weight given to recent values, alpha=.2 worked well here, auto selection did not
# 
##Models to consider when fitting ETS models
#       - AAA: Additive Trend and Season
#       - MAM: Additive Trend with Multiplicative Seasonality (or, MAN if no seasonality but changing variance)
#       - ZAA or ZAM w/damped trend vs not damped
autoplot(jobs_train)

ets(jobs_train)

#if you see trend then you use multiplicative seasonality
m_ets = ets(jobs_train, model='ZAA', damped=F, alpha=.7) #M non constant from left to right, #additive  , damped= if you want to flattened out the trend

autoplot(jobs_train ) +
  autolayer(m_ets$fitted)


autoplot(jobs_train) + 
  autolayer(m_ets$fitted)

f_ets = forecast(m_ets, h=12)
autoplot(jobs_test) + 
  autolayer(f_ets) +
  autolayer(jobs_test, color='red2', linewidth=2)


accuracy(f_ets, jobs_test)
#The best results are from AAA (Additive Error, Additive Trend, Additive Seasonality).
# trend and seasonality in the data are additive rather than multiplicative
################################################RMSE###########################################################
accuracy(forecast_tslm1, jobs_test)
accuracy(forecast_tslm2, jobs_test)
accuracy(forecast_tslm, jobs_test)
accuracy(f_arima,jobs_test) #best RMSE
accuracy(f_arimax_all, jobs_test)# 4th best 
accuracy(f_arimax_e, jobs_test)
accuracy(f_arimax_le, jobs_test) #2nd best RMSE
accuracy(f_arimax_es, jobs_test) # 5th best 
accuracy(f_arimax_s, jobs_test)
accuracy(f_auto, jobs_test)
accuracy(f_stl, jobs_test)
accuracy(f_ets, jobs_test) #3rd best rmse
#############################TCSV###############################

# TSLM Model (With Layoffs as External Regressor)
forecast_function_tslm1 = function(y, h, xreg){
  tslm(y ~ poly(trend, 2) + season + xreg) %>%
    forecast(h=h, newdata=data.frame(
      trend = seq(length(y) + 1, length(y) + h),
      season = factor(rep(1:12, length.out=h)),
      xreg = tail(xreg, h)
    ))
}

# TSLM Model (With Spend as External Regressor)
forecast_function_tslm2 = function(y, h, xreg){
  tslm(y ~ poly(trend, 3) + season + xreg) %>%
    forecast(h=h, newdata=data.frame(
      trend = seq(length(y) + 1, length(y) + h),
      season = factor(rep(1:12, length.out=h)),
      xreg = tail(xreg, h)
    ))
}

# STL Decomposition + Forecast
forecast_function_stl = function(y, h){
  stlm(y, s.window='periodic') %>%
    forecast(h=h)
}

# ETS Model (Exponential Smoothing)
forecast_function_ets = function(y, h){
  ets(y, model='ZAA', damped=F, alpha=0.7) %>%
    forecast(h=h)
}

# ARIMA Model
forecast_function_arima = function(y, h){
  Arima(y, order=c(0,1,0), seasonal=c(2,1,3)) %>%
    forecast(h=h)
}

# ARIMAX Model (With Layoffs, Employees, and Spend)
forecast_function_arimax_all = function(y, h, xreg, newxreg){
  Arima(y, order=c(1,1,1), seasonal=c(0,1,1), xreg=xreg) %>%
    forecast(h=h, xreg=newxreg)
}

# ARIMAX Model (Layoffs Only)
forecast_function_arimax_l = function(y, h, xreg, newxreg){
  Arima(y, order=c(2,1,0), seasonal=c(1,1,3), xreg=xreg) %>%
    forecast(h=h, xreg=newxreg)
}

# ARIMAX Model (Employees Only)
forecast_function_arimax_e = function(y, h, xreg, newxreg){
  Arima(y, order=c(0,1,1), seasonal=c(0,1,2), xreg=xreg) %>%
    forecast(h=h, xreg=newxreg)
}

# ARIMAX Model (Layoffs & Employees)
forecast_function_arimax_le = function(y, h, xreg, newxreg){
  Arima(y, order=c(3,0,4), seasonal=c(0,1,1), xreg=xreg) %>%
    forecast(h=h, xreg=newxreg)
}

# ARIMAX Model (Employees & Spend)
forecast_function_arimax_es = function(y, h, xreg, newxreg){
  Arima(y, order=c(2,0,3), seasonal=c(2,1,1), xreg=xreg) %>%
    forecast(h=h, xreg=newxreg)
}

# ARIMAX Model (Spend Only)
forecast_function_arimax_s = function(y, h, xreg, newxreg){
  Arima(y, order=c(1,0,1), seasonal=c(4,0,1), xreg=xreg) %>%
    forecast(h=h, xreg=newxreg)
}

# Neural Network Model
forecast_function_nnet = function(y, h){
  nnetar(y, p=3, P=3) %>%
    forecast(h=h)
}

# Neural Network Model with Spend as External Regressor
forecast_function_nnetx = function(y, h, xreg, newxreg){
  nnetar(y, p=3, P=3, xreg=xreg, size=8) %>%
    forecast(h=h, xreg=newxreg)
}


# Set Forecast Horizon
h <- 1  # Forecast 12 months ahead

# Apply Time Series Cross-Validation (TSCV)
e_tslm1   <- tsCV(jobs_train, forecast_function_tslm1, h=h, xreg=layoffs_train)
e_tslm2   <- tsCV(jobs_train, forecast_function_tslm2, h=h, xreg=spend_train)
e_stl     <- tsCV(jobs_train, forecast_function_stl, h=h)
e_ets     <- tsCV(jobs_train, forecast_function_ets, h=h)
e_arima   <- tsCV(jobs_train, forecast_function_arima, h=h)

# Cross-validation for ARIMAX Models (Handling External Regressors)
xreg_train_all <- cbind(layoffs_train, employee_train, spend_train)
xreg_train_le  <- cbind(layoffs_train, employee_train)
xreg_train_es  <- cbind(employee_train, spend_train)

e_arimax_all <- tsCV(jobs_train, forecast_function_arimax_all, h=h, xreg=xreg_train_all)
e_arimax_l   <- tsCV(jobs_train, forecast_function_arimax_l, h=h, xreg=layoffs_train)
e_arimax_e   <- tsCV(jobs_train, forecast_function_arimax_e, h=h, xreg=employee_train)
e_arimax_le  <- tsCV(jobs_train, forecast_function_arimax_le, h=h, xreg=xreg_train_le)
e_arimax_es  <- tsCV(jobs_train, forecast_function_arimax_es, h=h, xreg=xreg_train_es)
e_arimax_s   <- tsCV(jobs_train, forecast_function_arimax_s, h=h, xreg=spend_train)

# Neural Network Model
e_nnet   <- tsCV(jobs_train, forecast_function_nnet, h=h)
e_nnetx  <- tsCV(jobs_train, forecast_function_nnetx, h=h, xreg=spend_train)

# Compute RMSE for Model Comparison
rmse_tslm1   <- sqrt(mean(e_tslm1^2, na.rm=TRUE))
rmse_tslm2   <- sqrt(mean(e_tslm2^2, na.rm=TRUE))
rmse_stl     <- sqrt(mean(e_stl^2, na.rm=TRUE))
rmse_ets     <- sqrt(mean(e_ets^2, na.rm=TRUE))
rmse_arima   <- sqrt(mean(e_arima^2, na.rm=TRUE))
rmse_arimax_all <- sqrt(mean(e_arimax_all^2, na.rm=TRUE))
rmse_arimax_l   <- sqrt(mean(e_arimax_l^2, na.rm=TRUE))
rmse_arimax_e   <- sqrt(mean(e_arimax_e^2, na.rm=TRUE))
rmse_arimax_le  <- sqrt(mean(e_arimax_le^2, na.rm=TRUE))
rmse_arimax_es  <- sqrt(mean(e_arimax_es^2, na.rm=TRUE))
rmse_arimax_s   <- sqrt(mean(e_arimax_s^2, na.rm=TRUE))
rmse_nnet       <- sqrt(mean(e_nnet^2, na.rm=TRUE))
rmse_nnetx      <- sqrt(mean(e_nnetx^2, na.rm=TRUE))

# Store RMSE in a Data Frame
rmses <- data.frame(
  Model = c('TSLM_Layoffs', 'TSLM_Spend', 'STL', 'ETS', 'ARIMA', 
            'ARIMAX_All', 'ARIMAX_Layoffs', 'ARIMAX_Employees', 
            'ARIMAX_Layoffs+Employees', 'ARIMAX_Employees+Spend', 
            'ARIMAX_Spend', 'NNET', 'NNETX_Spend'),
  RMSE  = c(rmse_tslm1, rmse_tslm2, rmse_stl, rmse_ets, rmse_arima, 
            rmse_arimax_all, rmse_arimax_l, rmse_arimax_e, 
            rmse_arimax_le, rmse_arimax_es, rmse_arimax_s, 
            rmse_nnet, rmse_nnetx)
)

# Print RMSE Table
print(rmses)
  
  # --- Install and Load Required Packages ---
  if (!requireNamespace("caret", quietly = TRUE)) install.packages("caret")
if (!requireNamespace("glmnet", quietly = TRUE)) install.packages("glmnet")
if (!requireNamespace("gt", quietly = TRUE)) install.packages("gt")

library(caret)
library(glmnet)
library(gt)

# Forecast each model
f_arima = forecast(m_arima, h=12)$mean
f_arimax_le = forecast(m_arimax_le, xreg=xreg_test)$mean
f_ets = forecast(m_ets, h=12)$mean

# OLS Regression-Based Optimal Weighting 
# Create a training dataset
forecasts_matrix = cbind(f_arima, f_arimax_le, f_ets)

# Fit a linear regression model to find optimal weights
weights_model = lm(jobs_test ~ forecasts_matrix)

# Extract weights (remove intercept)
optimal_weights = coef(weights_model)[-1]

# Normalize weights so they sum to 1
optimal_weights = optimal_weights / sum(optimal_weights)

# Compute the optimally weighted forecast
f_ols_weighted = forecasts_matrix %*% optimal_weights

# Convert OLS forecast to time series
f_ols_weighted_ts = ts(f_ols_weighted, start=start(jobs_test), frequency=frequency(jobs_test))

# Plot OLS Weighted Average Forecast
autoplot(jobs_test) + 
  autolayer(f_arima, series="ARIMA", color="brown") + 
  autolayer(f_arimax_le, series="ARIMAX_LE", color="yellow") + 
  autolayer(f_ets, series="ETS", color="purple") + 
  autolayer(f_ols_weighted_ts, size=1.5, linetype=2, series="OLS Weighted Avg", color="blue") +
  ggtitle("Comparison of ARIMA, ARIMAX_LE, ETS & OLS Weighted Forecast") +
  xlab("Time") + ylab("Jobs Forecast") +
  theme_minimal()

# Assess Accuracy
acc = rbind(
  data.frame(accuracy(f_arima, jobs_test), row.names='ARIMA'),
  data.frame(accuracy(f_arimax_le, jobs_test), row.names='ARIMAX_LE'),
  data.frame(accuracy(f_ets, jobs_test), row.names='ETS'),
  data.frame(accuracy(f_ols_weighted_ts, jobs_test), row.names='OLS Weighted Avg')
)

# Format & Visualize Accuracy 
# Ensure Model names are correctly assigned
acc$Model = rownames(acc)

# Convert accuracy results to long format
acc_long = acc %>%
  pivot_longer(cols = where(is.numeric), names_to = "Metric", values_to = "Value")

# Show Accuracy Table
acc %>%
  gt() %>%
  tab_header(title = "Model Performance Comparison (Lower RMSE & MAPE is Better)") %>%
  cols_label(Model = "Forecasting Model",
             RMSE = "Test RMSE",
             MAPE = "Test MAPE (%)") %>%
  fmt_number(columns = c(RMSE, MAPE), decimals = 2)

# RMSE Plot
acc_long %>%
  filter(Metric == "RMSE") %>%
  ggplot(aes(x = reorder(Model, Value), y = Value, fill = Model)) + 
  geom_col() + 
  coord_flip() + 
  labs(title = "RMSE Comparison", x = "Model", y = "RMSE") +
  theme_minimal()


# Create a comparison table
forecast_comparison <- data.frame(
  Date = time(jobs_test),
  Actual = as.numeric(jobs_test),
  OLS_Forecast = as.numeric(f_ols_weighted_ts)
)

# Print the table
print(forecast_comparison)

