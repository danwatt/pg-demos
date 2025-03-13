alter table market add president varchar(64) null;

update market set president = 'OBAMA 1' where observation_date >=' 2009-01-20' and observation_date < '2013-01-21';
update market set president = 'OBAMA 2' where observation_date >=' 2013-01-21' and observation_date < '2017-01-20';
update market set president = 'TRUMP 1' where observation_date >=' 2017-01-20' and observation_date < '2021-01-20';
update market set president = 'BIDEN' where observation_date >=' 2021-01-20' and observation_date < '2025-01-20';
update market set president = 'TRUMP 2' where observation_date >=' 2025-01-20' and observation_date < '2029-01-20';