--sprawdzenie, które kolumny dot. p³ci

select * from county_facts_dictionary cfd 
where lower(cfd.description) like '%fem%'
or lower(cfd.description) like '%sex%'
or lower(cfd.description) like '%gend%';

--wypisanie wyników (primary_results) z kolumn¹ dot. p³ci
select 
	cf.fips
,	cf.sex255214 procent_kobiet
,	cf.area_name cf_area
,	pr.*
from county_facts cf 
right join primary_results pr on cf.fips = pr.fips ;

--wyniki partii w poszczególnych hrabstwach
select 
	cf.fips
,	cf.sex255214 procent_kobiet
,	pr.state 
,	pr.county 
,	pr.party 
,	sum(pr.votes)
from county_facts cf 
right join primary_results pr on cf.fips = pr.fips 
group by cf.fips 
,	cf.sex255214 
,	pr.state
,	pr.county 
,	pr.party
order by pr.state ;

--wyniki partii w poszczególnych stanach
--drop table glosy_partie ;

create temp table glosy_partie
as
select 
	pr.state 
,	round(avg(cf.sex255214),3) sr_kobiet_per_stan
,	pr.party 
,	sum(pr.votes) l_glosow
from county_facts cf 
right join primary_results pr on cf.fips = pr.fips 
group by pr.state 
,	pr.party
order by pr.state ;

select *
,	sum(l_glosow) over (partition by state) suma_glosow
,	round(l_glosow / sum(l_glosow) over (partition by state) *100,3) procent_glosow
from glosy_partie ;

--ranking kandydatów w poszczególnych stanach 
create temp table wyniki_kandydat_stan
as
select 
	pr.state 
,	round(avg(cf.sex255214),3) sr_kobiet_per_stan
,	pr.party 
,	pr.candidate 
,	sum(pr.votes) l_glosow_per_kandydat
,	rank() over(partition by pr.state order by sum(pr.votes) desc) ranking
from county_facts cf 
right join primary_results pr on cf.fips = pr.fips 
group by pr.state 
,	pr.candidate 
,	pr.party
order by pr.state ;

select * from wyniki_kandydat_stan ;

create temp table procent_stan
as
select *
,	sum(l_glosow_per_kandydat) over (partition by state) suma_glosow
,	round(l_glosow_per_kandydat / sum(l_glosow_per_kandydat) over (partition by state) * 100::numeric, 3) procent_glosow
from wyniki_kandydat_stan ;

select * from procent_stan ;

--wyniki dla stanow gdzie >=50% kobiet i <50% kobiet
create temp table counter_more_equal_50
as
select 
	state
,	sr_kobiet_per_stan
,	party
,	candidate
,	procent_glosow
,	case 	when upper(party) = 'DEMOCRAT' then 1 else -1 end counter_more
from procent_stan 
where ranking = 1
and sr_kobiet_per_stan >= 50 ;

select * from counter_more_equal_50 ;

create temp table counter_less_than_50
as
select 
	state
,	sr_kobiet_per_stan
,	party
,	candidate
,	procent_glosow
,	case 	when upper(party) = 'DEMOCRAT' then 1 else -1 end counter_less
from procent_stan 
where ranking = 1
and sr_kobiet_per_stan < 50 ;

select * from counter_less_than_50 ;

select 
	avg(cm.sr_kobiet_per_stan)
,	sum(counter_more) counter
,	case	when sum(counter_more) > 0 then 'Democrat wins'
			when sum(counter_more) < 0 then 'Republican wins'
			else 'Tie' end final_result
from counter_more_equal_50 cm
union
select 
	avg(cl.sr_kobiet_per_stan) counter
,	sum(counter_less)
,	case	when sum(counter_less) > 0 then 'Democrat wins'
			when sum(counter_less) < 0 then 'Republican wins'
			else 'Tie' end final_result
from counter_less_than_50 cl ;

--wygrany/a kandydat/ka z liczb¹ stanów, w których wygrali
select * from procent_stan ;

select 
	candidate
,	party
,	count(*) state_counter
,	avg(procent_glosow) sr_procent_glosow
,	avg(sr_kobiet_per_stan) sr_kobiet
from procent_stan
where ranking = 1 
group by candidate, party
order by sr_kobiet desc ;







