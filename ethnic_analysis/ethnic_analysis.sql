--zestawienie ludnosci w poszczegolnych stanach--
create temp table state_summary
as
select 
	cf.fips
,	cf.area_name
,	cf.state_abbreviation 
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

select * from state_summary sm;


--zestawienie glosow w poszczegolnych stanach na partie--
create temp table summary_votes
as
select
	pr.state 
,	pr.state_abbreviation 
,	pr.party
,	pr.candidate 
,	sum(pr.votes) summary_votes
,	rank() over (partition by pr.state, pr.party order by sum(pr.votes)desc) 
from primary_results pr
group by pr.state, pr.state_abbreviation, pr.party, pr.candidate 
order by pr.state;

select * from summary_votes sv;

--zestawienie zwyciestw z podzialem na kandydatow--
create temp table candidate_winners
as
select
	sv.state
,	sv.state_abbreviation
,	sv.candidate
,	sv.party
,	sv.summary_votes
,	sm.whites_percentage
,	sm.black_amercian_or_african_percentage
,	sm.american_indian_or_alaska_percentage
,	sm.asian_percentage
,	sm.native_hwaian_or_pacific_ocean_percentage
,	sm.hispanic_or_latino_percentage
,	sm.two_or_more_races_percentage
from summary_votes sv
join state_summary sm on sv.state=sm.area_name
where "rank" = 1;

select * from candidate_winners cw;

--sprawdzam czy jesli dana grupa etniczna byla liczniejsza niz jej srednia, czy istaniala jakas tendencja do glosowania na poszczegolnych kandydatow--

--whites--
create temp table working_version_whites
as
select 
	cw.state
,	cw.state_abbreviation
,	cw.candidate
,	cw.party
,	cw.summary_votes
,	cw.whites_percentage
,	(case 
	 when cw."candidate" like 'Hillary Clinton' then 1
	 when cw."candidate" like 'Bernie Sanders' then 2
	 when cw."candidate" like 'Donald Trump' then 3
	 when cw."candidate" like 'Ted Cruz' then 4
	 when cw."candidate" like 'Jeb Bush' then 5
	 when cw."candidate" like 'Carly Fiorina' then 6
	 when cw."candidate" like 'Martin O''Malley' then 7
	 when cw."candidate" like 'John Kasich' then 8
	 when cw."candidate" like 'Rand Paul' then 9
	 when cw."candidate" like 'Chris Christie' then 10
	 when cw."candidate" like 'Ben Carson' then 11
	 when cw."candidate" like 'Mike Huckabee' then 12
	 when cw."candidate" like 'Marco Rubio' then 13
	 else 0 end) as ile
from candidate_winners cw
where cw.whites_percentage > (select avg(cf.rhi125214) from county_facts cf)
group by cw.state, cw.state_abbreviation, cw.candidate, cw.party, cw.summary_votes, cw.whites_percentage;

select* from working_version_whites wvw;

select 
	candidate
,	party
,	count("ile") as how_many_times_winner
from working_version_whites wvw
group by candidate, party
order by how_many_times_winner desc;

--osoby czarnosk�re--
create temp table working_version_black
as
select 
	cw.state
,	cw.state_abbreviation
,	cw.candidate
,	cw.party
,	cw.summary_votes
,	cw.black_amercian_or_african_percentage
,	(case 
	 when cw."candidate" like 'Hillary Clinton' then 1
	 when cw."candidate" like 'Bernie Sanders' then 2
	 when cw."candidate" like 'Donald Trump' then 3
	 when cw."candidate" like 'Ted Cruz' then 4
	 when cw."candidate" like 'Jeb Bush' then 5
	 when cw."candidate" like 'Carly Fiorina' then 6
	 when cw."candidate" like 'Martin O''Malley' then 7
	 when cw."candidate" like 'John Kasich' then 8
	 when cw."candidate" like 'Rand Paul' then 9
	 when cw."candidate" like 'Chris Christie' then 10
	 when cw."candidate" like 'Ben Carson' then 11
	 when cw."candidate" like 'Mike Huckabee' then 12
	 when cw."candidate" like 'Marco Rubio' then 13
	 else 0 end) as ile
