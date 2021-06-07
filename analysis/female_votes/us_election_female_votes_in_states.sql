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

/*posortowane*/
SELECT
  cf.fips ,
  cf.area_name ,
  cf.sex255214 
FROM
  county_facts cf
WHERE
  cf.state_abbreviation ISNULL
ORDER BY
  3 DESC ;

/*wyci¹gam wartoœci skrajne*/
WITH min_max AS (
  SELECT
    min(cf2.sex255214) AS min_val ,
    max(cf2.sex255214) AS max_val
  FROM
    county_facts cf2
    WHERE cf2.state_abbreviation ISNULL 
)
SELECT
  cf.fips ,
  cf.area_name ,
  cf.sex255214 AS percent_women
FROM
  county_facts cf
JOIN min_max ON
  cf.sex255214 = min_max.min_val OR cf.sex255214 = min_max.max_val
WHERE
  cf.state_abbreviation ISNULL
ORDER BY
  3 DESC ;

/*procent kobiet zawiera siê w przedziale <47.4, 52.6>, dalsze rozwa¿ania przeprowadzone z podzia³em na <50%, =50%, >50% */
/*liczba stanów, gdzie kobiety stanowi¹ wiêcej, mniej lub równo 50%*/
WITH more_less AS (
  SELECT
    cf.fips ,
    cf.area_name ,
    cf.sex255214 AS percent_women ,
    CASE
      WHEN cf.sex255214 > 50 THEN 'more than 50% women'
      WHEN cf.sex255214 < 50 THEN 'less than 50% women'
      ELSE '50% women'
    END women_rate
  FROM
    county_facts cf
  WHERE
    cf.state_abbreviation ISNULL
  ORDER BY
    cf.fips
)
SELECT
  women_rate ,
  count(women_rate) AS number_of_states
FROM
  more_less
GROUP BY
  women_rate 
ORDER BY women_rate DESC ;

/*ranking kandydatów w poszczególnych stanach w zestawieniu z procentem kobiet */
SELECT
  cf.sex255214 AS percent_women ,
  cpis.*
FROM
  candidates_percent_in_states cpis
JOIN county_facts cf ON
  cpis.state = cf.area_name ;

/*ile razy poszczególni kandydaci zwyciê¿yli i jak to siê ma do œredniej kobiet*/
SELECT
  round(avg(cf.sex255214), 2) AS avg_percent_women ,
  (
    SELECT
      cf2.sex255214
    FROM
      county_facts cf2
    WHERE
      cf2.fips = 0
  ) AS avg_in_us ,
  CASE
    WHEN avg(cf.sex255214) > (
      SELECT
        cf2.sex255214
      FROM
        county_facts cf2
      WHERE
        cf2.fips = 0
    ) THEN 'more than avg'
    WHEN avg(cf.sex255214) < (
      SELECT
        cf2.sex255214
      FROM
        county_facts cf2
      WHERE
        cf2.fips = 0
    ) THEN 'less than avg'
    ELSE 'equals avg'
  END AS percent_women_wtr_avg ,
  cpis.party ,
  cpis.candidate ,
  count(cpis.state) AS times_won ,
  round(avg(cpis.percent_votes), 2) AS avg_percent_votes
FROM
  candidates_percent_in_states cpis
JOIN county_facts cf ON
  cpis.state = cf.area_name
WHERE
  cpis.ranking = 1
GROUP BY
  cpis.party ,
  cpis.candidate
ORDER BY
  party,
  1 DESC ;

--|avg_percent_women|avg_in_us|percent_women_wtr_avg|party     |candidate      |times_won|avg_percent_votes|
--|-----------------|---------|---------------------|----------|---------------|---------|-----------------|
--|50.92            |50.8     |more than avg        |Democrat  |Hillary Clinton|25       |62.23            |
--|50.18            |50.8     |less than avg        |Democrat  |Bernie Sanders |16       |60.74            |
--|51.10            |50.8     |more than avg        |Republican|John Kasich    |1        |47.57            |
--|50.77            |50.8     |less than avg        |Republican|Donald Trump   |32       |53.64            |
--|50.18            |50.8     |less than avg        |Republican|Ted Cruz       |6        |45.57            |



/*wyniki dla stanów, gdzie œrednia populacja kobiet >=50%*/
SELECT
  round(avg(cf.sex255214), 2) AS avg_women_percent ,
  cpis.party ,
  cpis.candidate ,
  count(cpis.state) AS states_won ,
  round(avg(cpis.percent_votes), 2) AS avg_percent_votes
