-- Set a seed so this script is repeatable
select setseed(0.1);

insert into dog(name)
select name
from name;

-- Insert primary breed
-- If we wanted to get fancy, we could order this by the breed popularity.
insert into dog_breed(dog_id, breed_id)
select id as dog_id, 1 + ((id * 7) % (select max(id) from breed)) as breed_id
from dog
where random() > 0.1;

-- Insert a secondary breed

insert into dog_breed(dog_id, breed_id)
select id as dog_id, 1 + ((id * 5) % (select max(id) from breed)) as breed_id
from dog d
where random() > 0.6
on conflict do nothing;

-- build 'unknown' table

insert into dog_breed_unknown(dog_id, breed_id)
select dog_id, breed_id
from dog_breed;

insert into breed(breed)
values ('Unknown');

insert into dog_breed_unknown (dog_id, breed_id)
select d.id, (select id from breed where breed.breed = 'Unknown')
from dog d
where d.id not in (select dog_id from dog_breed_unknown);


vacuum analyse;