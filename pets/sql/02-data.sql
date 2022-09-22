COPY test_covid_act_now
FROM '/docker-entrypoint-initdb.d/data.csv'
WITH (
    FORMAT csv,
    DELIMITER ',',
    FORCE_NULL(positive_tests,negative_tests,total_hospital_beds_used,covid_hospital_beds,covid_icu_beds,new_cases,positive_ratio,infection_rate)
)