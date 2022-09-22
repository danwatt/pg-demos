COPY breed (breed, description, temperament, popularity, min_height, max_height, min_weight, max_weight, min_expectancy,
            max_expectancy, breed_group, grooming_frequency_value, grooming_frequency_category, shedding_value,
            shedding_category, energy_level_value, energy_level_category, trainability_value, trainability_category,
            demeanor_value, demeanor_category)
    FROM '/docker-entrypoint-initdb.d/breeds.csv'
    DELIMITER ','
    CSV HEADER;

COPY name (name)
    FROM '/docker-entrypoint-initdb.d/names.csv'
    DELIMITER ','
    CSV HEADER;