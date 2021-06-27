
----------------------------------------------------------------------------------
--QUALITY CHECK TABLICY COUNTY_FACTS
----------------------------------------------------------------------------------

--sprawdzenie, czy fips zawsze dodatni
 SELECT *
FROM
  county_facts cf
WHERE
  fips < 0
  OR fips isnull ;

--sprawdzenie, czy skrót sk³ada siê zawsze z dwóch liter
 SELECT
  count(*) ,
  CASE
    WHEN upper(state_abbreviation) SIMILAR TO '[A-Z]{2}' THEN 'valid state abbr'
    ELSE 'invalid state abbr'
  END state_abbr_check
FROM
  county_facts cf
GROUP BY
  state_abbr_check ;

--^52 invalid state abbreviation --> 51 stanów + USA
 SELECT
  area_name ,
  state_abbreviation ,
  CASE
    WHEN upper(state_abbreviation) SIMILAR TO '[A-Z]{2}' THEN 'valid state abbr'
    ELSE 'invalid state abbr'
  END state_abbr_check
FROM
  county_facts cf
ORDER BY
  state_abbr_check,
  area_name
LIMIT 52 ;

--sprawdzenie, czy wszystkie hrabstwa maj¹ wpisany state_abbreviation 
--(oraz czy wszystkie stany maj¹ null w state_abbreviation) 
 SELECT
  fips ,
  area_name ,
  state_abbreviation
FROM
  county_facts cf
WHERE
  state_abbreviation isnull
ORDER BY
  fips ;

SELECT count(*)
FROM
  county_facts cf
WHERE
  state_abbreviation isnull ;

SELECT
  fips ,
  area_name ,
  state_abbreviation
FROM
  county_facts cf
WHERE
  state_abbreviation IS NOT NULL
  AND state_abbreviation NOT SIMILAR TO '[A-Z]{2}'
ORDER BY
  fips ;
--^USA i Alabama nie maj¹ przypisanej wartoœci null
--dla ujednolicenia przypisujê null tym polom
--patrz: us_election_fixes.sql 

--ponowne sprawdzenie wartoœci null
 SELECT
  fips ,
  area_name ,
  state_abbreviation
FROM
  county_facts cf
WHERE
  state_abbreviation isnull
ORDER BY
  fips ;

SELECT count(*)
FROM
  county_facts cf
WHERE
  state_abbreviation isnull ;

----------------------------------------------------------------------------------
--QUALITY CHECK TABLICY PRIMARY_RESULTS
---------------------------------------------------------------------------------- 

--sprawdzenie, czy fips zawsze dodatni
 SELECT *
FROM
  primary_results pr
WHERE
  fips <0
  OR fips isnull ;

--znalezienie potencjalnych wartoœci fips dla wierszy, w których wystêpuje null
 SELECT
  pr.* ,
  concat(
    pr.county,
    ' County'
  ) AS area_name,
  (
    SELECT
      cf.fips
    FROM
      county_facts cf
    WHERE
      cf.area_name = concat(
        pr.county,
        ' County'
      )
        AND cf.state_abbreviation = pr.state_abbreviation
  ) AS potential_fips
FROM
  primary_results pr
WHERE
  pr.fips <0
  OR pr.fips isnull ;
--update tabeli
--patrz: us_election_fixes.sql

--ponowne sprawdzenie, czy fips zawsze dodatni
 SELECT *
FROM
  primary_results pr
WHERE
  fips <0
  OR fips isnull ;

--sprawdzenie, czy skrót sk³ada siê zawsze z dwóch liter
 SELECT
  count(*) ,
  CASE
    WHEN upper(state_abbreviation) SIMILAR TO '[A-Z]{2}' THEN 'valid state abbr'
    ELSE 'invalid state abbr'
  END state_abbr_check
FROM
  primary_results pr
GROUP BY
  state_abbr_check ;

