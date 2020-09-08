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

## Limitations

This assumes that the underlying table is insert-only. There are no
deletes, and no updates. If the `current` record were deleted,
the previous (highest seq number) would need to be marked as current.
If an older record were deleted, you may or may not want to update
seq numbers (ie: if records 1-5 exist, and 3 was removed, do
you want the databaser to have 1,2,4,5, or 1,2,3,4?).

## Running

From a terminal window:

```shell script
make run
```

Connect to the database:
```shell script
psql -h localhost -U postgres
password: (the password is 'password')

select * from demo_table where synthetic_key = (select synthetic_key from demo_table where local_seq > 10 limit 1);
```


