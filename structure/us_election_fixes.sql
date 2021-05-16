/*Wszystkie zapytania na podstawie, których stworzone zosta³y updaty/delety znajduj¹ siê w pliku us_election_data_quality_check.sql*/

/*update tabeli county_facts, aby wszystkie stany mia³y wartoœæ null w polu state_abbreviation
(z zapytañ w us_election_data_quality_check.sql wiemy, ¿e nale¿y null przypisaæ do 'United States' i 'Alabama')*/
update county_facts set state_abbreviation = null 
where area_name = 'United States' or area_name = 'Alabama' ;

/*uzupe³nienie wartoœci fips w tabeli primary_results na podstawie znalezionych odpowiadaj¹cych wartoœci w county_facts */
update primary_results pr
set fips = (
	select cf.fips 
	from county_facts cf 
	where cf.area_name = concat(pr.county, ' County') 
	and cf.state_abbreviation = pr.state_abbreviation)
where pr.fips isnull ;

/*usuniêcie wierszy, dla których primary_results.fips nie ma odpowiednika county_facts.fips*/
delete from primary_results 
where fips in (
select  
	pr.fips 
from primary_results pr 
full join county_facts cf on pr.fips = cf.fips 
where cf.fips isnull
) ;

/*usuniêcie wierszy, dla których county_facts.fips nie ma odpowiednika primary_results.fips */
delete from county_facts 
where fips in (
select  
	cf.fips 
from primary_results pr 
full join county_facts cf on pr.fips = cf.fips 
where pr.fips isnull and cf.state_abbreviation is not null
) ;