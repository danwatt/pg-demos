-- Export denormalized data to CSV
-- This query joins facility data with measurements and pivots the data points
-- to create a denormalized view with all required data points in a single row

COPY (
    SELECT 
        f.name AS facility_name,
        f.state,
        m.measured_on,
        MAX(CASE WHEN m.data_point = 'level_a' THEN m.interval_value END) AS level_a,
        MAX(CASE WHEN m.data_point = 'level_b' THEN m.interval_value END) AS level_b,
        MAX(CASE WHEN m.data_point = 'level_c' THEN m.interval_value END) AS level_c,
        MAX(CASE WHEN m.data_point = 'level_d' THEN m.interval_value END) AS level_d,
        MAX(CASE WHEN m.data_point = 'male_crim' THEN m.interval_value END) AS male_crim,
        MAX(CASE WHEN m.data_point = 'male_non_crim' THEN m.interval_value END) AS male_non_crim,
        MAX(CASE WHEN m.data_point = 'female_crim' THEN m.interval_value END) AS female_crim,
        MAX(CASE WHEN m.data_point = 'female_non_crim' THEN m.interval_value END) AS female_non_crim,
        MAX(CASE WHEN m.data_point = 'ice_threat_level_1' THEN m.interval_value END) AS ice_threat_level_1,
        MAX(CASE WHEN m.data_point = 'ice_threat_level_2' THEN m.interval_value END) AS ice_threat_level_2,
        MAX(CASE WHEN m.data_point = 'ice_threat_level_3' THEN m.interval_value END) AS ice_threat_level_3,
        MAX(CASE WHEN m.data_point = 'no_ice_threat_level' THEN m.interval_value END) AS no_ice_threat_level
    FROM 
        ice_facility f
    JOIN 
        ice_measurement m ON f.id = m.facility_id
    WHERE 
        m.data_point IN (
            'level_a', 'level_b', 'level_c', 'level_d',
            'male_crim', 'male_non_crim', 'female_crim', 'female_non_crim',
            'ice_threat_level_1', 'ice_threat_level_2', 'ice_threat_level_3', 'no_ice_threat_level'
        )
    GROUP BY 
        f.name, f.state, m.measured_on
    ORDER BY 
        f.name, f.state, m.measured_on
) TO '/tmp/out/ice_denormalized_data.csv' WITH CSV DELIMITER ',' HEADER;
