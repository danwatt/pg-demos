CREATE TABLE intkeys.parent_table
(
    id   INT PRIMARY KEY NOT NULL,
    sk   CHAR(20)        NOT NULL,
    NAME VARCHAR(256)    NOT NULL
);

CREATE TABLE intkeys.child_table
(
    id        INT PRIMARY KEY NOT NULL,
    parent_id INT             NOT NULL,
    sk        CHAR(20)        NOT NULL,
    name      VARCHAR(256)    NOT NULL
);

ALTER TABLE intkeys.child_table
    ADD CONSTRAINT child_table_parent_table_id_fk
        FOREIGN KEY (parent_id) REFERENCES intkeys.parent_table
            ON UPDATE CASCADE ON DELETE CASCADE;

CREATE INDEX child_table_parent_id_index
    ON intkeys.child_table (parent_id);

CREATE INDEX child_table_sk_index
    ON intkeys.child_table (sk);

CREATE INDEX parent_table_sk_index
    ON intkeys.parent_table (sk);

TRUNCATE intkeys.parent_table CASCADE;

--Set the random seed so that we can still generate random data,
--but have consistent results between Docker runs
SELECT setseed(0.5);

INSERT INTO intkeys.parent_table(id, sk, name)
SELECT gs,
       public.random_text_md5_v2(20),
       public.random_text_md5_v2(50)
FROM generate_series(1, 10000) gs;

INSERT INTO intkeys.child_table(id, parent_id, sk, name)
SELECT gs,
       floor(random() * ((SELECT COUNT(*) FROM intkeys.parent_table) - 1 + 1)) + 1,
       public.random_text_md5_v2(20),
       public.random_text_md5_v2(50)
FROM generate_series(1, (SELECT COUNT(*) FROM intkeys.parent_table) * 5) gs;