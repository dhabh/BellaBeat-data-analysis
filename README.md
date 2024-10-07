# Bellabeat-Case-Study
 Bellabeat is a successful small company, but they have the potential to become a larger player in the global smart device market. Urška Sršen, cofounder and Chief Creative Officer of Bellabeat, believes that analyzing smart device fitness data could help unlock new growth opportunities for the company.

This case study involves analyzing data to uncover trends in smart device usage and providing actionable insights for the company’s marketing strategy. I used SQL where I have imported my CSV files into Google's BigQuery for analysis.

There are 11 CSV file names:

Daily_Activity

Heartrate_seconds

hourly_Calories

hourly_Intensities

hourly_Steps

minuteCaloriesNarrow

minuteIntensitiesNarrow

minuteMETsNarrow

minuteSleep

minuteStepsNarrow

weightLogInfo

ANALYSIS

I performed detailed analysis on user activities based on:

Time of day: It breaks down activity levels (intensity, total steps) into segments like morning, afternoon, evening, and night.

Day of the week: It separates user behavior between weekdays and weekends, providing insights into when users are most or least active.

I identified nap patterns by checking whether users sleep and wake up on the same day. This insight into users’ sleep behaviors (naps, sleep hours) were crucial.

calculations:

Activity intensity (light, moderate, and vigorous) during different times of the day and on different days of the week.

Deciles of activity levels, which helps in understanding the range of activity among different users.

The insights from this analysis help Bellabeat make data-driven decisions about product improvements and features. Understanding how users interact with fitness, sleep, and wellness devices allows Bellabeat to prioritize features that enhance user experience.

DATASET: https://www.kaggle.com/datasets/arashnic/fitbit?resource=download
