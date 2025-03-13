ALTER TABLE demo_table
    ADD current BOOL DEFAULT FALSE;

CREATE INDEX ix_demo_table_current ON demo_table (synthetic_key)
    WHERE current = true;

-- Backfill the `current` value

WITH current_rows AS (
    SELECT synthetic_key, max(version) AS mx
    FROM demo_table
    GROUP BY synthetic_key
)
UPDATE demo_table
SET current = TRUE
FROM current_rows cr
WHERE demo_table.synthetic_key = cr.synthetic_key
  AND demo_table.version = cr.mx;
;

-- Add trigger

CREATE FUNCTION version_current_trg() RETURNS TRIGGER AS
$$
BEGIN

    UPDATE demo_table
    SET current = FALSE
    WHERE current = TRUE
      AND synthetic_key = NEW.synthetic_key;

    NEW.current = TRUE;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_insert_version_current
    BEFORE INSERT
    ON demo_table
    FOR EACH ROW
EXECUTE PROCEDURE version_current_trg();