FROM
  candidates_percent_in_states cpis
JOIN county_facts cf ON
  cpis.state = cf.area_name
WHERE
  cf.sex255214 >= 50
  AND cpis.ranking = 1
GROUP BY
  cpis.party ,
  cpis.candidate
ORDER BY
  cpis.party ,
  4 DESC ;

/*wyniki dla stanów, gdzie œrednia populacja kobiet <50%*/
SELECT
  round(avg(cf.sex255214), 2) AS avg_women_percent ,
  cpis.party ,
  cpis.candidate ,
  count(cpis.state) AS states_won ,
  round(avg(cpis.percent_votes), 2) AS avg_percent_votes
FROM
  candidates_percent_in_states cpis
JOIN county_facts cf ON
  cpis.state = cf.area_name
WHERE
  cf.sex255214 < 50
  AND cpis.ranking = 1
GROUP BY
  cpis.party ,
  cpis.candidate
ORDER BY
  cpis.party ,
  4 DESC ;

--œrednia populacja kobiet >=50%
--|avg_women_percent|party     |candidate      |states_won|avg_percent_votes|
--|-----------------|----------|---------------|----------|-----------------|
--|51.02            |Democrat  |Hillary Clinton|23        |63.13            |
--|50.52            |Democrat  |Bernie Sanders |10        |57.52            |
--|50.93            |Republican|Donald Trump   |28        |52.80            |
--|50.38            |Republican|Ted Cruz       |4         |39.34            |
--|51.10            |Republican|John Kasich    |1         |47.57            |

--œrednia populacja kobiet <50%
--|avg_women_percent|party     |candidate      |states_won|avg_percent_votes|
--|-----------------|----------|---------------|----------|-----------------|
--|49.60            |Democrat  |Bernie Sanders |6         |66.11            |
--|49.70            |Democrat  |Hillary Clinton|2         |51.89            |
--|49.65            |Republican|Donald Trump   |4         |59.52            |
--|49.80            |Republican|Ted Cruz       |2         |58.03            |

/*Wnioski:
 * Istotn¹ zmianê widaæ w partii Demokratów - tam gdzie kobiety stanowi¹ wiêkszoœæ 
 * populacji czêœciej wygrywa Hillary Clinton, natomiast tam, gdzie mniejszoœæ - Bernie Sanders.
 * W obydwu przypadkach jednak œredni procent kobiet jest wy¿szy w stanach g³osuj¹cych na H.Clinton.
 * 
 * W partii Republikan w obu przypadkach wygrywa Donald Trump.*/


/*procent kobiet zawiera siê w przedziale <47.4, 52.6>, dalsze rozwa¿ania przeprowadzone z podzia³em na poni¿ej/powy¿ej œredniej/mediany */
/*liczba stanów, gdzie kobiety stanowi¹ wiêcej/mniej ni¿ œrednio w US */
CREATE TEMP TABLE avg_med
AS 
SELECT
  (SELECT cf2.sex255214 FROM county_facts cf2 WHERE cf2.fips = 0) AS us_avg,
  percentile_disc(0.5) WITHIN GROUP(ORDER BY cf.sex255214) AS us_med 
FROM
  county_facts cf
WHERE cf.state_abbreviation ISNULL ;

SELECT *
FROM
  avg_med ;

/*tabela z porównaniem populacji kobiet do wartoœci œredniej dla US oraz mediany*/
CREATE OR REPLACE
VIEW avg_med_comparison AS
SELECT
  cf.fips ,
  cf.area_name ,
  cf.sex255214 AS percent_women ,
  (SELECT am.us_avg FROM avg_med am) ,
  CASE
    WHEN cf.sex255214 > am.us_avg THEN 'more than average'
    WHEN cf.sex255214 < am.us_avg THEN 'less than average'
    ELSE 'equals average'
  END AS avg_check ,
  (SELECT am.us_med FROM avg_med am) ,
  CASE
    WHEN cf.sex255214 > am.us_med THEN 'more than median'
    WHEN cf.sex255214 < am.us_med THEN 'less than median'
    ELSE 'equals median'
  END AS med_check
FROM
  county_facts cf ,
  avg_med am
WHERE
  cf.state_abbreviation ISNULL
  AND cf.fips != 0
ORDER BY
  cf.fips ;

SELECT * FROM avg_med_comparison ;

