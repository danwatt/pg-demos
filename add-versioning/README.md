## Add Sequence Information

This demo explores adding a trivial global sequence and a local sequence
(grouped by a synthetic key) to an existing table.

This demo is for a system that has a synthetic key defined as a random string.
For ease of generation in this demo, that key will be a GUID.

This system could have multiple inserts for the same GUID. The underlying
table is designed to be insert-only. So, a sample of the data might
look like the following (guids truncated for clarity)

| timestamp | synthetic_key | other values |
| --------- | ---- | ---- |
| 2020-09-05T13:10:00Z | 4cb473af | ... |
| 2020-09-05T13:11:00Z | 4cb473af | ... |
| 2020-09-05T13:12:00Z | 0c03631c | ... |
| 2020-09-05T13:13:00Z | 4cb473af | ... |
| 2020-09-05T13:14:00Z | 0c03631c | ... |

After adding a sequences or a global sequence, plus a flag to identify the most recent (current) record,
 we should end up with:

| timestamp | synthetic_key | local | global | current |
| --------- | ---- | ----- | ------ | ------- | 
| 2020-09-05T13:10:00Z | 4cb473af | 1 | 1 | false |
| 2020-09-05T13:11:00Z | 4cb473af | 2 | 2 | false |
| 2020-09-05T13:12:00Z | 0c03631c | 1 | 3 | false |
| 2020-09-05T13:13:00Z | 4cb473af | 3 | 4 | true |
| 2020-09-05T13:14:00Z | 0c03631c | 2 | 5 | true |

