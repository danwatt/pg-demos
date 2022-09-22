select *
from calendar
where year = 2022
  and is_holiday = true;

select count(*)
from calendar
where is_office_closed = false
  and year = 2022;


select distinct year
from calendar
where month = 2 and day = 29;