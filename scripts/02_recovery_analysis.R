
#Project: CTA L Ridership Analysis, Pre and Post COVID Crisis 
#Author: Rachel Zhu
#Date: 09-17-2026

# Packages ----

library(readxl)
library(writexl)
library(dplyr)
library(ggplot2)
library(lmtest)

## import dataframes ----

master <- read_excel("master_w_income_ind.xlsx")
monthly_ridership_by_inc_grp <- read_excel("monthly_ridership_by_inc_grp.xlsx")
income_tract_data <- read_excel("income_tract_data.xlsx")

## Q3: Was there a significant association between ridership recovery and income level in 2021, 2022, and 2023?

# ----

monthly_ridership_by_inc_grp$income_group<- factor(monthly_ridership_by_inc_grp$income_group, levels = c("Low", "Middle", "High"), ordered = TRUE)

  ## 2021 recovery between groups
monthly_station_recovery_2021 <- monthly_ridership_by_inc_grp |> 
  filter(year == "2021") |> 
  group_by(station_id, station_name, income_group, income_ind) |>
  summarize(mean_prop_of_baseline = mean(prop_of_baseline, na.rm = TRUE),.groups="drop")

  ## 2022 recovery between groups
monthly_station_recovery_2022 <- monthly_ridership_by_inc_grp |> 
  filter(year == "2022") |> 
  group_by(station_id, station_name, income_group, income_ind) |>
  summarize(mean_prop_of_baseline = mean(prop_of_baseline, na.rm = TRUE),.groups="drop")
  
  ## 2023 recovery between groups
monthly_station_recovery_2023 <- monthly_ridership_by_inc_grp |> 
  filter(year == "2023") |> 
  group_by(station_id, station_name, income_group, income_ind) |>
  summarize(mean_prop_of_baseline = mean(prop_of_baseline, na.rm = TRUE),.groups="drop")


# 2021 recovery ----

## linear regression ----

## Y_recovery_in 2021 = B0 + B1_income * X

  lm_recovery_income_2021 <- lm(mean_prop_of_baseline ~ income_ind, data = monthly_station_recovery_2021)

## (hypotheses) H0: B1 = 0  H1: B1 != 0

## t-test
  summary(lm_recovery_income_2021)

### p-value:  1.59e-12
### coefficient:  -0.069656
### standard err:  0.008795

## confidence interval

  confint(lm_recovery_income)

### CI:  (-0.08707656, -0.05223559)

  
## plot of recovery in 2021 by income level/index ----

ggplot(monthly_station_recovery_2021, 
       aes(x = income_ind, y = mean_prop_of_baseline)) +
  geom_point() + 
  geom_smooth(method = "lm", se = TRUE) + 
  labs(x = "Income Index", y = "2021 ridership relative to 2019 baseline",
       title = "Neighborhood Income and CTA Ridership Recovery") +
  theme_minimal()


## How strong is the correlation between income group and post-covid recovery in 2021? ----

## compute correlation (excluding NAs)
cor(x = monthly_station_recovery_2021$income_ind, 
    y = monthly_station_recovery_2021$mean_prop_of_baseline,
    use = "complete.obs")
### (Pearson's) rounded correlation between income level and recovery =  -0.5924002


## confidence interval and p-value
cor.test(monthly_station_recovery_2021$income_ind,
         monthly_station_recovery_2021$mean_prop_of_baseline,
         method = "pearson")
### p-value =  1.593e-12
### 95% confidence interval =   ( -0.6983762, -0.4610063)


## Is the model valid? ----
## Residual and assumption checks

## linearity check: Residuals vs. Fitted Values
## equal variance/homoscedasticity: Spread of residuals

par(mfrow = c(2, 2))
plot(lm_recovery_income_2021)
par(mfrow = c(1, 1))

## normality of residuals: Q-Q plot/shapiro-wilk normality test
## shapiro.test hypotheses H0: residuals are normal H1: residuals are not normal

shapiro.test(lm_recovery_income_2021$residuals)

### p-value:  5.247e-05

## independence of residuals: Durbin-Watson Test
## dwtest hypotheses H0: residuals are independent H1: residuals are not independent

dwtest(lm_recovery_income_2021, alternative = "two.sided")

### p-value:  0.5814



# 2022 recovery ----

## linear regression ----

## Y_recovery_in 2022 = B0 + B1_income * X

lm_recovery_income_2022 <- lm(mean_prop_of_baseline ~ income_ind, data = monthly_station_recovery_2022)

