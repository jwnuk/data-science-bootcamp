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
WITH cte AS (
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
JOIN cte ON
  cf.sex255214 = cte.min_val OR cf.sex255214 = cte.max_val
WHERE
  cf.state_abbreviation ISNULL
ORDER BY
  3 DESC ;

/*procent kobiet zawiera siê w przedziale <47.4, 52.6>, dalsze rozwa¿ania przeprowadzone z podzia³em na <50%, =50%, >50% */
/*liczba stanów, gdzie kobiety stanowi¹ wiêcej, mniej lub równo 50%*/
WITH cte AS (
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
  cte
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

/*UWAGI: Chcia³am podzieliæ na stany, gdzie kobiety stanowi¹ wiêkszoœæ i gdzie kobiety stanowi¹ mniejszoœæ,
 * jednak proporcje s¹ tutaj mocno zaburzone. Prawdopodobnie granicê postawiæ jako œrednia/mediana. 
 * 
 * Do przedyskutowania.*/










