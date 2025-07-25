-- First, insert unique facility information into ice_facility
INSERT INTO ice_facility (name,
                          address,
                          city,
                          state,
                          zip,
                          aor,
                          type_detailed,
                          male_female)
SELECT DISTINCT name,
                address,
                city,
                state,
                zip,
                aor,
                type_detailed,
                male_female
FROM ice_raw_data;

-- Then, transform float columns into measurements in ice_measurement
-- This uses CROSS JOIN LATERAL to unpivot the float columns
INSERT INTO ice_measurement (facility_id,
                             measured_on,
                             data_point,
                             value)
SELECT f.id          as facility_id,
       r.report_date as measured_on,
       m.data_point,
       m.value
FROM ice_raw_data r
         JOIN ice_facility f ON r.name = f.name AND
                                r.address = f.address
         CROSS JOIN LATERAL (
    VALUES ('fy25_alos', r.fy25_alos),
           ('level_a', r.level_a),
           ('level_b', r.level_b),
           ('level_c', r.level_c),
           ('level_d', r.level_d),
           ('male_crim', r.male_crim),
           ('male_non_crim', r.male_non_crim),
           ('female_crim', r.female_crim),
           ('female_non_crim', r.female_non_crim),
           ('ice_threat_level_1', r.ice_threat_level_1),
           ('ice_threat_level_2', r.ice_threat_level_2),
           ('ice_threat_level_3', r.ice_threat_level_3),
           ('no_ice_threat_level', r.no_ice_threat_level),
           ('mandatory', r.mandatory)
    ) m(data_point, value);

-- Temporary
delete from ice_measurement where measured_on >= '2025-07-07';

WITH DateOffsets AS (
    -- Calculate days into fiscal year for each measurement
    SELECT id,
           facility_id,
           data_point,
           measured_on,
           value,
           measured_on + 1 - CASE
                                 WHEN EXTRACT(MONTH FROM measured_on) < 10 THEN
                                     TO_DATE(EXTRACT(YEAR FROM measured_on) - 1 || '-10-01', 'YYYY-MM-DD')
                                 ELSE
                                     TO_DATE(EXTRACT(YEAR FROM measured_on) || '-10-01', 'YYYY-MM-DD')
               END
               as days_into_fiscal_year
    FROM ice_measurement),

     PreviousValues AS (
         -- Get previous measurement for each facility/data_point combination
         SELECT d.*,
                LAG(value) OVER w                 as prev_value,
                LAG(days_into_fiscal_year) OVER w as prev_days_into_year
         FROM DateOffsets d
         WINDOW w AS (
                 PARTITION BY facility_id, data_point
                 ORDER BY measured_on
                 )),
     intervals as (select *,
                          days_into_fiscal_year * value                 as detention_days,
                          prev_days_into_year * prev_value              as previous_detention_days,
                          days_into_fiscal_year - prev_days_into_year   as days,
                          (days_into_fiscal_year * value - prev_days_into_year * prev_value) /
                          (days_into_fiscal_year - prev_days_into_year) as interval_value
                   from PreviousValues)
update ice_measurement
set interval_value = u.interval_value
from intervals u
where ice_measurement.id = u.id;

update ice_measurement
set interval_value = value
where interval_value is null;
