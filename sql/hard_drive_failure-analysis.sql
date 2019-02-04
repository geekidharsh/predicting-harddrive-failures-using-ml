-- @author: Harshvardhan Pandey
-- @project name: pandey
-- @table name: hard_drive_stats


-- SQL ANALYSIS SCRIPT WRITTEN FOR THIS CASE

-- Grabbing top 10 based on most common models. 
-- As a secondary check, I verified if the total serial_numbers per model.

#standardSQL
SELECT
  model,
  COUNT(DISTINCT serial_number) serial_num
FROM
  `orbital-linker-226700.pandey.hard_drive_stats`
GROUP BY
  model
ORDER BY
  serial_num DESC
LIMIT
  10



-- filtering dataset by top 10
#standardSQL
SELECT
  *
FROM
  `orbital-linker-226700.pandey.hard_drive_stats`
WHERE
  model IN (
  SELECT
    model
  FROM (
    SELECT
      model,
      COUNT(DISTINCT serial_number) serial_num
    FROM
      `orbital-linker-226700.pandey.hard_drive_stats`
    GROUP BY
      model
    ORDER BY
      serial_num DESC
    LIMIT
      10))




-- filter out the most critical metrics as per SMART systems
-- filtering the data with no critical metrics having empty values
SELECT
  COUNT(*),
  model,
  COUNT(DISTINCT serial_number) number_of_hdd,
  SUM(IF(failure IS TRUE,
      1,
      0)) fails,
  ROUND(SUM(IF(failure IS TRUE,
        1,
        0))/COUNT(DISTINCT serial_number),3) percentage_of_fails,
  SUM(read_error_rate) read_error_rate,
  AVG(reallocated_sector) reallocated_sector,
  AVG( command_timeout ) command_timeout,
  SUM(reported_uncorrect) reported_uncorrect
FROM
  `orbital-linker-226700.pandey.hard_drive_stats_top10_models`
  where 
    reallocated_sector IS NOT NULL
  AND reported_uncorrect IS NOT NULL
  AND command_timeout IS NOT NULL

GROUP BY
  model


-- we see here, 2 of the top 10 models did not fail at all
-- we eleminate these going forward as they do not help up understand failure causes.

-- Models:
Hitachi HDS5C4040ALE630
ST10000NM0086



-- we exclude them from the results moving forward

-- filtering the data with no critical metrics having empty values
SELECT
  model,
  COUNT(DISTINCT serial_number) number_of_hdd,
  SUM(IF(failure IS TRUE,
      1,
      0)) fails,
  ROUND(SUM(IF(failure IS TRUE,
        1,
        0))/COUNT(DISTINCT serial_number),3) percentage_of_fails,
  SUM(read_error_rate) read_error_rate,
  AVG(reallocated_sector) reallocated_sector,
  AVG( command_timeout ) command_timeout,
  SUM(reported_uncorrect) reported_uncorrect
FROM
  `orbital-linker-226700.pandey.hard_drive_stats_top10_models`
where model not like 'Hitachi HDS5C4040ALE630'
and model not like 'ST10000NM0086'
GROUP BY
  model



-- filtering the models with no failure as they wont help with predicting failure
SELECT
  *
FROM
  `orbital-linker-226700.pandey.hard_drive_stats_top10_models`
WHERE
  model NOT LIKE 'Hitachi HDS5C4040ALE630'
  OR model NOT LIKE 'ST10000NM0086'
  AND failure IS TRUE


  -- getting any number of rows with all metrics being not null. result is: 0 rows
SELECT
  spin_up_time,
  start_stop_count,
  reallocated_sector,
  seek_time_performance power_on_hours,
  power_cycle_count,
  reported_uncorrect,
  command_timeout,
  high_fly_writes,
  airflow_temprature,
  load_cycle_count
FROM
  `orbital-linker-226700.pandey.models_with_no_fail`