--sprawdzenie, czy liczba stanów odpowiada liczbie skrótów
 SELECT
  count(DISTINCT state) ,
  count(DISTINCT state_abbreviation)
FROM
  primary_results pr ;

--sprawdzenie, czy skrót odpowiada nazwie stanu
 SELECT
  state_abbreviation ,
  state
FROM
  primary_results pr
GROUP BY
  state_abbreviation,
  state
ORDER BY
  state_abbreviation ;

--sprawdzenie, czy stany maj¹ odpowiedniki w tabeli county_facts 
 SELECT
  pr.state_abbreviation AS state_abbr_pr ,
  pr.state ,
  cf.state_abbreviation AS state_abbr_cf
FROM
  primary_results pr
FULL JOIN county_facts cf ON
  pr.fips = cf.fips
GROUP BY
  pr.state_abbreviation,
  pr.state,
  cf.state_abbreviation
ORDER BY
  pr.state ;

--sprawdzenie brakuj¹cych odpowiedników fips w tabelach county_facts i primary_results
 SELECT count(DISTINCT pr.fips) AS fips_not_in_county_facts
FROM
  primary_results pr
FULL JOIN county_facts cf ON
  pr.fips = cf.fips
WHERE
  cf.fips isnull ;

--z podzia³em na stany
 SELECT
  DISTINCT pr.state_abbreviation ,
  count(pr.fips) AS fips_not_in_county_facts
FROM
  primary_results pr
FULL JOIN county_facts cf ON
  pr.fips = cf.fips
WHERE
  cf.fips isnull
GROUP BY
  pr.state_abbreviation ;

--^istnieje 7032 fipsów, niewystêpuj¹cych w county_facts
 SELECT
  count(DISTINCT cf.fips) AS fips_not_in_primary_results
FROM
  primary_results pr
FULL JOIN county_facts cf ON
  pr.fips = cf.fips
WHERE
  pr.fips isnull
  AND cf.state_abbreviation IS NOT NULL ;

--z podzia³em na stany
 SELECT
  DISTINCT cf.state_abbreviation ,
  count(cf.fips) AS fips_not_in_primary_results
FROM
  primary_results pr
FULL JOIN county_facts cf ON
  pr.fips = cf.fips
WHERE
  pr.fips isnull
  AND cf.state_abbreviation IS NOT NULL
GROUP BY
  cf.state_abbreviation ;
--^istnieje 335 fipsów niewystêpuj¹cych w primary_results 
--(niebêd¹cych nullami, czyli US lub ca³ymi stanami - te bêd¹ pozostawione)
--usuniêcie fipsów bez odpowiedników

--poni¿sze zapytanie powinno zwracaæ 7032 i 335:
 SELECT
  count(pr.fips) AS fips_not_in_county_facts ,
  count(cf.fips) AS fips_not_in_primary_results
FROM
  primary_results pr
FULL JOIN county_facts cf ON
  pr.fips = cf.fips
WHERE
  cf.fips isnull
  OR pr.fips isnull
  AND cf.state_abbreviation IS NOT NULL ;
--zapytania delete patrz: us_election_fixes.sql

--po usuniêciu poni¿sze zapytanie powinno zwracaæ zera:
 SELECT
  count(pr.fips) AS fips_not_in_county_facts ,
  count(cf.fips) AS fips_not_in_primary_results
FROM
  primary_results pr
FULL JOIN county_facts cf ON
  pr.fips = cf.fips
WHERE
  cf.fips isnull
  OR pr.fips isnull
  AND cf.state_abbreviation IS NOT NULL ;

--sprawdzenie, czy istniej¹ hrabstwa, w których nie oddano g³osów
 SELECT
  fips ,
  state,
  county ,
  sum(votes) OVER (
    PARTITION BY fips
  )
FROM
  primary_results pr
ORDER BY
  4 ;

--^w hrabstwie Carroll w Arkansas nie oddano g³osów --> usuwam te rekordy z tabel
--zapytania delete patrz: us_election_fixes.sql

