/*- jak wygl¹da podzia³ ze wzglêdu na p³eæ osób g³osuj¹cych w poszczególnych hrabstwach?*/
/*- jak wygl¹da rozk³ad g³osów na poszczególnych kandydatów z podzia³em na p³eæ?*/

/*- jak wygl¹da podzia³ ze wzglêdu na p³eæ osób g³osuj¹cych w poszczególnych hrabstwach?*/
SELECT
  cf.fips ,
  cf.area_name ,
  cf.sex255214 AS percent_women
FROM
  county_facts cf
WHERE
  cf.state_abbreviation IS NOT NULL
ORDER BY
  fips ;

/*posortowane*/
SELECT
  cf.fips ,
  cf.area_name ,
  cf.sex255214 AS percent_women
FROM
  county_facts cf
WHERE
  cf.state_abbreviation IS NOT NULL
ORDER BY
  3 DESC ;

/*wyci¹gam tylko wartoœci skrajne*/
WITH min_max AS (
  SELECT
    min(cf2.sex255214) AS min_val ,
    max(cf2.sex255214) AS max_val
  FROM
    county_facts cf2
    WHERE cf2.state_abbreviation IS NOT NULL 
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
  cf.state_abbreviation IS NOT NULL
ORDER BY
  3 DESC ;

/*widaæ, ¿e w przypadku hrabstw wartoœci znacznie bardziej zró¿nicowane (miêdzy 30.1% a 56.8%) ni¿ w stanach (miêdzy 47.4% a 52.6%)*/

/*tworzê widok z rankingiem kandydatów ka¿dej z partii w poszczególnych hrabstwach*/
CREATE OR REPLACE VIEW county_ranking AS
SELECT
  cf.fips ,
  pr.state_abbreviation ,
  pr.state ,
  cf.area_name ,
  cf.sex255214 AS percent_women ,
  pr.party ,
  pr.candidate ,
  pr.votes ,
  pr.fraction_votes ,
  RANK() OVER (PARTITION BY pr.fips, pr.party ORDER BY pr.votes DESC) AS ranking
FROM
  county_facts cf
JOIN primary_results pr ON
  cf.fips = pr.fips
WHERE
  cf.state_abbreviation IS NOT NULL
ORDER BY
  cf.fips ,
  pr.party ,
  pr.votes DESC ;

/*utworzony widok:*/
SELECT *
FROM
  county_ranking ;

/*wyniki poszczególnych kandydatów, tzn. w ilu hrabstwach wygrali*/
SELECT
  round(avg(cr.percent_women),2) AS avg_women_percent ,
  (SELECT cf.sex255214 FROM county_facts cf WHERE cf.fips = 0) AS us_avg ,
  cr.party ,
  cr.candidate ,
  count(DISTINCT cr.fips) AS counties_won ,
  round(100*avg(cr.fraction_votes),2) avg_fraction_votes
FROM
  county_ranking cr 
  WHERE cr.ranking = 1 AND votes != 0
GROUP BY cr.party ,
  cr.candidate 
ORDER BY cr.party, 5 DESC ;

--|avg_women_percent|us_avg|party     |candidate      |counties_won|avg_fraction_votes|
--|-----------------|------|----------|---------------|------------|------------------|
--|50.15            |50.8  |Democrat  |Hillary Clinton|1663        |63.47             |
--|49.70            |50.8  |Democrat  |Bernie Sanders |1162        |57.05             |
--|50.06            |50.8  |Republican|Donald Trump   |2006        |53.00             |
--|49.78            |50.8  |Republican|Ted Cruz       |619         |44.38             |
--|50.52            |50.8  |Republican|John Kasich    |58          |45.16             |
--|51.29            |50.8  |Republican|Marco Rubio    |39          |36.94             |

/*podzia³ hrabstw ze wzglêdu na populacjê kobiet: */
CREATE TEMP TABLE IF NOT EXISTS quartiles AS 
SELECT
  percentile_disc(0.25) WITHIN GROUP (ORDER BY cf.sex255214) AS q_25 ,
  percentile_disc(0.5) WITHIN GROUP (ORDER BY cf.sex255214) AS q_50 ,
  percentile_disc(0.75) WITHIN GROUP (ORDER BY cf.sex255214) AS q_75 ,
  percentile_disc(1) WITHIN GROUP (ORDER BY cf.sex255214) AS q_100 ,
  round(avg(cf.sex255214),2) AS average ,
  (SELECT cf.sex255214 FROM county_facts cf WHERE cf.fips = 0) AS avg_in_us
FROM
  county_facts cf
WHERE
  cf.state_abbreviation IS NOT NULL ;

SELECT * FROM quartiles ;

/*wyniki kandydatów w hrabstwach, gdzie populacja kobiet mieœci siê w pierwszym kwartylu*/
SELECT
  round(avg(cr.percent_women), 2) AS avg_women_percent ,
  cr.party ,
  cr.candidate ,
  count(DISTINCT cr.fips) counties_won ,
  round(100 * avg(cr.fraction_votes), 2) AS avg_fraction_votes
FROM
  county_ranking cr ,
  quartiles
WHERE
  cr.percent_women <= q_25
  AND cr. ranking = 1
  AND cr.fraction_votes != 0
GROUP BY
  cr.party ,
  cr.candidate
ORDER BY
  cr.party ,
  4 DESC ;

/*wyniki kandydatów w hrabstwach, gdzie populacja kobiet mieœci siê w drugim kwartylu*/
SELECT
  round(avg(cr.percent_women), 2) AS avg_women_percent ,
  cr.party ,
  cr.candidate ,
  count(DISTINCT cr.fips) counties_won ,
  round(100 * avg(cr.fraction_votes), 2) AS avg_fraction_votes
FROM
  county_ranking cr ,
  quartiles
WHERE
  cr.percent_women <= q_50
  AND cr.percent_women > q_25
  AND cr. ranking = 1
  AND cr.fraction_votes != 0
GROUP BY
  cr.party ,
  cr.candidate
ORDER BY
  cr.party ,
  4 DESC ;

/*wyniki kandydatów w hrabstwach, gdzie populacja kobiet mieœci siê w trzecim kwartylu*/
SELECT
  round(avg(cr.percent_women), 2) AS avg_women_percent ,
  cr.party ,
  cr.candidate ,
  count(DISTINCT cr.fips) counties_won ,
  round(100 * avg(cr.fraction_votes), 2) AS avg_fraction_votes
FROM
  county_ranking cr ,
  quartiles
WHERE
  cr.percent_women <= q_75
  AND cr.percent_women > q_50
  AND cr. ranking = 1
  AND cr.fraction_votes != 0
GROUP BY
  cr.party ,
  cr.candidate
ORDER BY
  cr.party ,
  4 DESC ;

/*wyniki kandydatów w hrabstwach, gdzie populacja kobiet mieœci siê w czwartym kwartylu*/
SELECT
  round(avg(cr.percent_women), 2) AS avg_women_percent ,
  cr.party ,
  cr.candidate ,
  count(DISTINCT cr.fips) counties_won ,
  round(100 * avg(cr.fraction_votes), 2) AS avg_fraction_votes
FROM
  county_ranking cr ,
  quartiles
WHERE
  cr.percent_women > q_75
  AND cr. ranking = 1
  AND cr.fraction_votes != 0
GROUP BY
  cr.party ,
  cr.candidate
ORDER BY
  cr.party ,
  4 DESC ;

--pierwszy kwartyl 
--|avg_women_percent|party     |candidate      |counties_won|avg_fraction_votes|
--|-----------------|----------|---------------|------------|------------------|
--|47.89            |Democrat  |Bernie Sanders |388         |58.68             |
--|47.04            |Democrat  |Hillary Clinton|386         |62.84             |
--|47.50            |Republican|Donald Trump   |521         |56.38             |
--|47.40            |Republican|Ted Cruz       |177         |47.15             |
--|47.65            |Republican|John Kasich    |6           |42.57             |
--|47.13            |Republican|Marco Rubio    |3           |35.80             |

--drugi kwartyl
--|avg_women_percent|party     |candidate      |counties_won|avg_fraction_votes|
--|-----------------|----------|---------------|------------|------------------|
--|50.09            |Democrat  |Bernie Sanders |351         |57.87             |
--|50.08            |Democrat  |Hillary Clinton|308         |58.93             |
--|50.09            |Republican|Donald Trump   |448         |55.40             |
--|50.08            |Republican|Ted Cruz       |165         |44.66             |
--|50.05            |Republican|John Kasich    |13          |44.98             |
--|50.18            |Republican|Marco Rubio    |4           |38.53             |

--trzeci kwartyl
--|avg_women_percent|party     |candidate      |counties_won|avg_fraction_votes|
--|-----------------|----------|---------------|------------|------------------|
--|50.79            |Democrat  |Hillary Clinton|434         |60.81             |
--|50.74            |Democrat  |Bernie Sanders |300         |55.10             |
--|50.77            |Republican|Donald Trump   |523         |51.16             |
--|50.76            |Republican|Ted Cruz       |172         |42.48             |
--|50.75            |Republican|John Kasich    |24          |44.57             |
--|50.79            |Republican|Marco Rubio    |10          |34.26             |

--czwarty kwartyl
--|avg_women_percent|party     |candidate      |counties_won|avg_fraction_votes|
--|-----------------|----------|---------------|------------|------------------|
--|51.91            |Democrat  |Hillary Clinton|535         |68.69             |
--|51.73            |Democrat  |Bernie Sanders |123         |54.29             |
--|51.90            |Republican|Donald Trump   |514         |49.35             |
--|51.70            |Republican|Ted Cruz       |105         |42.41             |
--|52.29            |Republican|Marco Rubio    |22          |38.02             |
--|51.69            |Republican|John Kasich    |15          |47.31             |

/*Wnioski: 
 * Wraz ze wzrostem populacji kobiet w partii Demokratów roœnie poparcie Hillary Clinton, 
 * pod wzglêdem zarówno wygranych hrabstw, jak i przewagi procentowej.
 * 
 * W partii Republikan niezmiennie wygrywa Donald Trump, choæ w drugim kwartylu liczba zdobytych przez niego hrabstw stosunkowo spad³a.
 * Jeœli chodzi o pozosta³ych kandydatów w pierwszych trzech kwartylach stopniowo roœnie poparcie Johna Kasich oraz Marco Rubio
 * (pod wzglêdem wygranych hrabstw), w czwartym natomiast gwa³townie spada liczba hrabstw sprzyjaj¹cych Tedowi Cruz,
 * (która utrzymywa³a siê doœæ stabilnie) a Marco Rubio wyprzedza Johna Kasich.
 * 
 * W partii Demokratów dla ka¿dego przedzia³u Hillary Clinton zdobywa hrabstwa o œrednio wiêkszej populacji kobiet.
 * W partii Republikan hrabstwa o najwy¿szej œredniej populacji kobiet zdobywa Marco Rubio w drugim do czwartego kwartyla.
 * Jedynie w pierwszym zdobywa je John Kasich.*/

/*UWAGI:
 * W drugim oraz trzecim kwartylu jedynie nieznaczne ró¿nice w populacji kobiet dla poszczególnych kandydatów. */

-----------------------
/*sprawdzenie korelacji dla poszczególnych kandydatów*/

/*ile razy kandydat znalaz³ siê na liœcie wyników*/
SELECT
  DISTINCT candidate ,
  count(*)
FROM
  county_ranking cr 
JOIN county_facts cf ON
  cr.fips = cf.fips 
GROUP BY
  candidate
ORDER BY
  2 DESC ;

/*zale¿noœæ % g³osów oddanych na kandydata od populacji kobiet badam dla kandydatów,
 * którzy pojawiaj¹ siê w wynikach dla co najmniej 20% stanów*/
SELECT
  round(0.2 * count(DISTINCT fips)) AS min_counties
FROM
  county_ranking cr ;

DROP VIEW candidates_in_counties_vs_female ;
CREATE OR REPLACE
VIEW candidates_in_counties_vs_female AS
SELECT
  cr.* ,
  CASE
    WHEN cr.candidate = 'Bernie Sanders' THEN 1
    WHEN cr.candidate = 'Hillary Clinton' THEN 2
    WHEN cr.candidate = 'Donald Trump' THEN 3
    WHEN cr.candidate = 'John Kasich' THEN 4
    WHEN cr.candidate = 'Ted Cruz' THEN 5
    WHEN cr.candidate = 'Marco Rubio' THEN 6
    WHEN cr.candidate = 'Ben Carson' THEN 7
    ELSE NULL
  END AS candidate_number
FROM
  county_ranking cr ;

SELECT * FROM candidates_in_counties_vs_female cicvf ;

/*wyniki*/
SELECT
  count(*) ,
  candidate ,
  party ,
  CORR(fraction_votes, percent_women) ,
  @corr(fraction_votes, percent_women) AS corr_abs
FROM
  candidates_in_counties_vs_female cicvf
WHERE
  candidate_number IS NOT NULL
GROUP BY
  candidate ,
  party
ORDER BY
  5 DESC ;

--|count|candidate      |party     |corr                |corr_abs           |
--|-----|---------------|----------|--------------------|-------------------|
--|2807 |Hillary Clinton|Democrat  |0.12945645964134336 |0.12945645964134336|
--|2807 |Bernie Sanders |Democrat  |-0.09807058631948133|0.09807058631948133|
--|2720 |John Kasich    |Republican|0.08544999846168005 |0.08544999846168005|
--|1899 |Marco Rubio    |Republican|0.06899939843198523 |0.06899939843198523|
--|1031 |Ben Carson     |Republican|0.06815723164514095 |0.06815723164514095|
--|2720 |Ted Cruz       |Republican|-0.06412795851878263|0.06412795851878263|
--|2720 |Donald Trump   |Republican|-0.04534598735380448|0.04534598735380448|

/*Wniosek:
 * W przeciwieñstwie do wyników dla stanów, w przypadku poszczególnych hrabstw korelacje
 * dla wszystkich kandydatów miêdzy oddanymi na nich g³osami praktycznie nie wystêpuj¹. 
 * Dalej najwiêksze zale¿noœci istniej¹ w partii Demokratów,
 * jednak znacznie (ok. siedmiokrotnie) s³absze. (0.71 vs 0.13/0.1)
 * 
 * Prawdopodobnie zbyt szczegó³owe wyniki w przypadku podzia³u na hrabstwa. */

/*wyniki dla kandydatów, na których g³osowano w <20% hrabstw
 * sprawdzenie, czy w ich wypadku zale¿noœæ jest wy¿sza*/
SELECT
  count(*) ,
  candidate ,
  party ,
  CORR(fraction_votes, percent_women) ,
  @corr(fraction_votes, percent_women) AS corr_abs
FROM
  candidates_in_counties_vs_female cicvf
WHERE
  candidate_number ISNULL
GROUP BY
  candidate ,
  party
ORDER BY
  5 DESC ;

/*Wniosek:
 * Dla kandydatów, na których oddano g³osy w <20% hrabstw, zale¿noœci oddanych g³osów 
 * od populacji kobiet s¹ ju¿ nieco bardziej widoczne (0.04-0.32, mediana 0.12 vs 0.05-0.13, mediana 0.07), 
 * jednak dalej korelacjê w najlepszym przypadku mo¿na uznaæ za co najwy¿ej s³ab¹.*/
