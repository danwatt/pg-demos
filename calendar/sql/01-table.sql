create table calendar
(
    date             date        not null primary key,
    year             smallint    not null,
    month            smallint    not null,
    day              smallint    not null,
    day_of_week      smallint    not null, -- 0 = Sunday
    nth_week_day     smallint    not null,-- 1 = 1st Tuesday, 2 = 2nd Tuesday, etc.
    day_of_year      smallint    not null,
    week_of_month    smallint    not null,
    is_weekday       boolean default false,
    is_holiday       boolean default false,
    is_office_closed boolean default false,
    description      varchar(64) null
)