from candidate_winners cw
where cw.black_amercian_or_african_percentage > (select avg(cf.rhi225214) from county_facts cf)
group by cw.state, cw.state_abbreviation, cw.candidate, cw.party, cw.summary_votes, cw.black_amercian_or_african_percentage;

select 
	candidate
,	party
,	count("ile") as how_many_times_winner
from working_version_black
group by candidate, party
order by how_many_times_winner desc;

--american_indian_or_alaska--
create temp table working_version_indian
as
select 
	cw.state
,	cw.state_abbreviation
,	cw.candidate
,	cw.party
,	cw.summary_votes
,	cw.american_indian_or_alaska_percentage
,	(case 
	 when cw."candidate" like 'Hillary Clinton' then 1
	 when cw."candidate" like 'Bernie Sanders' then 2
	 when cw."candidate" like 'Donald Trump' then 3
	 when cw."candidate" like 'Ted Cruz' then 4
	 when cw."candidate" like 'Jeb Bush' then 5
	 when cw."candidate" like 'Carly Fiorina' then 6
	 when cw."candidate" like 'Martin O''Malley' then 7
	 when cw."candidate" like 'John Kasich' then 8
	 when cw."candidate" like 'Rand Paul' then 9
	 when cw."candidate" like 'Chris Christie' then 10
	 when cw."candidate" like 'Ben Carson' then 11
	 when cw."candidate" like 'Mike Huckabee' then 12
	 when cw."candidate" like 'Marco Rubio' then 13
	 else 0 end) as ile
from candidate_winners cw
where cw.american_indian_or_alaska_percentage > (select avg(cf.rhi325214) from county_facts cf)
group by cw.state, cw.state_abbreviation, cw.candidate, cw.party, cw.summary_votes, cw.american_indian_or_alaska_percentage;

select 
	candidate
,	party
,	count("ile") as how_many_times_winner
from working_version_indian
group by candidate, party
order by party, how_many_times_winner desc;

--asian--
create temp table working_version_asian
as
select 
	cw.state
,	cw.state_abbreviation
,	cw.candidate
,	cw.party
,	cw.summary_votes
,	cw.asian_percentage
,	(case 
	 when cw."candidate" like 'Hillary Clinton' then 1
	 when cw."candidate" like 'Bernie Sanders' then 2
	 when cw."candidate" like 'Donald Trump' then 3
	 when cw."candidate" like 'Ted Cruz' then 4
	 when cw."candidate" like 'Jeb Bush' then 5
	 when cw."candidate" like 'Carly Fiorina' then 6
	 when cw."candidate" like 'Martin O''Malley' then 7
	 when cw."candidate" like 'John Kasich' then 8
	 when cw."candidate" like 'Rand Paul' then 9
	 when cw."candidate" like 'Chris Christie' then 10
	 when cw."candidate" like 'Ben Carson' then 11
	 when cw."candidate" like 'Mike Huckabee' then 12
	 when cw."candidate" like 'Marco Rubio' then 13
	 else 0 end) as ile
from candidate_winners cw
where cw.asian_percentage > (select avg(cf.rhi425214) from county_facts cf)
group by cw.state, cw.state_abbreviation, cw.candidate, cw.party, cw.summary_votes, cw.asian_percentage;

select 
	candidate
,	party
,	count("ile") as how_many_times_winner
from working_version_asian
group by party, candidate 
order by party, how_many_times_winner desc;

--native_hwaian_or_pacific_ocean--
create temp table working_version_hawaian
as
select 
	cw.state
,	cw.state_abbreviation
,	cw.candidate
,	cw.party
,	cw.summary_votes
,	cw.native_hwaian_or_pacific_ocean_percentage
,	(case 
	 when cw."candidate" like 'Hillary Clinton' then 1
	 when cw."candidate" like 'Bernie Sanders' then 2
	 when cw."candidate" like 'Donald Trump' then 3
	 when cw."candidate" like 'Ted Cruz' then 4
	 when cw."candidate" like 'Jeb Bush' then 5
	 when cw."candidate" like 'Carly Fiorina' then 6
	 when cw."candidate" like 'Martin O''Malley' then 7
	 when cw."candidate" like 'John Kasich' then 8
	 when cw."candidate" like 'Rand Paul' then 9
	 when cw."candidate" like 'Chris Christie' then 10
	 when cw."candidate" like 'Ben Carson' then 11
	 when cw."candidate" like 'Mike Huckabee' then 12
	 when cw."candidate" like 'Marco Rubio' then 13
	 else 0 end) as ile
