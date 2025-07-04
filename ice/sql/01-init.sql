create table ice_raw_data
(
    --Date	Name	Address	City	State	Zip	AOR	Type Detailed	Male/Female	FY25 ALOS	Level A
    report_date              date,
    name                     varchar,
    address                  varchar,
    city                     varchar,
    state                    varchar,
    zip                      varchar,
    aor                      varchar,
    type_detailed            varchar,
    male_female              varchar,
    fy25_alos                float,
    level_a                  float,
    level_b                  float,
    level_c                  float,
    level_d                  float,
    male_crim                float,
    male_non_crim            float,
    female_crim              float,
    female_non_crim          float,
    ice_threat_level_1       float,
    ice_threat_level_2       float,
    ice_threat_level_3       float,
    no_ice_threat_level      float,
    mandatory                float,
    guaranteed_minimum       varchar,
    last_inspection_type     varchar,
    last_inspection_end_date varchar,
    pending_fy25_inspection  varchar,
    last_inspection_standard varchar,
    last_final_rating        varchar
);

create table ice_facility
(
    id            serial,
    name          varchar,
    address       varchar,
    city          varchar,
    state         varchar,
    zip           varchar,
    aor           varchar,
    type_detailed varchar, -- This might change
    male_female   varchar  -- This might change
);

create table ice_measurement
(
    id             serial,
    facility_id    int,
    measured_on    date,
    data_point     varchar,
    value          float,
    interval_value float
);