COPY ice_raw_data (
    report_date ,
    name,
    address ,
    city ,
    state ,
    zip ,
    aor ,
    type_detailed ,
    male_female ,
    fy25_alos ,
    level_a ,
    level_b ,
    level_c ,
    level_d ,
    male_crim ,
    male_non_crim ,
    female_crim ,
    female_non_crim ,
    ice_threat_level_1 ,
    ice_threat_level_2 ,
    ice_threat_level_3 ,
    no_ice_threat_level ,
    mandatory ,
    guaranteed_minimum ,
    last_inspection_type ,
    last_inspection_end_date ,
    pending_fy25_inspection ,
    last_inspection_standard ,
    last_final_rating
    )
    FROM '/docker-entrypoint-initdb.d/ice.csv'

    WITH (
        FORMAT CSV,
        HEADER,
        DELIMITER ',',
        QUOTE '"',
        FORCE_NULL *
    )
;