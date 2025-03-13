## Add Version Number

This demo explores adding a versioning column to an existing table. An entity identified by a synthetic key can have
multiple records added to the table over time. There may be a need to add versioning to this table, to be able to identify
the original record, and see what version the entity is currently on, while also preserving history.

A sample of the data might look like the following:

| timestamp              | synthetic_key | other values |
|------------------------|---------------|--------------|
| 2020-09-05T13:10:00Z   | aaaaa         | ...          |
| 2020-09-05T13:11:00Z   | aaaaa         | ...          |
| 2020-09-05T13:12:00Z   | bbbbb         | ...          |
| 2020-09-05T13:13:00Z   | aaaaa         | ...          |
| 2020-09-05T13:14:00Z   | bbbbb         | ...          |

After adding a version number, plus a convenience flag
to identify the most recent (current) record,  we should end up with:

| timestamp            | synthetic_key | version | current  |
|----------------------|---------------|---------|----------|
| 2020-09-05T13:10:00Z | aaaaa         | 1       | false    |
| 2020-09-05T13:11:00Z | aaaaa         | 2       | false    |
| 2020-09-05T13:12:00Z | bbbbb         | 1       | false    |
| 2020-09-05T13:13:00Z | aaaaa         | 3       | true     |
| 2020-09-05T13:14:00Z | bbbbb         | 2       | true     |

## Limitations

This assumes that the underlying table is insert-only. There are no
deletes, and no updates. If the `current` record were deleted,
the previous (highest seq number) would need to be marked as current.
If an older record were deleted, you may or may not want to update
seq numbers (ie: if records 1-5 exist, and 3 was removed, do
you want the database to have 1,2,4,5, or 1,2,3,4?).

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


