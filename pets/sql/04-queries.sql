-- Problematic query. 1012 rows, 916 cost
EXPLAIN (ANALYZE, COSTS, VERBOSE, BUFFERS, FORMAT JSON) select d.*, b.breed
                from dog d
                         left join dog_breed db on d.id = db.dog_id
                         left join breed b on db.breed_id = b.id
                where b.breed = 'Labrador Retriever'
                   or b.id is null
                group by d.id, b.breed
                order by b.breed nulls last, d.name;


EXPLAIN (ANALYZE, COSTS, VERBOSE, BUFFERS, FORMAT JSON)  select d.*
from dog d
left join dog_breed db on d.id = db.dog_id
where db.dog_id is null;

-- 1012 rows, 260 cost
explain analyse select d.*, case when b.breed = 'Unknown' then NULL else b.breed end as breed
                from dog d
                         join dog_breed_unknown db on d.id = db.dog_id
                         join breed b on db.breed_id = b.id
                where b.breed in ('Labrador Retriever', 'Unknown')
                group by d.id, b.breed
                order by breed asc nulls last,
                         d.name asc;

explain analyse select d.*, b.breed
                from dog d
                         join dog_breed_null db on d.id = db.dog_id
                         left join breed b on db.breed_id = b.id
                where b.breed = 'Labrador Retriever' or db.breed_id is null
                group by d.id, b.breed
                order by breed asc nulls last,
                         d.name asc;