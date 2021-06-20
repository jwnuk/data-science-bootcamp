--analiza pod względem struktury wiekowej poszczególnych stanów a ilości oddanych głosów na poszczególną partię,
--przyjęłam dwie grupy wiekowe : 18-64 i 65-powyżej. 
--zestawienie oraz współczynnik korelacji sugeruje iż nie ma korelacji, związku struktury wiekowej na ilość głosów oddanych na poszczegówlne partie

select distinct pr.state,
                pr.party,
                round(avg(100 - cf.age135214 - cf.age295214 - cf.age775214) over (partition by pr.state), 0) under_65,
                round(avg(cf.age775214) over (partition by pr.state), 0) over_65,
                sum(pr.votes) over (partition by pr.state, pr.party) party_state
           from county_facts cf
           join primary_results pr 
             on cf.fips = pr.fips
          order by 4 desc ;

create temp table statystyka as
select distinct pr.state,
                pr.party,
                round(avg(100 - cf.age135214 - cf.age295214 - cf.age775214) over (partition by pr.state), 0) under_65,
                round(avg(cf.age775214) over (partition by pr.state), 0) over_65,
                sum(pr.votes) over (partition by pr.state, pr.party ) party_state
           from county_facts cf
           join primary_results pr 
             on cf.fips = pr.fips
          order by 1 desc ;

select  s.state,
        s.party,
        corr(s.under_65, s.party_state) corr_under_65,
        corr(s.over_65, s.party_state) corr_over_65	
   from statystyka s
  group by s.state, s.party ;

select corr(s.under_65, s.party_state) corr_under_65,
       corr(s.over_65, s.party_state) corr_over_65
  from statystyka s ;

-- Analiza struktury wiekowej w odniesieiu do głosowania na poszczególnych kandydatów w stanach.
-- wskaźniki korelacji w tym zestawieniu również nie wskazuje korelacji. 

create temp table candidate as
select distinct pr.candidate,
                pr.state,
                round(avg(100 - cf.age135214 - cf.age295214 - cf.age775214) over (partition by pr.state), 0) under_65,
                round(avg(cf.age775214) over (partition by pr.state), 0) over_65,
                sum(pr.votes) over (partition by pr.state, pr.candidate ) party_candidate
           from county_facts cf
           join primary_results pr 
             on cf.fips = pr.fips
          order by 1 desc ;


select corr(under_65,party_candidate) under_65,
       corr(over_65,party_candidate) over_65
  from candidate c ;