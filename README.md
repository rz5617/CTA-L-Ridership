# CTA-L-Ridership Analysis, Pre and Post COVID Crisis

This project is an analysis of changes in L ridership following the onset of the COVID-19 pandemic, and will also explore whether recovery differed according to economic characteristics (income) of the census tract containing the CTA station.

Raw, unclean ridership data was taken from the Chicago Data Portal, provided by the CTA, as well as income by census tract from the ACS (American Community Survey). Geographic data for CTA station locations and census tract borders were also taken from the Chicago Data Portal and turned into geospatial data. R (ggplot2, dplyr, sf), Excel, and Power Query were used to develop this project.

For the sake of the project, I will consider ‘2020-03-01’ the start of the COVID-19 global health crisis, and ‘2023-05-01’ the end.

## Overview

The 2020 pandemic was the catalyst of a major disruption to public transit usage in Chicago. By examining ridership from 2016 through 2024 with emphasis on the magnitude of post-onset recovery, I will address two questions:

1.  How did CTA L ridership change, following the onset of the COVID-19 crisis?

2.  What were the variations in CTA L ridership recovery according to the economic characteristics (income) of the census tract that contains the CTA station?

## Results (Summary)

First, by plotting tidy/clean ridership data that has been aggregated to mean daily rides per month from 2016 to 2024, a steep decline can be seen following the start of the pandemic in 2020. Specifically, ridership fell approximately 86.7% between February 2020 and April 2020. It subsequently saw a gradual, but incomplete recovery of up to 64.9% by 2024.

Then, by plotting the proportion of ridership recovery across income groups (low, middle, high) starting in 2020, the greatest differences between low, middle, and high-income groups can be observed within the first year and a half of the pandemic. After mid-2021, the ridership recovery gaps shrink, although there is still an observable, but not necessarily a statistically significant difference. This is further explored through linear regression and correlation analysis (02_ridership_analysis.R)

## Main visuals

<img src="plots/01_ridership_scatterplot.png" width="800" height="600"/>

- Monthly CTA L ridership from 2016-2024, visualizing the cutoff at around March 2020 and the subsequent recovery.

<img src="plots/03_recovery_by_income_group.png" width="800" height="600"/>

- Monthly ridership recovery relative to 2019 baseline, grouped by income group (low, mid, high) of the census tract containing the CTA station.

## Repository contents

- report/ detailed write-ups of methods and findings
  - *data.pdf* - a detailed report of methods used to clean raw datasets.
  - *report.pdf* - a detailed report of analysis, results, and answers to both primary questions.
- scripts/ R scripts used for data cleaning and analysis
  - *geospatial_data_cleaning.R* – contains code for cleaning, turning two sets of geographic data into geospatial data, joining, and exporting.
  - *01_ridership_analysis.R* - contains code for analyses and visualizations of overall ridership and relationship between income level and ridership recovery.
  - *02_ridership_analysis.R* - contains statistical analysis of magnitude and statistical significance of relationship between income level and ridership recovery across multiple post-pandemic years.
- plots/ Contains all visuals generated using ggplot2 from *01_ridership_analysis.R* and *02_ridership_analysis.R*
- rawdata/ Contains all raw datasets used for this project
- cleandata/ Contains all prepared datasets using Excel, Power Query, and R

## Sources

All found through Chicago Data Portal

- CTA Ridership daily totals [link](https://data.cityofchicago.org/d/5neh-572f)
- CTA L rail stations geographic data [link](https://data.cityofchicago.org/d/3tzw-cg4m)
- U.S. Census Bureau Census Tract Data [link](https://data.cityofchicago.org/d/4hp8-2i8z)
- American Community Survey 5 year data by census tract [link](https://data.cityofchicago.org/d/t68z-cikk)

## Limitations

Be advised that the (cleaned) data provides the income measure of the neighborhood that contains the CTA station. It should not be interpreted as a measure of the individual income of CTA riders. It only accounts for rides recorded at each station, and does not tell us which census tract in which the individual rider resides.

The income data used is representative of people's income living in these census tracts *in 2023*, well after the pandemic had begun. It does not account for changes in tract income over the full period, but still used for the purposes of the project. Also, since we were only given income "buckets," it was necessary to construct *income index*.
