-- 11.06.2021 - analiza V2 na potrzeby prezentacji

-- Dystrybucja EDU635213

select
   avg(cf.edu635213),
   min(cf.edu635213),
   max(cf.edu635213)
from county_facts cf
inner join primary_results pr on cf.fips = pr.fips;

-- Dystrybucja EDU635213

select
   avg(cf.edu685213),
   min(cf.edu685213),
   max(cf.edu685213)
from county_facts cf
inner join primary_results pr on cf.fips = pr.fips;

-- Uzyskiwanie reprezentatywnej próbki

select
       cf.fips, cf.area_name, cf.state_abbreviation, cf.edu635213, cf.edu685213,
       pr.party, pr.candidate, pr.votes, pr.fraction_votes,
       cf.pop010210, cf.age295214,
       (cf.pop010210 * (100 - cf.age295214) / 100)::int as population_above_18
from county_facts cf
inner join primary_results pr on cf.fips = pr.fips
order by cf.edu635213 desc;

drop table if exists education_analysis;

create temp table education_analysis
    as select
       cf.fips, cf.area_name, cf.state_abbreviation, cf.edu635213, cf.edu685213,
       pr.party, pr.candidate, pr.votes, pr.fraction_votes,
       sum(pr.votes) over (partition by pr.fips) as total_votes,
       max(pr.votes) over (partition by pr.fips) as winner_votes,
       case
          when max(pr.votes) over (partition by pr.fips, party) = pr.votes then true
          else false
       end as is_winner,
       (pr.votes::numeric / (sum(pr.votes) over (partition by pr.fips))::numeric) * 100 as votes_percentage,
        (cf.pop010210 * (100 - cf.age295214) / 100)::int as population_above_18
    from county_facts cf
    inner join primary_results pr on cf.fips = pr.fips
    where votes > 0
    order by cf.edu635213 desc;

select * from education_analysis;
-- 17 376 rekordów

create temp table education_analysis_filtered as select * from education_analysis where total_votes >= population_above_18 * 0.1;
-- 16 949 rekordów

-- Kwartyle (edu635213)

select
  percentile_disc(0.25) WITHIN GROUP (ORDER BY eaf.edu635213) AS q_25 ,
  percentile_disc(0.5) WITHIN GROUP (ORDER BY eaf.edu635213) AS q_50 ,
  percentile_disc(0.75) WITHIN GROUP (ORDER BY eaf.edu635213) AS q_75 ,
  percentile_disc(1) WITHIN GROUP (ORDER BY eaf.edu635213) AS q_100
from
  education_analysis_filtered eaf
where is_winner = true;

-- Kwartyle (edu685213)

select
  percentile_disc(0.25) WITHIN GROUP (ORDER BY eaf.edu685213) AS q_25 ,
  percentile_disc(0.5) WITHIN GROUP (ORDER BY eaf.edu685213) AS q_50 ,
  percentile_disc(0.75) WITHIN GROUP (ORDER BY eaf.edu685213) AS q_75 ,
  percentile_disc(1) WITHIN GROUP (ORDER BY eaf.edu685213) AS q_100
from
  education_analysis_filtered eaf
where is_winner = true;

-- Korelacje

select * from education_analysis_filtered;

drop table if exists education_analysis_correlations;
create temp table education_analysis_correlations as
    select
       fips,
       coalesce(corr(edu635213, fraction_votes), 0) as correlation_edu635213,
       coalesce(corr(edu685213, fraction_votes), 0) as correlation_edu685213
    from education_analysis_filtered
    group by fips
    order by 2 desc, 3 desc;

drop view if exists education_analysis_comparision;
create view education_analysis_comparision as select
        ea.fips,
        ea.area_name,
        ea.state_abbreviation,
        ea.edu635213,
        ea.edu685213,
        ea.party,
        ea.candidate,
        ea.votes,
        ea.fraction_votes,
        ea.total_votes,
        ea.votes_percentage,
        eac.correlation_edu635213,
        eac.correlation_edu685213
    from education_analysis_filtered ea
    inner join education_analysis_correlations eac on ea.fips = eac.fips
    where ea.is_winner
    order by eac.correlation_edu635213 desc;

select * from education_analysis_comparision
where
      correlation_edu635213 != 0
  and correlation_edu685213 != 0
  and abs(correlation_edu635213 - correlation_edu685213) < 0.25
  and (abs(correlation_edu685213) > 0.75 or abs(correlation_edu635213) > 0.75);