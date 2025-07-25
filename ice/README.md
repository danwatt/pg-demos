## ICE Detention Data

### Purpose

With the uptick in ICE detentions in 2025, I was curious to see if there was data on this.
[ICE does report this every few weeks](https://www.ice.gov/detain/detention-management).

Looking at the data something felt off - the numbers of people were all presented as floating point numbers.
It turns out that the data that is reported is presented as an average since the start of the
calendar year, not a weekly or daily average.

[Someone else noticed this and devised a way to get better numbers](https://substack.com/home/post/p-167268086),
though just averaged to a few weeks  instead of a daily average or a min/max.

https://relevant-research.com/assets/pdf/methodology_writeup.pdf

I wanted to repeat that in SQL.

## Startup

```bash
make serve
```

Connect to the following: `postgresql://localhost:5432/postgres`

### Automation
To just generate the automated output, assuming running on a Linux or MacOS machine:

```bash
make run
# Wait a few seconds
# pip install pandas matplotlib
```

## HTML Files
This project also has some HTML files that were generated using AI tools, as a means
of visualizing the data.


## Updates
2025-07-25 - I was bringing in the lastest spreadsheet, and noticed that the results were anomalous.
My original source made the same observation: https://substack.com/@austinkocher/p-168637495, and https://adamjsawyer.com/posts/ice_impossibility/.

So for now, I am going to omit the latest data (from 2025-07-07), untill those smarter than I figure it out.