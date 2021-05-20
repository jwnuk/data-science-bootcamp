/*liczba g³osów na dan¹ partiê w poszczególnych hrabstwach*/
create view party_votes_per_county as
select
	pr.fips ,
	pr.state ,
	pr.county ,
	pr.party ,
	sum(pr.votes) as votes_for_party
from
	primary_results pr
group by
	pr.fips ,
	pr.state ,
	pr.county ,
	pr.party
order by
	pr.fips ;

select
	*
from
	party_votes_per_county ;

/*procent g³osów na dan¹ partiê w poszczególnych hrabstwach*/
create view percent_party_per_county as
select
	pvpc.* ,
	sv.vote_sum ,
	case
		when vote_sum = 0 then null
		else round(pvpc.votes_for_party::numeric / sv.vote_sum * 100, 3)
	end as vote_percent
from
	party_votes_per_county pvpc
left join (
	select
		fips ,
		sum(votes) vote_sum
	from
		primary_results pr
	group by
		fips ) as sv on
	pvpc.fips = sv.fips ;

select
	*
from
	percent_party_per_county ;

/*liczba g³osów na dan¹ partiê w poszczególnych stanach*/
create view party_votes_per_state as
select
	pr.state ,
	pr.party ,
	sum(pr.votes) votes
from
	county_facts cf
right join primary_results pr on
	cf.fips = pr.fips
group by
	pr.state ,
	pr.party
order by
	pr.state ;

select
	*
from
	party_votes_per_state ;

/*procent g³osów na dan¹ partiê w poszczególnych stanach*/
create view percent_party_per_state as
select
	* ,
	sum(votes) over (partition by state) vote_sum ,
	round(votes / sum(votes) over (partition by state) * 100, 3) vote_percent
from
	party_votes_per_state ;

select
	*
from
	percent_party_per_state ;
--ranking kandydatów w poszczególnych stanach 
 create view candidates_in_states as
select
	pr.state ,
	pr.party ,
	pr.candidate ,
	sum(pr.votes) votes ,
	rank() over(partition by pr.state
order by
	sum(pr.votes) desc) ranking
from
	primary_results pr
group by
	pr.state ,
	pr.candidate ,
	pr.party
order by
	pr.state ;

select
	*
from
	candidates_in_states ;
--ranking kandydatów w poszczególnych stanach z wartoœciami procentowymi
 create view candidates_percent_in_states as
select
	* ,
	sum(votes) over (partition by state) vote_sum ,
	round(votes / sum(votes) over (partition by state) * 100::numeric, 3) percent_votes
from
	candidates_in_states ;

select
	*
from
	candidates_percent_in_states ;
--wygrani w poszczególnych stanach
 create view winners_in_states as
select
	*
from
	candidates_percent_in_states
where
	ranking = 1 ;

select
	*
from
	winners_in_states ;
