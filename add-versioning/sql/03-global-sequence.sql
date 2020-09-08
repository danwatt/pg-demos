CREATE SEQUENCE global_sequence START 1;

-- This will create the column AND fill in sequence values
-- based on how the rows are ordered in the table
ALTER TABLE demo_table
    ADD global_seq INT NOT NULL DEFAULT nextval('global_sequence');

