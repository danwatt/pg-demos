COPY market (observation_date,djia)
    FROM '/docker-entrypoint-initdb.d/DJIA.csv'
    DELIMITER ','
    CSV HEADER;