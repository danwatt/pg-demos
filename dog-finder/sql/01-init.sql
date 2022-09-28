CREATE TABLE name
(
    name varchar
);

CREATE TABLE breed
(
    id                          serial primary key,
    breed                       varchar(128),
    description                 text,
    temperament                 text,
    popularity                  int,
    min_height                  float4,
    max_height                  float4,
    min_weight                  float4,
    max_weight                  float4,
    min_expectancy              float4,
    max_expectancy              float4,
    breed_group                 varchar(128),
    grooming_frequency_value    float4,
    grooming_frequency_category varchar(128),
    shedding_value              float4,
    shedding_category           varchar(128),
    energy_level_value          float4,
    energy_level_category       varchar(128),
    trainability_value          float4,
    trainability_category       varchar(128),
    demeanor_value              float4,
    demeanor_category           varchar(128)
);

create index ix_breed_name
    on breed (breed);


create table dog
(
    id   serial primary key,
    name varchar(128)
);

create index ix_dog_name
    on dog (name);

create table dog_breed
(
    dog_id   int not null,
    breed_id int not null
);

create unique index ux_dog_breed
    on dog_breed (dog_id, breed_id);

create unique index ux_dog_breed_reversed
    on dog_breed (breed_id,dog_id);

create index ix_dog_breed_breed_id
    on dog_breed (breed_id) ;


-- "Unknown" table

create table dog_breed_unknown
(
    dog_id   int not null,
    breed_id int not null
);

create unique index ux_dog_breed_unknown
    on dog_breed_unknown (dog_id, breed_id);

create index ix_dog_breed_unknown_breed_id
    on dog_breed_unknown (breed_id);




