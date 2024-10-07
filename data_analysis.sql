-- Analysis of user activity intensity by time of day
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

-- Analyze activity trends by day of the week
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

-- Analyzing sleep patterns and identifying naps
SELECT
  Id,
  sleep_start AS sleep_date,
  COUNT(logId) AS number_of_naps,
  SUM(EXTRACT(HOUR FROM time_sleeping)) AS total_hours_slept
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
WHERE
  sleep_start = sleep_end  -- Assuming naps are when sleep starts and ends on the same day
GROUP BY
  Id, sleep_date
ORDER BY
  number_of_naps DESC;

-- Calculate deciles for activity intensity by part of the week and time of day
WITH user_activity_summary AS (
  SELECT
    Id,
    FORMAT_TIMESTAMP("%A", ActivityHour) AS day_of_week,
    CASE
      WHEN FORMAT_TIMESTAMP("%A", ActivityHour) IN ('Saturday', 'Sunday') THEN 'Weekend'
      ELSE 'Weekday'
    END AS part_of_week,
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
    Id, part_of_week, time_of_day
)
SELECT
  part_of_week,
  time_of_day,
  PERCENTILE_CONT(total_intensity, 0.1) AS intensity_10th_percentile,
  PERCENTILE_CONT(total_intensity, 0.5) AS intensity_50th_percentile,
  PERCENTILE_CONT(total_intensity, 0.9) AS intensity_90th_percentile
FROM
  user_activity_summary
GROUP BY
  part_of_week, time_of_day
ORDER BY
  part_of_week, time_of_day;

-- Comparing calories burned to activity levels (steps, intensity) per day
SELECT
  A.Id,
  A.ActivityDate,
  A.TotalSteps,
  A.TotalDistance,
  A.Calories,
  SUM(I.TotalIntensity) AS total_intensity,
  AVG(I.AverageIntensity) AS average_intensity
FROM
  `data_analytics_cert.fitbit.dailyActivity_merged` A
LEFT JOIN
  `data_analytics_cert.fitbit.dailyIntensities_merged` I
ON
  A.Id = I.Id AND A.ActivityDate = I.ActivityDay
GROUP BY
  A.Id, A.ActivityDate, A.TotalSteps, A.TotalDistance, A.Calories
ORDER BY
  A.Id, A.ActivityDate;