## (hypotheses) H0: B1 = 0  H1: B1 != 0

## t-test
summary(lm_recovery_income_2022)

### p-value:  0.0517
### coefficient:  -0.02482
### standard err:  0.01262

## confidence interval
confint(lm_recovery_income_2022)

### CI:  (-0.04981393, 0.0001834114)

## plot of recovery in 2022 by income level/index ----

ggplot(monthly_station_recovery_2022, 
       aes(x = income_ind, y = mean_prop_of_baseline)) +
  geom_point() + 
  geom_smooth(method = "lm", se = TRUE) + 
  labs(x = "Income Index", y = "2022 ridership relative to 2019 baseline",
       title = "Neighborhood Income and CTA Ridership Recovery") +
  theme_minimal()


## How strong is the correlation between income group and post-covid recovery in 2022? ----

## compute correlation (excluding NAs)
cor(x = monthly_station_recovery_2022$income_ind, 
    y = monthly_station_recovery_2022$mean_prop_of_baseline,
    use = "complete.obs")
### (Pearson's) rounded correlation between income level and recovery =  -0.1795797


## confidence interval and p-value
cor.test(monthly_station_recovery_2022$income_ind,
         monthly_station_recovery_2022$mean_prop_of_baseline,
         method = "pearson")
### p-value =  0.05168
### 95% confidence interval =   (-0.349009941,  0.001219241)


## Is the model valid? ----
## Residual and assumption checks

## linearity check: Residuals vs. Fitted Values
## equal variance/homoscedasticity: Spread of residuals

par(mfrow = c(2, 2))
plot(lm_recovery_income_2022)
par(mfrow = c(1, 1))

## normality of residuals: Q-Q plot/shapiro-wilk normality test
## shapiro.test hypotheses H0: residuals are normal H1: residuals are not normal

shapiro.test(lm_recovery_income_2022$residuals)

### p-value:  6.478e-10

## independence of residuals: Durbin-Watson Test
## dwtest hypotheses H0: residuals are independent H1: residuals are not independent

dwtest(lm_recovery_income_2022, alternative = "two.sided")

### p-value:  0.5982



# 2023 recovery ----

## linear regression ----

## Y_recovery_in 2023 = B0 + B1_income * X

lm_recovery_income_2023 <- lm(mean_prop_of_baseline ~ income_ind, data = monthly_station_recovery_2023)

## (hypotheses) H0: B1 = 0  H1: B1 != 0

## t-test
summary(lm_recovery_income_2023)

### p-value:  0.404
### coefficient:  -0.01313
### standard err:  0.01568

## confidence interval
confint(lm_recovery_income_2023)

### CI:  (-0.04417387, 0.01792077)

## plot of recovery in 2023 by income level/index ----

ggplot(monthly_station_recovery_2023, 
       aes(x = income_ind, y = mean_prop_of_baseline)) +
  geom_point() + 
  geom_smooth(method = "lm", se = TRUE) + 
  labs(x = "Income Index", y = "2023 ridership relative to 2019 baseline",
       title = "Neighborhood Income and CTA Ridership Recovery") +
  theme_minimal()


## How strong is the correlation between income group and post-covid recovery in 2022? ----

## compute correlation (excluding NAs)
cor(x = monthly_station_recovery_2023$income_ind, 
    y = monthly_station_recovery_2023$mean_prop_of_baseline,
    use = "complete.obs")
### (Pearson's) rounded correlation between income level and recovery =  -0.07751597


## confidence interval and p-value
cor.test(monthly_station_recovery_2023$income_ind,
         monthly_station_recovery_2023$mean_prop_of_baseline,
         method = "pearson")
### p-value =  0.4041
### 95% confidence interval =   (-0.2547064,  0.1047106)


## Is the model valid? ----
## Residual and assumption checks

## linearity check: Residuals vs. Fitted Values
## equal variance/homoscedasticity: Spread of residuals

par(mfrow = c(2, 2))
plot(lm_recovery_income_2023)
par(mfrow = c(1, 1))

## normality of residuals: Q-Q plot/shapiro-wilk normality test
## shapiro.test hypotheses H0: residuals are normal H1: residuals are not normal

shapiro.test(lm_recovery_income_2023$residuals)

### p-value:  7.503e-08

## independence of residuals: Durbin-Watson Test
## dwtest hypotheses H0: residuals are independent H1: residuals are not independent

dwtest(lm_recovery_income_2023, alternative = "two.sided")

### p-value:  0.956

  
  
  
  
  
  
  