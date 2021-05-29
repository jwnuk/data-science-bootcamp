 
--zestawienie ludnosci w poszczegolnych stanach--
drop table state_summary;
create temp table state_summary
as
select 
	cf.fips 
,	cf.area_name 
,	cf.rhi125214 whites_percentage
,	cf.rhi225214 black_amercian_or_african_percentage
,	cf.rhi325214 american_indian_or_alaska_percentage
,	cf.rhi425214 asian_percentage
,	cf.rhi525214 native_hwaian_or_pacific_ocean_percentage
,	cf.rhi725214 hispanic_or_latino_percentage
,	cf.rhi625214 two_or_more_races_percentage
from county_facts cf
where cf.state_abbreviation is null
order by cf.area_name ;

select * from state_summary;

--zestawienie g�os�w na partie--
drop table summary_votes;
create temp table summary_votes
as
select
	pr.state 
,	pr.state_abbreviation 
,	pr.party
,	sum(pr.votes) summary_votes
,	rank() over (partition by pr.state order by sum(pr.votes)desc) 
from primary_results pr
group by pr.state, pr.state_abbreviation, pr.party 
order by pr.state;

select * from summary_votes;

--zestawienie stan�w, w kt�rycn wygrali demokraci--

--drop table democrat_winners;

create temp table democrat_winners
as
select 
	state
,	state_abbreviation
,	party
,	summary_votes
,	whites_percentage
,	black_amercian_or_african_percentage
,	american_indian_or_alaska_percentage
,	asian_percentage
,	native_hwaian_or_pacific_ocean_percentage
,	hispanic_or_latino_percentage
,	two_or_more_races_percentage
from summary_votes
right join state_summary on area_name=state
where "rank" = 1 and "party" like 'Democrat';

select * from democrat_winners;

--zestawienie stan�w, w kt�rycn wygrali republikanie--

create temp table republican_winners
as
select 
	state
,	state_abbreviation
,	party
,	summary_votes
,	whites_percentage
,	black_amercian_or_african_percentage
,	american_indian_or_alaska_percentage
,	asian_percentage
,	native_hwaian_or_pacific_ocean_percentage
,	hispanic_or_latino_percentage
,	two_or_more_races_percentage
from summary_votes
right join state_summary on area_name=state
where "rank" = 1 and "party" like 'Republican';

select * from republican_winners;


--przeliczam �redni� dla ka�dej grupy etnicznej--
drop table average_percentage;
create temp table average_percentage
as
select
	cf.fips 
,	cf.area_name
,	avg(cf.rhi125214) whites_percentage_avg
,	avg(cf.rhi225214) black_amercian_or_african_percentage_avg
,	avg(cf.rhi325214) american_indian_or_alaska_percentage_avg
,	avg(cf.rhi425214) asian_percentage_avg
,	avg(cf.rhi525214) native_hwaian_or_pacific_ocean_percentage_avg
,	avg(cf.rhi725214) hispanic_or_latino_percentage_avg
,	avg(cf.rhi625214) two_or_more_races_percentage_avg
from county_facts cf
where cf.state_abbreviation is null
group by cf.area_name , cf.fips
order by cf.area_name ;

select * from average_percentage;

--zestawienie g�os�w na kandydat�w--
drop table summary_candidate_votes_1;
create temp table summary_candidate_votes_1
as
select distinct
	pr.state 
,	pr.state_abbreviation 
,	pr.candidate
,	pr.party 
,	sum(pr.votes) over (partition by pr.candidate order by pr.state) summary_votes
from primary_results pr
group by pr.state, pr.state_abbreviation, pr.candidate, pr.party, pr.votes
order by pr.state, pr.candidate;

select * from summary_candidate_votes_1;

--drop table summary_candidate_votes;

create temp table summary_candidate_votes
as
select distinct * 
,	rank() over (partition by state order by summary_votes desc) 
from summary_candidate_votes_1
group by state, state_abbreviation, candidate, party, summary_votes
order by state, candidate;

select * from summary_candidate_votes;

--zestawienie zwyci�stw z podzia�em na kandydat�w--
--drop table candidate_winners;
create temp table candidate_winners
as
select distinct 
	state
,	state_abbreviation
,	candidate
,	party
,	summary_votes
,	whites_percentage
,	black_amercian_or_african_percentage
,	american_indian_or_alaska_percentage
,	asian_percentage
,	native_hwaian_or_pacific_ocean_percentage
,	hispanic_or_latino_percentage
,	two_or_more_races_percentage
from summary_candidate_votes
join state_summary on state=area_name
where "rank" = 1;

select * from candidate_winners;

--sprawdzam czy je�li dana grupa etniczna by�a liczniejsza ni� jej �rednia, czy istania�a jaka� tendencja do g�osowania na poszczeg�lnych kandydat�w--

