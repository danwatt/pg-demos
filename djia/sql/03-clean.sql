-- Add a simple field to track days that are actual trading days, vs holidays and weekends
alter table market
    add trading_day int;


-- Backfill the trading days
update market
set trading_day = 1
where djia is null;

-- Fill weekends
insert into market(observation_date, djia)
SELECT CAST('2015-03-11' AS DATE) + (n || ' day')::INTERVAL, null::double precision
FROM generate_series(0, 3700) n
EXCEPT
select observation_date, null
from market;

DELETE
from market
where observation_date > now();

-- Fill holidays / non-trading days with the previous close
with filler as (select observation_date,
                       djia,
                       coalesce(djia, lag(djia) over(order by observation_date)) as previousClose
                from market)
update market as d
set djia = f.previousClose from filler as f
where f.observation_date = d.observation_date
  and d.djia is null
  and f.previousClose is not null;

-- Run twice, because we could have two days in a row.
-- TODO: Exercise for later - there is a way to do this as a single statement
with filler as (select observation_date,
                       djia,
                       coalesce(djia, lag(djia) over(order by observation_date)) as previousClose
                from market)
update market as d
set djia = f.previousClose from filler as f
where f.observation_date = d.observation_date
  and d.djia is null
  and f.previousClose is not null;

-- Fill one mroe time, because there are 3-day weekends
with filler as (select observation_date,
                       djia,
                       coalesce(djia, lag(djia) over(order by observation_date)) as previousClose
                from market)
update market as d
set djia = f.previousClose from filler as f
where f.observation_date = d.observation_date
  and d.djia is null
  and f.previousClose is not null;

-- Backfill non-trading days
update market
set trading_day = 0
where djia is null;