/*Wszystkie zapytania na podstawie, których stworzone zosta³y updaty/delety znajduj¹ siê w pliku us_election_data_quality_check.sql*/;

/*update tabeli county_facts, aby wszystkie stany mia³y wartoœæ null w polu state_abbreviation
(z zapytañ w us_election_data_quality_check.sql wiemy, ¿e nale¿y null przypisaæ do 'United States' i 'Alabama')*/
UPDATE
  county_facts
SET
  state_abbreviation = NULL
WHERE
  area_name = 'United States'
  OR area_name = 'Alabama' ;

/*uzupe³nienie wartoœci fips w tabeli primary_results na podstawie znalezionych odpowiadaj¹cych wartoœci w county_facts */
UPDATE
  primary_results pr
SET
  fips = (
    SELECT
      cf.fips
    FROM
      county_facts cf
    WHERE
      cf.area_name = concat(pr.county, ' County')
        AND cf.state_abbreviation = pr.state_abbreviation
  )
WHERE
  pr.fips ISNULL ;

/*usuniêcie wierszy, dla których primary_results.fips nie ma odpowiednika county_facts.fips*/
DELETE
FROM
  primary_results
WHERE
  fips IN (
    SELECT
      pr.fips
    FROM
      primary_results pr
    FULL JOIN county_facts cf ON
      pr.fips = cf.fips
    WHERE
      cf.fips ISNULL
  ) ;

/*usuniêcie wierszy, dla których county_facts.fips nie ma odpowiednika primary_results.fips */
DELETE
FROM
  county_facts
WHERE
  fips IN (
    SELECT
      cf.fips
    FROM
      primary_results pr
    FULL JOIN county_facts cf ON
      pr.fips = cf.fips
    WHERE
      pr.fips ISNULL
      AND cf.state_abbreviation IS NOT NULL
  ) ;

/*usuniêcie wierszy dla hrabstwa, w którym nie oddano g³osów*/
DELETE
FROM
primary_results
WHERE
fips IN (
  SELECT fips
  FROM
    primary_results pr
  GROUP BY
    fips,
    state,
    county
  HAVING
    sum(votes) = 0
) ;

DELETE
FROM
  county_facts
WHERE
  fips IN (
    SELECT fips
    FROM
      primary_results pr
    GROUP BY
      fips,
      state,
      county
    HAVING
      sum(votes) = 0
  ) ;
