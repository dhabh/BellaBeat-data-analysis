-- Viewing the structure of the table to understand its schema
DESCRIBE dailyActivity;

-- Check the number of records in the dataset
SELECT COUNT(*) AS total_records FROM dailyActivity;

-- Check distinct values for key fields like user_id or activity type
SELECT COUNT(DISTINCT user_id) AS unique_users FROM dailyActivity;

-- Basic statistics on steps, heart rate, etc.
SELECT 
    MIN(steps) AS min_steps, 
    MAX(steps) AS max_steps, 
    AVG(steps) AS avg_steps 
FROM dailyActivity;
-- Repeated for other csv files as well
-- Cleaning
-- Remove duplicates from the daily activity data based on the Id and ActivityDate
DELETE FROM daily_activity
WHERE rowid NOT IN (
    SELECT MIN(rowid)
    FROM daily_activity
    GROUP BY Id, ActivityDate
);
-- Replace NULL values in steps with 0, assuming 0 means no activity for the day
UPDATE daily_activity
SET TotalSteps = 0
WHERE TotalSteps IS NULL;
-- Convert ActivityDate from string to proper DATE format
ALTER TABLE daily_activity
MODIFY ActivityDate DATE;

-- For example, in MySQL, you might want to change a date format string to a DATE type
UPDATE daily_activity
SET ActivityDate = STR_TO_DATE(ActivityDate, '%m/%d/%Y');

-- Remove rows where TotalSteps are greater than a reasonable threshold (e.g., 50,000)
DELETE FROM daily_activity
WHERE TotalSteps > 50000;

-- Trim leading/trailing spaces and standardize all strings to lowercase (for activity types, for example)
UPDATE daily_activity
SET ActivityType = LOWER(TRIM(ActivityType));

-- Replace NULL heart rate values with the average heart rate for that user
UPDATE heartrate_data hr
SET hr.Value = (
    SELECT AVG(Value)
    FROM heartrate_data
    WHERE Id = hr.Id AND Value IS NOT NULL
)
WHERE hr.Value IS NULL;

-- Repeated for other csv files as well
