-- New Year's Day. Always 1/1
update calendar
set is_holiday       = true,
    is_office_closed = true,
    description      = 'New Year''s Day'
where day = 1
  and month = 1;

-- Martin Luther King Jr. Day	-- 3rd Monday of January
update calendar
set is_holiday       = true,
    is_office_closed = true,
    description      = 'Martin Luther King Jr. Day'
where day_of_week = 1
  and nth_week_day = 3
  and month = 1;

-- Washington's Birthday (Presidents Day)	-- 3rd Monday of February

update calendar
set is_holiday       = true,
    is_office_closed = true,
    description      = 'Presidents Day'
where day_of_week = 1
  and nth_week_day = 3
  and month = 2;

-- Memorial Day-- last Monday in May.
update calendar
set is_holiday       = true,
    is_office_closed = true,
    description      = 'Memorial Day'
where day_of_week = 1
  and day between 25 and 31
  and month = 5;

-- Juneteenth National Independence Day	. Always 6/19
update calendar
set is_holiday       = true,
    is_office_closed = true,
    description      = 'Juneteenth'
where day = 19
  and month = 6;

-- Independence Day. Always 7/4
update calendar
set is_holiday       = true,
    is_office_closed = true,
    description      = 'Independence Day'
where day = 4
  and month = 7;

-- Labor Day	-- first Monday in September
update calendar
set is_holiday       = true,
    is_office_closed = true,
    description      = 'Labor Day'
where day_of_week = 1
  and nth_week_day = 1
  and month = 9;

-- Columbus Day	-- second Monday in October
update calendar
set is_holiday       = true,
    is_office_closed = true,
    description      = 'Columbus Day'
where day_of_week = 1
  and nth_week_day = 2
  and month = 10;

-- Veterans Day	-- always 11/11
update calendar
set is_holiday       = true,
    is_office_closed = true,
    description      = 'Veterans Day'
where day = 11
  and month = 11;

-- Thanksgiving Day	-- fourth Thursday in November
update calendar
set is_holiday       = true,
    is_office_closed = true,
    description      = 'Thanksgiving Day'
where day_of_week = 4
  and nth_week_day = 4
  and month = 11;

-- Christmas Day. Always 12/25
update calendar
set is_holiday       = true,
    is_office_closed = true,
    description      = 'Christmas Day'
where day = 25
  and month = 12;


-- Easter is not a US Federal Bank Holiday

-- Derived from https://www.sqlforge.com/index.php/2018/04/01/calculating-easter/
WITH
    YearCte /* Start with a set of years */
        AS
        (select y from generate_series(2020, 2100) y),
/* Here we calculate the Dominical Letter for the year */
    DominicalLetterCte
        AS
        (SELECT y,
                ((y / 100) - (y / 100) / 4 - ((y / 100) - ((y / 100) - 17) / 25) / 3 + 19 *
                                                                                       (y % 19) + 15) % 30 AS i
         FROM YearCte),
/* Here we combine the calculations of the Golden number and Epact of the year */
    GoldenNumberEpactCte
        AS
        (SELECT y,
                i - (i / 28) * (1 - (i / 28) * (29 / (i + 1)) * ((21 - (y % 19)) / 11)) AS i
         FROM DominicalLetterCte),
/* Final adjustment */
    AdjustmentCte
        AS
        (SELECT y,
                i,
                (y + y / 4 + i + 2 - (y / 100) + (y / 100) / 4) % 7 AS j
         FROM GoldenNumberEpactCte),
/* The result */
    ResultCte
        AS
        (SELECT CAST
                    (
                                CAST
                                    (
                                        y AS varchar(4)
                                    ) ||
                                RIGHT('0' || CAST(3 + (i - j + 40) / 44 AS varchar(2)), 2) ||
                                RIGHT('0' || CAST(i - j + 28 - 31 * ((3 + (i - j + 40) / 44) / 4)
                                    AS varchar(2)), 2
                                    ) AS DATE
                    ) AS Date
         FROM AdjustmentCte)
update calendar
set is_holiday       = true,
    is_office_closed = true,
    description      = 'Easter Sunday'
from ResultCte
where calendar.date = ResultCte.Date;

-- Sunday rule: When a Holiday falls on Saturday, Federal Reserve Banks and branches will be open the preceding Friday.
-- For holidays falling on Sunday, all Federal Reserve offices will be closed the following Monday.

with sundayHolidays as (select c2.date, c1.description
                        from calendar c1
                                 join calendar c2 on c2.date = c1.date + interval '1 day'
                        where c1.is_holiday = true
                          and c1.day_of_week = 0
                          and c2.is_holiday = false)
update calendar
set is_holiday        = true,
    is_office_closed = true,
    description      = sh.description || ' (Observed)'
from sundayHolidays sh
where calendar.date = sh.date;
