
#Project: CTA L Ridership Analysis, Pre and Post COVID Crisis
#Author: Rachel Zhu
#Date: 09-17-2026

# Packages ----

library(readxl)
library(writexl)
library(dplyr)
library(ggplot2)

## import main dataset ----

master <- read_excel("master.xlsx")


# Did CTA L Ridership change post-onset of the pandemic? ----

  ## dataframe of monthly rides from 2016 to 2024

monthly_ridership <- master |> 
  mutate(date = as.Date(format(date,"%Y-%m-01"))) |> 
  group_by(date) |> 
  summarize(monthly_rides = sum(rides), # summarized by total rides each month
            mean_rides = round(mean(rides),2)) # mean *daily* rides

monthly_ridership <- monthly_ridership |> 
  mutate(after_cov = ifelse(date < "2020-03-01","false","true")) # bisected data into two groups -- pre and post pandemic onset


  ## plot of monthly rides

ggplot(data = monthly_ridership, aes(x = date, y = mean_rides)) + 
  geom_point() +
  geom_smooth(aes(group = after_cov),se = FALSE, method = "lm") +  # creates two fitted lines for pre and post pandemic onset
  labs(x = "Year", y = "Mean daily rides per month", title = "Mean daily CTA ridership by month from 2016 to 2024") +
  theme_minimal()




# Did CTA L Ridership "recover" post-onset of the pandemic? ----

monthly_ridership <- monthly_ridership |> 
  mutate(year = format(date,"%Y"),  # parsing date into years and months
         month = format(date,"%m"))

  ## dataframe of pre-covid 2019 monthly "baseline"
  ## pre-covid baseline refers to column mean_rides

monthly_baselines_2019 <- monthly_ridership |> 
  filter(date >= "2019-01-01",
         date < "2020-01-01") |> 
  select(month, baseline_rides = mean_rides)


  ## creating new column for proportion/ratio of post-covid rides to baseline pre-covid rides

monthly_ridership <- monthly_ridership |> 
  left_join(monthly_baselines_2019, monthly_ridership, by ="month") |> 
  mutate(prop_of_baseline = mean_rides / baseline_rides )

  ## plotting recovery of CTA rides

monthly_ridership_post_cov <- monthly_ridership |> 
  filter(date > "2020-03-01")

ggplot(monthly_ridership_post_cov, aes(x = date, y = prop_of_baseline)) +
  geom_point() +
  labs( title = "Post-onset proportion of recovery",
        x = "Year",
        y = "Proportion of 2019 baseline rides",
        caption = "Each post-covid point is the ratio of mean daily rides per month to its corresponding month in the 2019 baseline year.") +
  theme_minimal()




# Is there variation in ridership recovery by income level of L station's location/area (census tract)? ----
# investigation of proportion of ridership (pre/2019 to post/2024) by income group

  ## dataframe of income "buckets" and census tracts

income_tract_data <- master |> 
  select(c("under_25000","25000_to_49999","50000_to_74999","75000_to_124999","over_125000","community_name", "census_tract")) |> 
  mutate(income_ind = round(
    (under_25000 * 1 +
      `25000_to_49999` * 2 +
      `50000_to_74999` * 3 +
      `75000_to_124999` * 4 +
      over_125000 * 5) /
    (under_25000 +
      `25000_to_49999` +
      `50000_to_74999` +
      `75000_to_124999` +
      over_125000),4)) |> 
  distinct()
  ### income_ind: spans from 1-5, a measure of the income bracket of the census tract of which the station is located.

percentiles <- quantile(income_tract_data$income_ind, probs = c(0, 1/3, 2/3, 1))

  ## categorizing income indexes into income groups (by thirds; low, middle, high)

income_tract_data <- income_tract_data |>
  mutate(income_group = cut(income_ind,
                            breaks = percentiles,
                            include.lowest = TRUE,
                            labels = c("Low", "Middle", "High")))

  ## export income_tract_data as excel sheet

write_xlsx(income_tract_data, "income_tract_data.xlsx")

  ## left join income index and income group

master_w_income_ind <- master |> 
  left_join(income_tract_data |> select(census_tract, income_ind, income_group),
            by = "census_tract")

  ## export joined master sheet that includes income indices and groups

write_xlsx(master_w_income_ind, "master_w_income_ind.xlsx")

  ## dataframe of monthly ridership by station's income group

monthly_ridership_by_inc_grp <- master_w_income_ind |> 
  mutate(year = format(date,"%Y"),
         month = format(date,"%m")) |> 
  group_by(station_id, station_name, income_ind, income_group, year, month) |> 
  summarize(mean_rides_by_station = mean(rides,na.rm = TRUE),.groups = "drop")


  ## 2019 vs 2024 monthly rides by station

monthly_station_baselines_2019 <- monthly_ridership_by_inc_grp |> 
  filter(year == "2019") |> 
  select("station_id", "month", baseline_rides = mean_rides_by_station)

monthly_ridership_by_inc_grp <- monthly_ridership_by_inc_grp |> 
  left_join(monthly_station_baselines_2019, by = c("station_id", "month")) |> 
  mutate( prop_of_baseline = mean_rides_by_station / baseline_rides)


  ## excluding pre-2020 data points -- adding mean prop of baseline column (average of proportion recovered across months within income groups)
monthly_ridership_by_inc_grp <- monthly_ridership_by_inc_grp |> 
  filter(year >= "2020") |> 
  group_by(year, month, income_group) |> 
  mutate(mean_prop_of_baseline = mean(prop_of_baseline, na.rm = TRUE))

monthly_ridership_by_inc_grp$date <- as.Date(paste(monthly_ridership_by_inc_grp$year,   # (re)adding full date column
                                                   monthly_ridership_by_inc_grp$month,
                                                   01,sep = "-"))

  ## exporting as excel sheet
write_xlsx(monthly_ridership_by_inc_grp, "monthly_ridership_by_inc_grp.xlsx")


  # plots of change in proportion of ridership from 2020 to 2024 across income groups

ggplot(monthly_ridership_by_inc_grp,
       aes(x = date, y = mean_prop_of_baseline, color = income_group)) + 
  geom_line() +
  labs(title = "L Ridership Relative to 2019 'baseline' by Station's Census Tract Income Group",
       x = "Date",
       y = "Proportion of 2019 'baseline' Ridership",
       color = "Income Groups") + 
  theme_minimal()

# (alternative) plots of change in proportion of ridership from 2020 to 2024 by income index

ggplot(monthly_ridership_by_inc_grp,
       aes(x = date, y = mean_prop_of_baseline, color = income_ind)) + 
  geom_point() +
  labs(title = "L Ridership Relative to 2019 'baseline' by Station's Census Tract Income Index",
       x = "Date",
       y = "Proportion of 2019 'baseline' Ridership",
       color = "Income Index") + 
#  geom_smooth(aes(group = income_group))+
  theme_minimal()