WHERE
  read_error_rate IS NOT NULL
  AND throughput_performance IS NOT NULL
  AND spin_up_time IS NOT NULL
  AND start_stop_count IS NOT NULL
  AND reallocated_sector IS NOT NULL
  AND seek_time_performance IS NOT NULL
  AND power_on_hours IS NOT NULL
  AND power_cycle_count IS NOT NULL
  AND reported_uncorrect IS NOT NULL
  AND command_timeout IS NOT NULL
  AND high_fly_writes IS NOT NULL
  AND airflow_temprature IS NOT NULL
  AND load_cycle_count IS NOT NULL




-- so not a good idea since there wont be any data left
-- so how do select feautures?

  -- 1. lets base it upon the most number of failures and select feautures that are 
  --    in these failure
  -- 2. filter features by least number of non empty values


  -- getting any number of rows with all metrics being not null. result is: 0 rows
SELECT
  model, SUM(IF( read_error_rate IS NULL,
      1,
      0 )) read_error_rate,
  SUM(IF( throughput_performance IS NULL,
      1,
      0)) throughput_performance,
  SUM(IF( spin_up_time IS NULL,
      1,
      0)) spin_up_time,
  SUM(IF( start_stop_count IS NULL,
      1,
      0)) start_stop_count,
  SUM(IF( reallocated_sector IS NULL,
      1,
      0)) reallocated_sector,
  SUM(IF( seek_time_performance IS NULL,
      1,
      0)) seek_time_performance,
  SUM(IF( power_on_hours IS NULL,
      1,
      0)) power_on_hours,
  SUM(IF( power_cycle_count IS NULL,
      1,
      0)) power_cycle_count,
  SUM(IF( reported_uncorrect IS NULL,
      1,
      0)) reported_uncorrect,
  SUM(IF( command_timeout IS NULL,
      1,
      0)) command_timeout,
  SUM(IF( high_fly_writes IS NULL,
      1,
      0)) high_fly_writes,
  SUM(IF( airflow_temprature IS NULL,
      1,
      0)) airflow_temprature,
  SUM(IF( load_cycle_count IS NULL,
      1,
      0)) load_cycle_count
FROM
  `orbital-linker-226700.pandey.models_with_no_fail` group by model


-- filtering feautures based on data availability
SELECT
  model,
  COUNT(DISTINCT serial_number) number_of_hdd,
  SUM(IF(failure IS TRUE,
      1,
      0)) fails,
  SUM(IF( read_error_rate IS NULL,
      1,
      0 )) read_error_rate,
  SUM(IF( throughput_performance IS NULL,
      1,
      0)) throughput_performance,
  SUM(IF( spin_up_time IS NULL,
      1,
      0)) spin_up_time,
  SUM(IF( start_stop_count IS NULL,
      1,
      0)) start_stop_count,
  SUM(IF( reallocated_sector IS NULL,
      1,
      0)) reallocated_sector,
  SUM(IF( seek_time_performance IS NULL,
      1,
      0)) seek_time_performance,
  SUM(IF( power_on_hours IS NULL,
      1,
      0)) power_on_hours,
  SUM(IF( power_cycle_count IS NULL,
      1,
      0)) power_cycle_count,
  SUM(IF( reported_uncorrect IS NULL,
      1,
      0)) reported_uncorrect,
  SUM(IF( command_timeout IS NULL,
      1,
      0)) command_timeout,
  SUM(IF( high_fly_writes IS NULL,
      1,
      0)) high_fly_writes,
  SUM(IF( airflow_temprature IS NULL,
      1,
      0)) airflow_temprature,
  SUM(IF( load_cycle_count IS NULL,
      1,
      0)) load_cycle_count
FROM
  `orbital-linker-226700.pandey.models_with_no_fail` 

GROUP BY
  model order by fails desc 



--------------------
-- Final conclusions: 
-- Based on this result: 
  -- I am getting rid of all the columns with a high number of empty field
      throughput_performance, 
      seek_time_performance, 
      reported_uncorrect, 
      airflow_temprature, 
      command_timeout, 
      high_fly_writes


