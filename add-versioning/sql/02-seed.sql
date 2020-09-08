CREATE TEMPORARY TABLE guids
(
    rn   INT,
    guid CHAR(36)
);

-- Generate 10,000 guids

INSERT INTO guids(rn, guid)
SELECT gs, gen_random_uuid()
FROM generate_series(1, 10000) gs;

DO
$$
    DECLARE
        generator CURSOR FOR
            -- Select 10,000 (or however many guids were generated above)
            -- combinations of a random row number and a number of times to repeat
            SELECT random_between(
                               (SELECT min(rn) FROM guids),
                               (SELECT max(rn) FROM guids)
                       )                AS row,
                   random_between(1, 3) AS repeats
            FROM guids;
        rownum  INT;
        repeats INT;
        t_guid  CHAR(36);
    BEGIN
        --

        -- Loop over our row number / repeat pairs. Look up the GUID associated
        -- with that row number, and insert it into our demo table {repeat} times
        OPEN generator;
        LOOP
            FETCH generator INTO rownum,repeats;
            EXIT WHEN NOT found;

            SELECT g.guid FROM guids g WHERE rn = rownum INTO t_guid;

            INSERT INTO demo_table(synthetic_key)
            SELECT t_guid
            FROM generate_series(1, repeats);
        END LOOP;
        CLOSE generator;
    END
$$;
