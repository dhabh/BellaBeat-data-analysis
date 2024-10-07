LOAD DATA INFILE 'dailyActivity.csv'
INTO TABLE dailyActivity
FIELDS TERMINATED BY ','
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;
-- Repeated for other files that needs to loaded