--osoby bia�osk�re--
drop table working_version_whites;
create temp table working_version_whites
as
select 
	state
,	state_abbreviation
,	candidate
,	party
,	summary_votes
,	(case when "candidate" like 'Hillary Clinton' then 1
		 when "candidate" like 'Bernie Sanders' then 2
		 when "candidate" like 'Donald Trump' then 3
		 when "candidate" like 'Ted Cruz' then 4
		 when "candidate" like 'Jeb Bush' then 5
		 when "candidate" like 'Carly Fiorina' then 6
		 when "candidate" like 'Martin O''Malley' then 7
		 when "candidate" like 'John Kasich' then 8
		 when "candidate" like 'Rand Paul' then 9
		 when "candidate" like 'Chris Christie' then 10
		 when "candidate" like 'Ben Carson' then 11
		 when "candidate" like 'Mike Huckabee' then 12
		 when "candidate" like 'Marco Rubio' then 13
		 else 0 end) as ile
from candidate_winners cw
join average_percentage ap on cw.state=ap.area_name
where whites_percentage > whites_percentage_avg
group by state, state_abbreviation, candidate, party, summary_votes ;

select* from working_version_whites wvw;

select 
	candidate
,	party
,	count("ile") as how_many_times_winner
from working_version_whites wvw
group by candidate, party;

--osoby czarnosk�re--
create temp table working_version_black
as
select 
	state
,	state_abbreviation
,	candidate
,	party
,	summary_votes
,	(case when "candidate" like 'Hillary Clinton' then 1
		 when "candidate" like 'Bernie Sanders' then 2
		 when "candidate" like 'Donald Trump' then 3
		 when "candidate" like 'Ted Cruz' then 4
		 when "candidate" like 'Jeb Bush' then 5
		 when "candidate" like 'Carly Fiorina' then 6
		 when "candidate" like 'Martin O''Malley' then 7
		 when "candidate" like 'John Kasich' then 8
		 when "candidate" like 'Rand Paul' then 9
		 when "candidate" like 'Chris Christie' then 10
		 when "candidate" like 'Ben Carson' then 11
		 when "candidate" like 'Mike Huckabee' then 12
		 when "candidate" like 'Marco Rubio' then 13
		 else 0 end) as ile
from candidate_winners cw
join average_percentage ap on cw.state=ap.area_name
where black_amercian_or_african_percentage > black_amercian_or_african_percentage_avg
group by state, state_abbreviation, candidate, party, summary_votes ;

select 
	candidate
,	party
,	count("ile") as how_many_times_winner
from working_version_black
group by candidate, party;

--american_indian_or_alaska--
create temp table working_version_indian
as
select 
	state
,	state_abbreviation
,	candidate
,	party
,	summary_votes
,	(case when "candidate" like 'Hillary Clinton' then 1
		 when "candidate" like 'Bernie Sanders' then 2
		 when "candidate" like 'Donald Trump' then 3
		 when "candidate" like 'Ted Cruz' then 4
		 when "candidate" like 'Jeb Bush' then 5
		 when "candidate" like 'Carly Fiorina' then 6
		 when "candidate" like 'Martin O''Malley' then 7
		 when "candidate" like 'John Kasich' then 8
		 when "candidate" like 'Rand Paul' then 9
		 when "candidate" like 'Chris Christie' then 10
		 when "candidate" like 'Ben Carson' then 11
		 when "candidate" like 'Mike Huckabee' then 12
		 when "candidate" like 'Marco Rubio' then 13
		 else 0 end) as ile
from candidate_winners cw
join average_percentage ap on cw.state=ap.area_name
where american_indian_or_alaska_percentage > american_indian_or_alaska_percentage_avg
group by state, state_abbreviation, candidate, party, summary_votes ;

select 
	candidate
,	party
,	count("ile") as how_many_times_winner
from working_version_indian
group by candidate, party;

--asian--
create temp table working_version_asian
as
select 
	state
,	state_abbreviation
,	candidate
,	party
,	summary_votes
,	(case when "candidate" like 'Hillary Clinton' then 1
		 when "candidate" like 'Bernie Sanders' then 2
		 when "candidate" like 'Donald Trump' then 3
		 when "candidate" like 'Ted Cruz' then 4
		 when "candidate" like 'Jeb Bush' then 5
		 when "candidate" like 'Carly Fiorina' then 6
		 when "candidate" like 'Martin O''Malley' then 7
		 when "candidate" like 'John Kasich' then 8
		 when "candidate" like 'Rand Paul' then 9
		 when "candidate" like 'Chris Christie' then 10
		 when "candidate" like 'Ben Carson' then 11
		 when "candidate" like 'Mike Huckabee' then 12
		 when "candidate" like 'Marco Rubio' then 13
		 else 0 end) as ile
