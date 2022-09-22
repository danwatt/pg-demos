CREATE TABLE test_covid_act_now (
    date date,
    country text,
    state text,
    county text,
    location_id text,
    positive_tests integer null,
    negative_tests integer null,
    total_hospital_beds_used integer null,
    covid_hospital_beds integer null,
    covid_icu_beds integer null,
    new_cases integer null,
    positive_ratio numeric null,
    infection_rate numeric null
);

create table cbsa
(
    code integer      not null
        constraint cbsa_pk
            primary key,
    name varchar(128) not null,
    type varchar(32)  not null
);
