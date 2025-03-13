-- Window Functions - Show change in stock market relative to a president's first day in office

Copy (

    with example as (select observation_date,
                            djia,
                            president,
                            row_number() over w_president                     as nth_day_in_office,
                            first_value(djia) over w_president                as value_on_first_day,
                            (djia / (first_value(djia) over w_president) - 1.0) * 100 as delta
                     from market
                     window w_president as (partition by president order by observation_date))
    select president,nth_day_in_office,delta
    from example
    where nth_day_in_office <= 90
    order by observation_date
) To '/tmp/out/djia-days-in-office.csv' With CSV DELIMITER ',' HEADER;