CREATE TABLE demo_table
(
    id            SERIAL PRIMARY KEY NOT NULL,
    created_at    TIMESTAMPTZ DEFAULT clock_timestamp(),
    synthetic_key CHAR(36)           NOT NULL
);

CREATE INDEX ix_demo_table_sk
    ON demo_table (synthetic_key);