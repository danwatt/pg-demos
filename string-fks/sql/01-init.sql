--https://www.simononsoftware.com/random-string-in-postgresql/

CREATE OR REPLACE FUNCTION random_text_md5_v2(INTEGER)
    RETURNS TEXT
    LANGUAGE SQL
AS
$$
SELECT upper(
               substring(
                       (SELECT string_agg(md5(random()::TEXT), '')
                        FROM generate_series(
                                1,
                                CEIL($1 / 32.)::INTEGER)
                       ), 1, $1));
$$;


CREATE SCHEMA intkeys;
CREATE SCHEMA stringkeys;