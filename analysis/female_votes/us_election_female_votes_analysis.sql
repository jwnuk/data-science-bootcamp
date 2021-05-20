/*- jak wygl¹da podzia³ ze wzglêdu na p³eæ osób g³osuj¹cych w poszczególnych stanach?*/
/*- jak wygl¹da rozk³ad g³osów na poszczególnych kandydatów z podzia³em na p³eæ?*/

/*sprawdzenie, które kolumny dotycz¹ p³ci*/
SELECT *
FROM
  county_facts_dictionary cfd
WHERE
  lower(cfd.description) LIKE '%fem%'
  OR lower(cfd.description) LIKE '%sex%'
  OR lower(cfd.description) LIKE '%gend%';

/*- jak wygl¹da podzia³ ze wzglêdu na p³eæ osób g³osuj¹cych w poszczególnych stanach?*/
SELECT
  cf.fips ,
  cf.area_name ,
  cf.sex255214 
FROM
  county_facts cf
WHERE
  cf.state_abbreviation ISNULL
ORDER BY
  fips ;


/*wyniki partii w poszczególnych hrabstwach*/
SELECT
  pvpc.* ,
  cf.sex255214 AS percent_women
FROM
  party_votes_per_county pvpc
JOIN county_facts cf ON
  pvpc.fips = cf.fips
ORDER BY pvpc.fips, votes_for_party DESC ;

SELECT * ,
  sum(votes_for_party) OVER (PARTITION BY fips)
FROM party_votes_per_county pvpc
ORDER BY 6 ;

SELECT * ,
  sum(votes_for_party) OVER (PARTITION BY fips)
FROM party_votes_per_county pvpc
WHERE lower(state) = 'arkansas' AND lower(county) = 'carroll' ;


---------------------------------------------------------------------------------
/* tutaj wyniki do usuniêcia */
















/*wyniki partii w poszczególnych stanach*/
SELECT
  pppc.* ,
  cf.sex255214 
FROM
  percent_party_per_county pppc
JOIN county_facts cf ON
  pppc.fips = cf.fips ;

SELECT
  ppps.* ,
  cf.area_name ,
  cf.sex255214 
FROM
  percent_party_per_state ppps
LEFT JOIN county_facts cf ON
  ppps.state = cf.area_name 
ORDER BY state, vote_percent DESC ;










/*ranking kandydatów w poszczególnych stanach */
CREATE TEMP TABLE wyniki_kandydat_stan AS
SELECT pr.state ,
  round(avg(cf.sex255214), 3) sr_kobiet_per_stan ,
  pr.party ,
  pr.candidate ,
  sum(pr.votes) l_glosow_per_kandydat ,
  RANK() OVER(
    PARTITION BY pr.state
  ORDER BY
    sum(pr.votes) DESC
  ) ranking
FROM
  county_facts cf
RIGHT JOIN primary_results pr ON
  cf.fips = pr.fips
GROUP BY
  pr.state ,
  pr.candidate ,
  pr.party
ORDER BY
  pr.state ;

SELECT *
FROM
  wyniki_kandydat_stan ;

CREATE TEMP TABLE procent_stan AS
SELECT * ,
  sum(l_glosow_per_kandydat) OVER (
    PARTITION BY state
  ) suma_glosow ,
  round(l_glosow_per_kandydat / sum(l_glosow_per_kandydat) OVER (PARTITION BY state) * 100::NUMERIC, 3) procent_glosow
FROM
  wyniki_kandydat_stan ;

SELECT *
FROM
  procent_stan ;











/*wyniki dla stanow gdzie >=50% kobiet i <50% kobiet*/
CREATE TEMP TABLE counter_more_equal_50 AS
SELECT
  state ,
  sr_kobiet_per_stan ,
  party ,
  candidate ,
  procent_glosow ,
  CASE
    WHEN upper(party) = 'DEMOCRAT' THEN 1
    ELSE -1
  END counter_more
FROM
  procent_stan
WHERE
  ranking = 1
  AND sr_kobiet_per_stan >= 50 ;

SELECT *
FROM
  counter_more_equal_50 ;

CREATE TEMP TABLE counter_less_than_50 AS
SELECT
  state ,
  sr_kobiet_per_stan ,
  party ,
  candidate ,
  procent_glosow ,
  CASE
    WHEN upper(party) = 'DEMOCRAT' THEN 1
    ELSE -1
  END counter_less
FROM
  procent_stan
WHERE
  ranking = 1
  AND sr_kobiet_per_stan < 50 ;

SELECT *
FROM
  counter_less_than_50 ;

SELECT
  avg(cm.sr_kobiet_per_stan) ,
  sum(counter_more) counter ,
  CASE
    WHEN sum(counter_more) > 0 THEN 'Democrat wins'
    WHEN sum(counter_more) < 0 THEN 'Republican wins'
    ELSE 'Tie'
  END final_result
FROM
  counter_more_equal_50 cm
UNION
SELECT
  avg(cl.sr_kobiet_per_stan) counter ,
  sum(counter_less) ,
  CASE
    WHEN sum(counter_less) > 0 THEN 'Democrat wins'
    WHEN sum(counter_less) < 0 THEN 'Republican wins'
    ELSE 'Tie'
  END final_result
FROM
  counter_less_than_50 cl ;












/*wygrany/a kandydat/ka z liczb¹ stanów, w których wygrali*/
SELECT *
FROM
  procent_stan ;

SELECT
  candidate ,
  party ,
  count(*) state_counter ,
  avg(procent_glosow) sr_procent_glosow ,
  avg(sr_kobiet_per_stan) sr_kobiet
FROM
  procent_stan
WHERE
  ranking = 1
GROUP BY
  candidate,
  party
ORDER BY
  sr_kobiet DESC ;
