-- Overall activity summary report
SELECT
  COUNT(DISTINCT Id) AS total_users,
  AVG(TotalSteps) AS avg_steps_per_day,
  AVG(TotalDistance) AS avg_distance_per_day,
  AVG(Calories) AS avg_calories_burned,
  AVG(VeryActiveMinutes) AS avg_very_active_minutes,
  AVG(FairlyActiveMinutes) AS avg_fairly_active_minutes,
  AVG(LightlyActiveMinutes) AS avg_lightly_active_minutes,
  AVG(SedentaryMinutes) AS avg_sedentary_minutes
FROM
  `data_analytics_cert.fitbit.dailyActivity_merged`;

-- Sleep summary report
WITH sleep_summary AS (
  SELECT
    Id,
    MIN(DATE(date)) AS sleep_date,
    SUM(CASE WHEN sleep_start = sleep_end THEN 1 ELSE 0 END) AS number_of_naps,
    SUM(EXTRACT(HOUR FROM time_sleeping)) AS total_sleep_hours
  FROM (
    SELECT
      Id,
      logId,
      MIN(DATE(date)) AS sleep_start,
      MAX(DATE(date)) AS sleep_end,
      TIME(TIMESTAMP_DIFF(MAX(date), MIN(date), HOUR),
        MOD(TIMESTAMP_DIFF(MAX(date), MIN(date), MINUTE), 60),
        MOD(TIMESTAMP_DIFF(MAX(date), MIN(date), SECOND), 60)) AS time_sleeping
    FROM
      `data_analytics_cert.fitbit.minuteSleep_merged`
    WHERE
      value = 1
    GROUP BY
      Id, logId
  )
  GROUP BY
    Id, sleep_date
)
SELECT
  COUNT(DISTINCT Id) AS total_users,
  AVG(number_of_naps) AS avg_naps_per_user,
  AVG(total_sleep_hours) AS avg_sleep_hours_per_user
FROM
  sleep_summary;

-- Activity intensity report by time of day
WITH user_activity AS (
  SELECT
    Id,
    CASE
      WHEN TIME(ActivityHour) BETWEEN TIME(6, 0, 0) AND TIME(12, 0, 0) THEN 'Morning'
      WHEN TIME(ActivityHour) BETWEEN TIME(12, 0, 0) AND TIME(18, 0, 0) THEN 'Afternoon'
      WHEN TIME(ActivityHour) BETWEEN TIME(18, 0, 0) AND TIME(21, 0, 0) THEN 'Evening'
      ELSE 'Night'
    END AS time_of_day,
    SUM(TotalIntensity) AS total_intensity,
    AVG(AverageIntensity) AS average_intensity
  FROM
    `data_analytics_cert.fitbit.hourlyIntensities_merged`
  GROUP BY
    Id, time_of_day
)
SELECT
  time_of_day,
  COUNT(DISTINCT Id) AS total_users,
  AVG(total_intensity) AS avg_total_intensity,
  AVG(average_intensity) AS avg_intensity_per_user
FROM
  user_activity
GROUP BY
  time_of_day
ORDER BY
  time_of_day;

-- Weekly activity summary report
WITH activity_by_day AS (
  SELECT
    Id,
    FORMAT_TIMESTAMP('%A', ActivityHour) AS day_of_week,
    CASE
      WHEN FORMAT_TIMESTAMP('%A', ActivityHour) IN ('Saturday', 'Sunday') THEN 'Weekend'
      ELSE 'Weekday'
    END AS day_type,
    SUM(TotalIntensity) AS total_intensity,
    AVG(AverageIntensity) AS average_intensity
  FROM
    `data_analytics_cert.fitbit.hourlyIntensities_merged`
  GROUP BY
    Id, day_of_week, day_type
)
SELECT
  day_of_week,
  day_type,
  COUNT(DISTINCT Id) AS total_users,
  AVG(total_intensity) AS avg_total_intensity,
  AVG(average_intensity) AS avg_intensity_per_user
FROM
  activity_by_day
GROUP BY
  day_of_week, day_type
ORDER BY
  FIELD(day_of_week, 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday');

-- Calories burned vs. activity report
SELECT
  A.Id,
  A.ActivityDate,
  SUM(A.TotalSteps) AS total_steps,
  AVG(A.TotalDistance) AS avg_distance,
  SUM(A.Calories) AS total_calories_burned,
  AVG(I.TotalIntensity) AS avg_intensity
FROM
  `data_analytics_cert.fitbit.dailyActivity_merged` A
LEFT JOIN
  `data_analytics_cert.fitbit.dailyIntensities_merged` I
ON
  A.Id = I.Id AND A.ActivityDate = I.ActivityDay
GROUP BY
  A.Id, A.ActivityDate
ORDER BY
  total_calories_burned DESC;

-- Activity intensity decile summary report
WITH user_activity_summary AS (
  SELECT
    Id,
    CASE
      WHEN TIME(ActivityHour) BETWEEN TIME(6, 0, 0) AND TIME(12, 0, 0) THEN 'Morning'
      WHEN TIME(ActivityHour) BETWEEN TIME(12, 0, 0) AND TIME(18, 0, 0) THEN 'Afternoon'
      WHEN TIME(ActivityHour) BETWEEN TIME(18, 0, 0) AND TIME(21, 0, 0) THEN 'Evening'
      ELSE 'Night'
    END AS time_of_day,
    SUM(TotalIntensity) AS total_intensity
  FROM
    `data_analytics_cert.fitbit.hourlyIntensities_merged`
  GROUP BY
    Id, time_of_day
)
SELECT
  time_of_day,
  ROUND(PERCENTILE_CONT(total_intensity, 0.1), 2) AS intensity_10th_percentile,
  ROUND(PERCENTILE_CONT(total_intensity, 0.5), 2) AS intensity_50th_percentile,
  ROUND(PERCENTILE_CONT(total_intensity, 0.9), 2) AS intensity_90th_percentile
FROM
  user_activity_summary
GROUP BY
  time_of_day
ORDER BY
  time_of_day;