/*ile stanów w poszczególnych przedzia³ach*/
SELECT
  med_check ,
  count(*) AS states
FROM
  avg_med_comparison amc
GROUP BY
  med_check 
ORDER BY 2 DESC ;

--|med_check       |states|
--|----------------|------|
--|more than median|25    |
--|less than median|24    |
--|equals median   |2     |


SELECT
  avg_check ,
  count(*) AS states
FROM
  avg_med_comparison amc
GROUP BY
  avg_check 
ORDER BY 2 DESC ;

--|avg_check        |states|
--|-----------------|------|
--|less than average|26    |
--|more than average|23    |
--|equals average   |2     |


/*zestawienie rankingu kandydatów z populacj¹ kobiet*/
SELECT
  cpis.* ,
  amc.percent_women ,
  amc.us_avg ,
  amc.avg_check ,
  amc.us_med ,
  amc.med_check
FROM
  candidates_percent_in_states cpis
JOIN avg_med_comparison amc ON
  cpis.state = amc.area_name
ORDER BY
  amc.fips ,
  cpis.party ,
  cpis.ranking ;

/*ile razy poszczególni kandydaci zwyciê¿yli*/

/*przedzia³ < us_avg*/
SELECT
  round(avg(amc.percent_women),2) AS avg_percent_women ,
  cpis.party ,
  cpis.candidate ,
  count(cpis.state) AS states_won ,
  round(avg(cpis.percent_votes),2) AS avg_votes_percent
FROM
  candidates_percent_in_states cpis
JOIN avg_med_comparison amc ON
  cpis.state = amc.area_name
WHERE
  cpis.ranking = 1
  AND amc.avg_check LIKE 'less%'
GROUP BY
  cpis.party ,
  cpis.candidate
ORDER BY
  cpis.party ,
  4 DESC ;

/*przedzia³ >= us_avg*/
SELECT
  round(avg(amc.percent_women),2) AS avg_percent_women ,
  cpis.party ,
  cpis.candidate ,
  count(cpis.state) AS states_won ,
  round(avg(cpis.percent_votes),2) AS avg_votes_percent
FROM
  candidates_percent_in_states cpis
JOIN avg_med_comparison amc ON
  cpis.state = amc.area_name
WHERE
  cpis.ranking = 1
  AND (amc.avg_check LIKE 'more%' OR amc.avg_check LIKE 'equals%')
GROUP BY
  cpis.party ,
  cpis.candidate
ORDER BY
  cpis.party ,
  4 DESC ;

/*przedzia³ < us_med*/
SELECT
  round(avg(amc.percent_women),2) AS avg_percent_women ,
  cpis.party ,
  cpis.candidate ,
  count(cpis.state) AS states_won ,
  round(avg(cpis.percent_votes),2) AS avg_votes_percent
FROM
  candidates_percent_in_states cpis
JOIN avg_med_comparison amc ON
  cpis.state = amc.area_name
WHERE
  cpis.ranking = 1
  AND amc.med_check LIKE 'less%'
GROUP BY
  cpis.party ,
  cpis.candidate
ORDER BY
  cpis.party ,
  4 DESC ;

/*przedzia³ >= us_med*/
SELECT
  round(avg(amc.percent_women),2) AS avg_percent_women ,
  cpis.party ,
  cpis.candidate ,
  count(cpis.state) AS states_won ,
  round(avg(cpis.percent_votes),2) AS avg_votes_percent
FROM
  candidates_percent_in_states cpis
JOIN avg_med_comparison amc ON
  cpis.state = amc.area_name
WHERE
  cpis.ranking = 1
  AND (amc.med_check LIKE 'more%' OR amc.med_check LIKE 'equals%')
GROUP BY
  cpis.party ,
  cpis.candidate
ORDER BY
  cpis.party ,
  4 DESC ;

--przedzia³ < us_avg
--|avg_percent_women|party     |candidate      |states_won|avg_votes_percent|
--|-----------------|----------|---------------|----------|-----------------|
--|50.07            |Democrat  |Bernie Sanders |14        |61.98            |
--|50.17            |Democrat  |Hillary Clinton|7         |55.26            |
--|50.18            |Republican|Donald Trump   |13        |64.44            |
--|50.18            |Republican|Ted Cruz       |6         |45.57            |

