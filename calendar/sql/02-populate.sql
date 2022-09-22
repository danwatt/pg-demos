with generator as (select cast(cast('2022-01-01' as date) + (n || ' day')::interval as date) as date
                   from generate_series(0, 365 * 40) n)
insert
into calendar(date,
              year,
              month,
              day,
              day_of_week,
              nth_week_day,
              day_of_year,
              week_of_month,
              is_weekday,
              is_office_closed)
select date,
       extract(year from date)                                               as year,
       extract(month from date)                                              as month,
       extract(day from date)                                                as day,
       extract(dow from date)                                                as day_of_week,
       ((date_part('day', date)::integer - 1) / 7) + 1                       as nth_week_day,
       extract(doy from date)                                                as day_of_year,
       ((date_part('day', date)::integer - 1) / 7) + 1                       as week_of_month,--TODO: Use ISO?
       case when (extract(dow from date)) in (0, 6) then false else true end as is_weekday,
       case when (extract(dow from date)) in (0, 6) then true else false end as is_office_closed
from generator;


-- Lets not go TOO far into the future
delete
from calendar
where year >= 2051;

