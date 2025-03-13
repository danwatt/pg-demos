ALTER TABLE demo_table
    ADD version INT NULL;

-- backfill version values - this issues an update to the entire table
-- and may take some time for a large table.

WITH generator AS (
    SELECT id,
           row_number() OVER (
               PARTITION BY synthetic_key
               ORDER BY created_at,id
               ) rn
    FROM demo_table
)
UPDATE demo_table
SET version = g.rn
FROM generator g
WHERE demo_table.id = g.id;

-- Add trigger

CREATE FUNCTION version_trg() RETURNS TRIGGER AS
$$
DECLARE
    current_max INT;
BEGIN
    SELECT coalesce(max(version), 0)
    FROM demo_table
    WHERE synthetic_key = NEW.synthetic_key
    INTO current_max;

    NEW.version = current_max + 1;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- This is implemented as a FOR EACH ROW to simplify the trigger function.
-- What would happen if we issued an INSERT that contained two rows with the same
-- synthetic key?

CREATE TRIGGER trg_insert_demo_version
    BEFORE INSERT
    ON demo_table
    FOR EACH ROW
EXECUTE PROCEDURE version_trg();

-- Make column non-nullable

ALTER TABLE demo_table
    ALTER COLUMN version
        SET NOT NULL;