--przedzia³ >= us_avg
--|avg_percent_women|party     |candidate      |states_won|avg_votes_percent|
--|-----------------|----------|---------------|----------|-----------------|
--|51.21            |Democrat  |Hillary Clinton|18        |64.94            |
--|50.90            |Democrat  |Bernie Sanders |2         |52.04            |
--|51.18            |Republican|Donald Trump   |19        |46.26            |
--|51.10            |Republican|John Kasich    |1         |47.57            |

--przedzia³ < us_med
--|avg_percent_women|party     |candidate      |states_won|avg_votes_percent|
--|-----------------|----------|---------------|----------|-----------------|
--|50.02            |Democrat  |Bernie Sanders |13        |62.71            |
--|50.17            |Democrat  |Hillary Clinton|7         |55.26            |
--|50.13            |Republican|Donald Trump   |12        |65.26            |
--|50.18            |Republican|Ted Cruz       |6         |45.57            |

--przedzia³ >= us_med
--|avg_percent_women|party     |candidate      |states_won|avg_votes_percent|
--|-----------------|----------|---------------|----------|-----------------|
--|51.21            |Democrat  |Hillary Clinton|18        |64.94            |
--|50.83            |Democrat  |Bernie Sanders |3         |52.19            |
--|51.16            |Republican|Donald Trump   |20        |46.68            |
--|51.10            |Republican|John Kasich    |1         |47.57            |


/*sprawdzenie korelacji dla poszczególnych kandydatów*/

/*ile razy kandydat znalaz³ siê na liœcie wyników*/
SELECT
  DISTINCT candidate ,
  count(*)
FROM
  candidates_percent_in_states cpis
JOIN county_facts cf ON
  cpis.state = cf.area_name
GROUP BY
  candidate
ORDER BY
  2 DESC ;

/*zale¿noœæ % g³osów oddanych na kandydata od populacji kobiet badam dla kandydatów,
 * którzy co najmniej 10 razy pojawiaj¹ siê w wynikach dla stanów*/

CREATE OR REPLACE
VIEW candidates_in_states_vs_female AS
SELECT
  cpis.* ,
  cf.sex255214 AS percent_women ,
  CASE
    WHEN cpis.candidate = 'Bernie Sanders' THEN 1
    WHEN cpis.candidate = 'Hillary Clinton' THEN 2
    WHEN cpis.candidate = 'Donald Trump' THEN 3
    WHEN cpis.candidate = 'John Kasich' THEN 4
    WHEN cpis.candidate = 'Ted Cruz' THEN 5
    WHEN cpis.candidate = 'Marco Rubio' THEN 6
    WHEN cpis.candidate = 'Ben Carson' THEN 7
    ELSE NULL
  END AS candidate_number
FROM
  candidates_percent_in_states cpis
JOIN county_facts cf ON
  cpis.state = cf.area_name ;

SELECT * FROM candidates_in_states_vs_female cisvf ;

/*wyniki*/
SELECT
  count(*) ,
  candidate ,
  party ,
  CORR(percent_votes, percent_women) ,
  @corr(percent_votes, percent_women) AS corr_abs
FROM
  candidates_in_states_vs_female cisvf
WHERE
  candidate_number IS NOT NULL
GROUP BY
  candidate ,
  party
ORDER BY
  5 DESC ;

--|count|candidate      |party     |corr                |corr_abs           |
--|-----|---------------|----------|--------------------|-------------------|
--|41   |Hillary Clinton|Democrat  |0.7083132717827585  |0.7083132717827585 |
--|41   |Bernie Sanders |Democrat  |-0.7079765694068759 |0.7079765694068759 |
--|11   |Ben Carson     |Republican|0.47165486434308895 |0.47165486434308895|
--|39   |John Kasich    |Republican|0.2256123095785897  |0.2256123095785897 |
--|39   |Ted Cruz       |Republican|-0.19232923996835724|0.19232923996835724|
--|22   |Marco Rubio    |Republican|-0.13001618368927229|0.13001618368927229|
--|39   |Donald Trump   |Republican|-0.04971340765341561|0.04971340765341561|

/*Wniosek:
 * - najwiêksz¹ zale¿noœæ widaæ w partii Demokratów. (0.71)
 * - w partii Republikan dla wiêkszoœci kandydatów istnieje bardzo s³aba korelacja,
 *   b¹dŸ praktycznie zupe³ny brak zwi¹zku miêdzy oddanymi na nich g³osami 
 *   z populacj¹ kobiet w danym stanie, w przypadku Johna Kasich mo¿na stwierdziæ
 *   nisk¹ korelacjê, w przypadku Bena Carsona - umiarkowan¹.*/