from candidate_winners cw
join average_percentage ap on cw.state=ap.area_name
where asian_percentage > asian_percentage_avg
group by state, state_abbreviation, candidate, party, summary_votes ;

select 
	candidate
,	party
,	count("ile") as how_many_times_winner
from working_version_asian
group by candidate, party;

--native_hwaian_or_pacific_ocean--

create temp table working_version_hawaian
as
select 
	state
,	state_abbreviation
,	candidate
,	party
,	summary_votes
,	(case when "candidate" like 'Hillary Clinton' then 1
		 when "candidate" like 'Bernie Sanders' then 2
		 when "candidate" like 'Donald Trump' then 3
		 when "candidate" like 'Ted Cruz' then 4
		 when "candidate" like 'Jeb Bush' then 5
		 when "candidate" like 'Carly Fiorina' then 6
		 when "candidate" like 'Martin O''Malley' then 7
		 when "candidate" like 'John Kasich' then 8
		 when "candidate" like 'Rand Paul' then 9
		 when "candidate" like 'Chris Christie' then 10
		 when "candidate" like 'Ben Carson' then 11
		 when "candidate" like 'Mike Huckabee' then 12
		 when "candidate" like 'Marco Rubio' then 13
		 else 0 end) as ile
from candidate_winners cw
join average_percentage ap on cw.state=ap.area_name
where native_hwaian_or_pacific_ocean_percentage > native_hwaian_or_pacific_ocean_percentage_avg
group by state, state_abbreviation, candidate, party, summary_votes ;

select 
	candidate
,	party
,	count("ile") as how_many_times_winner
from working_version_hawaian
group by candidate, party;

--hispanic_or_latino--
create temp table working_version_hispanic_or_latino
as
select 
	state
,	state_abbreviation
,	candidate
,	party
,	summary_votes
,	(case when "candidate" like 'Hillary Clinton' then 1
		 when "candidate" like 'Bernie Sanders' then 2
		 when "candidate" like 'Donald Trump' then 3
		 when "candidate" like 'Ted Cruz' then 4
		 when "candidate" like 'Jeb Bush' then 5
		 when "candidate" like 'Carly Fiorina' then 6
		 when "candidate" like 'Martin O''Malley' then 7
		 when "candidate" like 'John Kasich' then 8
		 when "candidate" like 'Rand Paul' then 9
		 when "candidate" like 'Chris Christie' then 10
		 when "candidate" like 'Ben Carson' then 11
		 when "candidate" like 'Mike Huckabee' then 12
		 when "candidate" like 'Marco Rubio' then 13
		 else 0 end) as ile
from candidate_winners cw
join average_percentage ap on cw.state=ap.area_name
where hispanic_or_latino_percentage > hispanic_or_latino_percentage_avg
group by state, state_abbreviation, candidate, party, summary_votes ;

select 
	candidate
,	party
,	count("ile") as how_many_times_winner
from working_version_hispanic_or_latino
group by candidate, party;

--two_or_more_races--

create temp table working_version_two_or_more_races
as
select 
	state
,	state_abbreviation
,	candidate
,	party
,	summary_votes
,	(case when "candidate" like 'Hillary Clinton' then 1
		 when "candidate" like 'Bernie Sanders' then 2
		 when "candidate" like 'Donald Trump' then 3
		 when "candidate" like 'Ted Cruz' then 4
		 when "candidate" like 'Jeb Bush' then 5
		 when "candidate" like 'Carly Fiorina' then 6
		 when "candidate" like 'Martin O''Malley' then 7
		 when "candidate" like 'John Kasich' then 8
		 when "candidate" like 'Rand Paul' then 9
		 when "candidate" like 'Chris Christie' then 10
		 when "candidate" like 'Ben Carson' then 11
		 when "candidate" like 'Mike Huckabee' then 12
		 when "candidate" like 'Marco Rubio' then 13
		 else 0 end) as ile
from candidate_winners cw
join average_percentage ap on cw.state=ap.area_name
where two_or_more_races_percentage > two_or_more_races_percentage_avg
group by state, state_abbreviation, candidate, party, summary_votes ;

select 
	candidate
,	party
,	count("ile") as how_many_times_winner
from working_version_two_or_more_races
group by candidate, party;

--sparawdzam czarnosk�rego kandydata Ben Carson w jakich stanach najepiej mu posz�o--
--czy w tych stanach procent os�b czarnosk�rych by� wy�szy ni� przeci�tnie--

select * from candidate_winners
where "candidate" like 'Ben Carson'; 


select*from summary_candidate_votes scv;

select * from summary_candidate_votes scv
join average_percentage ap on scv.state=ap.area_name
join candidate_winners cw on scv.state = cw.state
where scv."candidate" like 'Ben Carson' and black_amercian_or_african_percentage > black_amercian_or_african_percentage_avg;

