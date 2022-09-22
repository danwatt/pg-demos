## Covid Act Now SQL Demo

### Purpose

My spouse works in an intensive care unit that takes care of COVID patients. Since the start of the pandemic, we have
attempted to work our family calendar around the various waves, keeping weeks free for her to work extra when it looks
like there will be a surge of patients.

With good data from sources like [COVID ActNow](https://covidactnow.org/about), we can see the correlations between
positive test rates, case numbers, and hospital utilization. I had been using the charts on that website to see if a
surge was happening in our state to see if things were going to get busy in the coming weeks.

I wanted to see how SQL could be used to identify the peaks in the positive test ratio (PTR) and determine the duration
between the PTR peak and the peak in new cases.

## Downloading data
```bash
curl --location --request GET 'https://api.covidactnow.org/v2/states.timeseries.csv?apiKey={API_KEY}'  > states.csv
cut -d, -f 1,2,3,8,11,12,16,20,22,26,30 states.csv > states-limited.csv
```

## Startup

```bash
make run
```

Connect to the following: `postgresql://localhost:5432/postgres`

## SQL

The overall plan is to compute the following:

1. A local maximum for the positive test ratio, and later the case counts. Im using a 31 day back and forth window.
For a given date, look back 31 days and forward 31 days and determine what the maximum PTR is in that window
2. Identify a peak, and identify the first record if there are duplicates
3. Join PTR peaks to case number peaks within a given timeframe

### Step 1: Compute running local maximums

```postgresql
select date,
       state,
       positive_ratio,
       max(positive_ratio)
       over (partition by state
           order by date
           rows between 31 preceding and 31 following
           ) as local_max
from test_covid_act_now
where positive_ratio > 0
  and state = 'TX'
group by 1, 2, 3
order by date
```

| date       | state | positive\_ratio | local\_max |
|:-----------|:------|:----------------|:-----------|
| 2020-04-11 | TX    | 0.141           | 0.148      |
| 2020-04-12 | TX    | 0.136           | 0.148      |
| 2020-04-13 | TX    | 0.131           | 0.148      |
| 2020-04-14 | TX    | 0.128           | 0.148      |
| 2020-04-15 | TX    | 0.148           | 0.148      |
| 2020-04-16 | TX    | 0.146           | 0.148      |
| 2020-04-17 | TX    | 0.142           | 0.148      |
| 2020-04-18 | TX    | 0.144           | 0.148      |


### Step 2: Identify peaks

The second thing we need to do is identify peaks. We want to find records where the `local_max` is equal to the
current `positive_ratio`.

It is possible that we could have two records that are in close proximity that have the same value.

| Date       | Ratio | Local Max | Peak? |
|------------|-------|-----------|-------|
| 2021-01-01 | 0.100 | 0.123     | false |
| 2021-01-02 | 0.123 | 0.123     | true  |
| 2021-01-03 | 0.120 | 0.123     | false |
| 2021-01-04 | 0.123 | 0.123     | true  |
| 2021-01-05 | 0.111 | 0.123     | false |

The records on the 2nd and 4th are both local peaks since they share the same local maximum. What we want to do is
identify the first record and filter out the second and subsequent records. We can do this by using `LAG` to look at the
current record and compare it to the previous record. If the ratio for the current record is equal to the previous
record, we have a repeat. Repeats can be filtered out in the next step.

```postgresql
with testPositivity as (
    select date,
           state,
           positive_ratio,
           max(positive_ratio)
           over (partition by state
               order by date
               rows between 31 preceding and 31 following
               ) as local_max
    from test_covid_act_now
    where positive_ratio > 0
    group by 1, 2, 3
),
     runsTestPositivity as (
         select *,
                lag(positive_ratio) over (
                    partition by state order by date
                    ) = positive_ratio as repeat
         from testPositivity
         where positive_ratio = local_max
         order by date
     ),
     runTestPositvityWithNumber as (
         select date,
                state,
                positive_ratio,
                row_number() over (partition by state order by date) peak_number
         from runsTestPositivity
         where repeat = false
     )
select *
from runTestPositvityWithNumber
where state = 'TX'
```

| date       | state | positive\_ratio | peak\_number |
|:-----------|:------|:----------------|:-------------|
| 2020-07-07 | TX    | 0.245           | 1            |
| 2020-11-13 | TX    | 0.145           | 2            |
| 2021-01-01 | TX    | 0.204           | 3            |
| 2021-08-09 | TX    | 0.184           | 4            |
| 2021-12-28 | TX    | 0.239           | 5            |

### Join PTR peaks to case peaks

```postgresql
with testPositivity as (
    select date,
           state,
           positive_ratio,
           max(positive_ratio)
           over (partition by state
               order by date
               rows between 31 preceding and 31 following
               ) as local_max
    from test_covid_act_now
    where positive_ratio > 0
    group by 1, 2, 3
),
     runsTestPositivity as (
         select *,
                lag(positive_ratio) over (
                    partition by state order by date
                    ) = positive_ratio as repeat
         from testPositivity
         where positive_ratio = local_max
         order by date
     ),
     runTestPositvityWithNumber as (
         select date,
                state,
                positive_ratio,
                row_number() over (partition by state order by date) peak_number
         from runsTestPositivity
         where repeat = false
     ),
     cases as (
         select date,
                state,
                new_cases,
                max(new_cases)
                over (partition by state
                    order by date
                    rows between 31 preceding and 31 following
                    ) as local_max
         FROM test_covid_act_now
         where new_cases > 0
         group by 1, 2, 3
     ),
     runsCases as (
         select *, lag(new_cases) over (partition by state order by date) = new_cases as repeat
         from cases
         where new_cases = local_max
         order by date
     ),
     runsCasesWithNumber as (
         select date,
                state,
                new_cases,
                row_number() over (partition by state order by date) as peak_number
         from runsCases
         where new_cases = local_max
         order by date
     ),
     casesPeakAfterPtr as (
         select ptr.state, ptr.peak_number as ptr_peak_number, min(rcn.peak_number) as case_peak_number
         from runsCasesWithNumber rcn
                  join runTestPositvityWithNumber ptr on rcn.state = ptr.state
             and rcn.date between ptr.date - INTERVAL '14 days' and ptr.date + INTERVAL '60 days'
         group by ptr.state, ptr.peak_number
     )
select ptr.date,
       ptr.state,
       ptr.positive_ratio,
       rcn.new_cases       as new_cases,
       rcn.date            as case_peak,
       rcn.date - ptr.date as days_cases
from runTestPositvityWithNumber ptr
         left join casesPeakAfterPtr c on ptr.state = c.state and ptr.peak_number = c.ptr_peak_number
         left join runsCasesWithNumber rcn on c.case_peak_number = rcn.peak_number and ptr.state = rcn.state
where ptr.state = 'TX'
  --This will filter out some of the early peaks
  and ptr.positive_ratio > 0.1
;

```

## Final Result

The peaks for Texas, exlcuding the very first one, show date differences
of 9, 53, 4, 30, and -1. That last peak is the Omicron wave, which as I am typing this
is still ongoing.

| date       | state | positive\_ratio | new\_cases | case\_peak | days\_cases |
|:-----------|:------|:----------------|:-----------|:-----------|:------------|
| 2020-07-07 | TX    | 0.245           | 15038      | 2020-07-16 | 9           |
| 2020-11-13 | TX    | 0.145           | 30992      | 2021-01-05 | 53          |
| 2021-01-01 | TX    | 0.204           | 30992      | 2021-01-05 | 4           |
| 2021-08-09 | TX    | 0.184           | 42057      | 2021-09-08 | 30          |
| 2021-12-28 | TX    | 0.239           | 53547      | 2021-12-27 | -1          |


## License Notice

Data is licensed under Creative Commons Attribution-NonCommercial-NoDerivatives 4.0 International. Data is provided
by [COVID ActNow](https://covidactnow.org/about).

A small sampling of the COVID ActNow data, current as of January 2, 2021 is included for demonstration purposes only.
Specifically a snapshot of the columns positive test ratio, new cases, date and state for the largest US states were
saved.