from candidate_winners cw
where cw.native_hwaian_or_pacific_ocean_percentage > (select avg(cf.rhi525214) from county_facts cf)
group by cw.state, cw.state_abbreviation, cw.candidate, cw.party, cw.summary_votes, cw.native_hwaian_or_pacific_ocean_percentage;

select 
	candidate
,	party
,	count("ile") as how_many_times_winner
from working_version_hawaian
group by candidate, party
order by party, how_many_times_winner desc;

--hispanic_or_latino--
create temp table working_version_hispanic_or_latino
as
select 
	cw.state
,	cw.state_abbreviation
,	cw.candidate
,	cw.party
,	cw.summary_votes
,	cw.hispanic_or_latino_percentage
,	(case 
	 when cw."candidate" like 'Hillary Clinton' then 1
	 when cw."candidate" like 'Bernie Sanders' then 2
	 when cw."candidate" like 'Donald Trump' then 3
	 when cw."candidate" like 'Ted Cruz' then 4
	 when cw."candidate" like 'Jeb Bush' then 5
	 when cw."candidate" like 'Carly Fiorina' then 6
	 when cw."candidate" like 'Martin O''Malley' then 7
	 when cw."candidate" like 'John Kasich' then 8
	 when cw."candidate" like 'Rand Paul' then 9
	 when cw."candidate" like 'Chris Christie' then 10
	 when cw."candidate" like 'Ben Carson' then 11
	 when cw."candidate" like 'Mike Huckabee' then 12
	 when cw."candidate" like 'Marco Rubio' then 13
	 else 0 end) as ile
from candidate_winners cw
where cw.hispanic_or_latino_percentage > (select avg(cf.rhi725214) from county_facts cf)
group by cw.state, cw.state_abbreviation, cw.candidate, cw.party, cw.summary_votes, cw.hispanic_or_latino_percentage;

select 
	candidate
,	party
,	count("ile") as how_many_times_winner
from working_version_hispanic_or_latino
group by candidate, party
order by party, how_many_times_winner desc;

--two_or_more_races--
create temp table working_version_two_or_more_races
as
select 
	cw.state
,	cw.state_abbreviation
,	cw.candidate
,	cw.party
,	cw.summary_votes
,	cw.two_or_more_races_percentage
,	(case 
	 when cw."candidate" like 'Hillary Clinton' then 1
	 when cw."candidate" like 'Bernie Sanders' then 2
	 when cw."candidate" like 'Donald Trump' then 3
	 when cw."candidate" like 'Ted Cruz' then 4
	 when cw."candidate" like 'Jeb Bush' then 5
	 when cw."candidate" like 'Carly Fiorina' then 6
	 when cw."candidate" like 'Martin O''Malley' then 7
	 when cw."candidate" like 'John Kasich' then 8
	 when cw."candidate" like 'Rand Paul' then 9
	 when cw."candidate" like 'Chris Christie' then 10
	 when cw."candidate" like 'Ben Carson' then 11
	 when cw."candidate" like 'Mike Huckabee' then 12
	 when cw."candidate" like 'Marco Rubio' then 13
	 else 0 end) as ile
from candidate_winners cw
where cw.two_or_more_races_percentage > (select avg(cf.rhi625214) from county_facts cf)
group by cw.state, cw.state_abbreviation, cw.candidate, cw.party, cw.summary_votes, cw.two_or_more_races_percentage;

select 
	candidate
,	party
,	count("ile") as how_many_times_winner
from working_version_two_or_more_races
group by candidate, party
order by party, how_many_times_winner desc;

--sparawdzam czarnoskorego kandydata Ben Carson w jakich stanach najepiej mu poszlo--
--czy w tych stanach procent osob czarnoskorych byl wyzszy niz przecietnie--

select cw.* from candidate_winners cw
where cw."candidate" like 'Ben Carson';

select scv.* from summary_votes scv
join state_summary sm on scv.state=sm.area_name
where scv."candidate" like 'Ben Carson' and sm.black_amercian_or_african_percentage > (select avg(cf.rhi225214) from county_facts cf);

