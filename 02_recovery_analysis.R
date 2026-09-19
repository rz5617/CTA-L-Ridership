
#Project: CTA L Ridership Analysis Pre and Post COVID 
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


# 01 Are income indices of station's area correlated with post pandemic onset ridership recovery? ----

monthly_station_recovery_2024 <- monthly_ridership_by_inc_grp |> 
  filter(year == "2024") |> 
  group_by(station_id, station_name, income_group, income_ind) |>
  summarize(mean_prop_of_baseline = mean(prop_of_baseline, na.rm = TRUE),.groups="drop")

monthly_station_recovery_2024$income_group<- factor(monthly_station_recovery_2024$income_group, levels = c("Low", "Middle", "High"), ordered = TRUE)

## linear regression ----
  ## Y_recovery = B0 + B1_income * X

  lm_recovery_income <- lm(mean_prop_of_baseline ~ income_ind, data = monthly_station_recovery_2024)

  ## (hypotheses) H0: B1 = 0  H1: B1 != 0

  ## t-test
  summary(lm_recovery_income)

    ### p-value:  0.517
    ### coefficient:  -0.01104
    ### standard err:  0.01700

  ## confidence interval
  confint(lm_recovery_income)

  ### CI: (-0.04472203, 0.02263725)

## plot of recovery in 2024 by station ----
  
ggplot(monthly_station_recovery_2024, 
       aes(x = income_group, y = mean_prop_of_baseline)) +
  geom_point() + 
  geom_smooth(method = "lm", se = TRUE) + 
  labs(x = "Income", y = "2024 ridership relative to 2019 baseline",
       title = "Neighborhood Income and CTA Ridership Recovery") +
  theme_minimal()

  
  
  
# How strong is the correlation between income group and post-covid recovery? ----

  ## compute correlation (excluding NAs)
  cor(x = monthly_station_recovery_2024$income_ind, 
      y = monthly_station_recovery_2024$mean_prop_of_baseline,
      use = "complete.obs")
    ### (Pearson's) rounded correlation between income level and recovery = -0.0602
  
  
  ## confidence interval and p-value
  cor.test(monthly_station_recovery_2024$income_ind,
           monthly_station_recovery_2024$mean_prop_of_baseline,
           method = "pearson")
    ### p-value = 0.5174
    ### 95% confidence interval =  (-0.2383504,  0.1219015)




# Is the model valid? ----
## Residual and assumption checks

## linearity check: Residuals vs. Fitted Values ----
  ## equal variance/homoscedasticity: Spread of residuals
  
  par(mfrow = c(2, 2))
  plot(lm_recovery_income)
  par(mfrow = c(1, 1))
  
## normality of residuals: Q-Q plot/shapiro-wilk normality test ----
  ## shapiro.test hypotheses H0: residuals are normal H1: residuals are not normal
  
  shapiro.test(lm_recovery_income$residuals)
  
    ### p-value: 6.489e-08
  
## independence of residuals: Durbin-Watson Test ----
  ## dwtest hypotheses H0: residuals are independent H1: residuals are not independent
  
  dwtest(lm_recovery_income, alternative = "two.sided")
  
    ### p-value: 0.7836 


