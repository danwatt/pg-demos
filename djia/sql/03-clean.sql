-- Add a simple field to track days that are actual trading days, vs holidays and weekends
alter table market
    add trading_day int;


-- Backfill the trading days
update market
set trading_day = 1
where djia is not null;

-- Fill weekends or any other missing dates
insert into market(observation_date, djia)
SELECT CAST('2009-01-05' AS DATE) + (n || ' day')::INTERVAL, null::double precision
FROM generate_series(0, 10000) n
WHERE CAST('2009-01-05' AS DATE) + (n || ' day')::INTERVAL <= '2025-12-31'
EXCEPT
select observation_date, null
from market;

DELETE
from market
where observation_date > now();

-- Backfill non-trading days
update market
set trading_day = 0
where djia is null;

-- Fill missing prices with the last known good value.
-- The SQL Standard has an option for last_value(IGNORE NULLS), but as of Postgres 17 this has not been implemented

-- https://stackoverflow.com/a/37471185
with fixer as (
    select observation_date,
           djia,
           (select case when m1.djia is null then m2.djia else m1.djia end
            from market m2
            where m2.observation_date < m1.observation_date
              and m2.djia is not null
            order by m2.observation_date desc
                fetch first 1 row only) as fix
    from market m1
)
update market m
set djia = f.fix
from fixer f
where m.djia is null
  and m.observation_date = f.observation_date;