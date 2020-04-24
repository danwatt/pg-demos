CREATE TABLE stringkeys.parent_table
(
    sk   CHAR(20) PRIMARY KEY NOT NULL,
    NAME VARCHAR(256)         NOT NULL
);

CREATE TABLE stringkeys.child_table
(
    sk        CHAR(20) PRIMARY KEY NOT NULL,
    parent_sk CHAR(20)             NOT NULL,
    name      VARCHAR(256)         NOT NULL
);

ALTER TABLE stringkeys.child_table
    ADD CONSTRAINT child_table_parent_table_id_fk
        FOREIGN KEY (parent_sk) REFERENCES stringkeys.parent_table
            ON UPDATE CASCADE ON DELETE CASCADE;

CREATE INDEX child_table_parent_id_index
    ON stringkeys.child_table (parent_sk);

CREATE INDEX child_table_sk_index
    ON stringkeys.child_table (sk);

CREATE INDEX parent_table_sk_index
    ON stringkeys.parent_table (sk);

TRUNCATE stringkeys.parent_table CASCADE;

INSERT INTO stringkeys.parent_table(sk, NAME)
SELECT sk, name
FROM intkeys.parent_table;

INSERT INTO stringkeys.child_table(sk, parent_sk, name)
SELECT ct.sk, pt.sk, ct.name
FROM intkeys.parent_table pt
     JOIN intkeys.child_table ct ON pt.id = ct.parent_id;