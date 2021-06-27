-- Wybranie związanych z tematem wskaźników

select fips, area_name, state_abbreviation, edu635213, edu685213 from county_facts;

-- Wybranie związanych z tematem wskaźników razem z ich opisami (teoretycznie niepraktyczne, ale ułatwia wizualizację i interpretację)

select
       fips,
       area_name,
       state_abbreviation,
       edu635213,
       edu685213,
       (select description from county_facts_dictionary where lower(column_name) = 'edu635213') as edu635213_description,
       (select description from county_facts_dictionary where lower(column_name) = 'edu685213') as edu685213_description
from county_facts;

-- Wybranie związanych z tematem wskaźników razem z ich opisami w jednej kolumnie.
-- Kompletnie niepraktyczne do obliczeń, ale trochę lepsze do wizualizacji.

select
       fips,
       area_name,
       state_abbreviation,
       concat(edu635213, ' (', (select description from county_facts_dictionary where lower(column_name) = 'edu635213'), ')') as edu635213_description,
       concat(edu685213, ' (', (select description from county_facts_dictionary where lower(column_name) = 'edu685213'), ')') as edu685213_description
from county_facts;

-- Zestawienie danych dot. wyborów z pożądanymi wskaźnikami

select
       cf.fips, cf.area_name, cf.state_abbreviation, cf.edu635213, cf.edu685213,
       pr.party, pr.candidate, pr.votes, pr.fraction_votes
from county_facts cf
inner join primary_results pr on cf.fips = pr.fips;

-- Sprawdźmy najlepiej i najmniej wykształcone regiony, i sprawdźmy czy przypadkiem na oko nie widać jakiegoś związku.

select
       cf.fips, cf.area_name, cf.state_abbreviation, cf.edu635213, cf.edu685213,
       pr.party, pr.candidate, pr.votes, pr.fraction_votes
from county_facts cf
inner join primary_results pr on cf.fips = pr.fips
order by cf.edu635213 desc;

-- Interpretacja: na oko nie dostrzegam bezpośredniej relacji.
-- Natomiast można dostrzeć, że najniższy procent wyższego wykształcenia populacji powyżej 25rż danego regionu to 45%,a najwyższa to 99%.
-- 99% zdaje się być bardzo skrajną wartością, w dodatku silnie kontrastuje z relatywnie niskim % populacji z
-- "Bachelor's degree or higher, percent of persons age 25+, 2009-2013".
-- Co możma dostrzec, to że rekordy poniżej 99%:
-- najbliższy 98.4% mają wskaźnik edu685213 na poziomie 47.5%, 33.4%, 74.4% (kolejno rekody powyższego zapytania).
-- Co sugeruje anomalię. Co nią jest? Możemy dostrzec, że liczba głosów w tych regionach nie przekracza liczby 100.
-- Wszystkie rekordy z wartością 99% wskaźnika edu635213 mają kolejno: 99, 20, 4, 5 oraz 6 głosów w sumie.
-- Spróbuję odfiltrować rekordy z liczbą głosów poniżej 100, ponieważ mam wątpliwości co do tego, czy mogą reprezentować
-- demokratyczny wybór całego populacji regionu (anomalia może być np. rejonem/próbką ekskluzywną i zamkniętą).

select
       cf.fips, cf.area_name, cf.state_abbreviation, cf.edu635213, cf.edu685213,
       pr.party, pr.candidate, pr.votes, pr.fraction_votes
from county_facts cf
inner join primary_results pr on cf.fips = pr.fips
where votes >= 100
order by cf.edu635213 desc;

-- Z 17 579 rekordów otrzymujemy 14 204, czyli ubyło 3375 - około 19%.
-- Analizę tych małych populacji można zawsze przeprowadzić później.

-- Utworzę tymczasową tabelę z wyników powyższego zapytania, ponieważ myślę, że dla dalszej analizy te wyłuskane dane są kluczowe.

-- Usunięcie tabeli, tylko jeśli istnieje. Przydatne w trakcie pisania DDL, żebym mógł updatować tabelę wraz z postępem pracy.
drop table if exists education_analysis;

-- Wyciągam:
-- - dane z tabeli county facts połączone z primary results
-- - dla każdego rekordu (region - kandydat) dołączam liczbę wszystkich głosów w danym regionie
-- - dla każdego rekordu (region - kandydat) dołączam liczbę głosów wygranego kandydata (? założenie), czyli
-- największą liczbę głosów w danym regionie.
-- - czy jest wygranym (największa liczba głosów w danym regionie).

create temp table education_analysis
    as select
       cf.fips, cf.area_name, cf.state_abbreviation, cf.edu635213, cf.edu685213,
       pr.party, pr.candidate, pr.votes, pr.fraction_votes,
       sum(pr.votes) over (partition by pr.fips) as total_votes,
       max(pr.votes) over (partition by pr.fips) as winner_votes,
       case
          when max(pr.votes) over (partition by pr.fips) = pr.votes then true
          else false
       end as is_winner,
       (pr.votes::numeric / (sum(pr.votes) over (partition by pr.fips))::numeric) * 100 as votes_percentage
    from county_facts cf
    inner join primary_results pr on cf.fips = pr.fips
    where votes >= 100
    order by cf.edu635213 desc;


-- Według mnie sprytny sposób na przegrupowanie wyników po fips'ie bez utraty jakichkolwiek innych kolumn

select * from education_analysis where is_winner; -- czyli:
-- select * from education_analysis where votes = winner_votes;

-- Sprawdzę najczęściej wybieranego kandydata w przedziałach wskaźnika edu635213 w zakresach <0,25) , <25, 50), <50, 75), <75, 100)

select * from education_analysis where is_winner and edu635213 < 25; -- 0 wyników
select * from education_analysis where is_winner and edu635213 >= 25 and edu635213 < 50; -- 1 wynik - Starr Country
select * from education_analysis where is_winner and edu635213 >= 50 and edu635213 < 75; -- 293 wyników
select * from education_analysis where is_winner and edu635213 >= 75; -- 2 451 wyników

-- Interpretacja: prawie 90% regionów ma wskaźnik edu635213 powyżej 75%. Zatem sprawdźmy dokładniej:
-- 75-80%, 80-85%, 85-90%, 90-95%, 95%+

select * from education_analysis where is_winner and edu635213 >= 75 and edu635213 < 80; -- 448 wyników
select * from education_analysis where is_winner and edu635213 >= 80 and edu635213 < 85; -- 596 wyników
select * from education_analysis where is_winner and edu635213 >= 85 and edu635213 < 90; -- 856 wyników
select * from education_analysis where is_winner and edu635213 > 90 and edu635213 <= 95; -- 508 wyników
select * from education_analysis where is_winner and edu635213 > 95; -- 28 wyników

-- Sprawdzę wartości analityczne (korelacja) wskaźników dla wszystkich rekordów (kandydatów)

drop table if exists education_analysis_correlations;

create temp table education_analysis_correlations as select
       fips,
       coalesce(corr(edu635213, votes_percentage), 0) as correlation_edu635213,
       coalesce(corr(edu685213, votes_percentage), 0) as correlation_edu685213
    from education_analysis
    group by fips
    order by 2 desc, 3 desc;

-- Tworzę pełne zestawienie.

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
    from education_analysis ea
    inner join education_analysis_correlations eac on ea.fips = eac.fips
    where ea.is_winner
    order by eac.correlation_edu635213 desc;

-- +-----+-------------------+------------------+---------+---------+----------+---------------+-----+--------------+-----------+---------------------+---------------------+---------------------+
-- |fips |area_name          |state_abbreviation|edu635213|edu685213|party     |candidate      |votes|fraction_votes|total_votes|votes_percentage     |correlation_edu635213|correlation_edu685213|
-- +-----+-------------------+------------------+---------+---------+----------+---------------+-----+--------------+-----------+---------------------+---------------------+---------------------+
-- |48363|Palo Pinto County  |TX                |79.4     |15.1     |Republican|Ted Cruz       |2813 |0.455         |6452       |43.598884066955982641|0.983409870690226    |0.8038351823587396   |
-- |51590|Danville city      |VA                |77.9     |17.2     |Democrat  |Hillary Clinton|2676 |0.8           |6574       |40.705810769698813508|0.9694150266584575   |-0.8850000238542105  |
-- |51167|Russell County     |VA                |74.7     |10.5     |Republican|Donald Trump   |1730 |0.556         |3914       |44.200306591722023505|0.9624040111198758   |0                    |
-- |51105|Lee County         |VA                |74.2     |11.7     |Republican|Donald Trump   |1089 |0.534         |2411       |45.167980091248444629|0.9547828267587352   |-0.9547828267587352  |
-- |13245|Richmond County    |GA                |83.7     |20.5     |Democrat  |Hillary Clinton|16269|0.817         |34738      |46.83343888537048765 |0.939896263583607    |0                    |
-- |47181|Wayne County       |TN                |75.7     |7.9      |Republican|Donald Trump   |1159 |0.528         |2429       |47.715109098394400988|0.9295135526114463   |0.9295135526114463   |
-- |26001|Alcona County      |MI                |86.9     |13       |Republican|Donald Trump   |1111 |0.518         |2967       |37.445230872935625211|0.9235005121575879   |0                    |
-- |13281|Towns County       |GA                |86.8     |22.7     |Republican|Donald Trump   |1356 |0.46          |3494       |38.809387521465369204|0.9054174190735486   |0.9054174190735486   |
-- |26063|Huron County       |MI                |86.9     |13.7     |Republican|Donald Trump   |2346 |0.43          |7401       |31.698419132549655452|0.9029014560958963   |-0.9029014560958963  |
-- |40125|Pottawatomie County|OK                |86.1     |17.6     |Democrat  |Bernie Sanders |3400 |0.555         |13483      |25.216939850181710302|0.8995617913104572   |-0.8745312929096607  |
-- |... + 2 735 kolumn|
-- +-----+-------------------+------------------+---------+---------+----------+---------------+-----+--------------+-----------+---------------------+---------------------+---------------------+

-- Wyniki sugerują, że istnieją kandydaci, którzy uzyskują w danych regionach głosy (i wygrywają) z bardzo silną korelacją dot. edukacji.
-- Uważam, że należy interpretować za poprawne wyniki, gdzie correlation_edu635213 jest zbliżone do correlation_edu685213.
-- Uznajmy 20%.

-- Sprawdzam czy oba wskaźniki nie są 0 (bo wcześniej przekształciłem nulle na 0), a potem obliczam wartość bezwzględną z różnicy obu wskaźników i sprawdzam czy jest mniejsza od 25%.
-- Jeśli nie, to odpada.

-- (abs to funkcja wyznaczania liczby bezwzględnej, zastosowałem ją po to, zeby znajdowało zarówno negatywne jak i pozytywne korelacje)

select
    * from education_analysis_comparision
where correlation_edu635213 != 0 and correlation_edu685213 != 0 and abs(correlation_edu635213 - correlation_edu685213) < 0.25; -- filtrowanie;

-- Wynik to 292 wygranych kandydatów w danych regionach, które wykazują (pozytywną bądź negatywną), uznawaną za mnie za prawidłową korelację wskaźników
-- edukacji populacji danego regionu do % otrzymanych głosów przez danego kandydata.

-- Spróbuję wyciągnać z tego tylko te rekordy, które wykazują przynajmniej słabą korelację dla wskaźnika edu685213 (>0.5).

select
    * from education_analysis_comparision
where correlation_edu635213 != 0 and correlation_edu685213 != 0 and abs(correlation_edu635213 - correlation_edu685213) < 0.25 -- filtrowanie;
and abs(correlation_edu685213) > 0.5 -- zakres;

-- Wynik to 59 rekordów (j/w) wykazujących od niskiej do wysokiej korelacji (-0.94;-0.50, 0.42;0.98). Rezultat zapytania dołączyłem poniżej.

-- +-----+---------------------+------------------+---------+---------+----------+---------------+------+-----------------+-----------+---------------------+---------------------+---------------------+
-- |fips |area_name            |state_abbreviation|edu635213|edu685213|party     |candidate      |votes |fraction_votes   |total_votes|votes_percentage     |correlation_edu635213|correlation_edu685213|
-- +-----+---------------------+------------------+---------+---------+----------+---------------+------+-----------------+-----------+---------------------+---------------------+---------------------+
-- |48363|Palo Pinto County    |TX                |79.4     |15.1     |Republican|Ted Cruz       |2813  |0.455            |6452       |43.598884066955982641|0.983409870690226    |0.8038351823587396   |
-- |47181|Wayne County         |TN                |75.7     |7.9      |Republican|Donald Trump   |1159  |0.528            |2429       |47.715109098394400988|0.9295135526114463   |0.9295135526114463   |
-- |13281|Towns County         |GA                |86.8     |22.7     |Republican|Donald Trump   |1356  |0.46             |3494       |38.809387521465369204|0.9054174190735486   |0.9054174190735486   |
-- |47107|McMinn County        |TN                |80.2     |14.3     |Republican|Donald Trump   |3604  |0.421            |9933       |36.283096748213027283|0.8863078577945863   |0.7106678966451045   |
-- |39069|Henry County         |OH                |90.4     |13.8     |Republican|John Kasich    |3499  |0.519            |8513       |41.10184423822389287 |0.8692102648838348   |0.8692102648838348   |
-- |48339|Montgomery County    |TX                |86.3     |30.7     |Republican|Ted Cruz       |43797 |0.483            |100828     |43.437338834450747808|0.8690151489809012   |0.8690151489809012   |
-- |16083|Twin Falls County    |ID                |83.7     |16.3     |Republican|Ted Cruz       |4717  |0.49             |10060      |46.888667992047713718|0.8548652501789572   |0.8548652501789572   |
-- |17191|Wayne County         |IL                |86.4     |11.8     |Republican|Donald Trump   |2075  |0.497            |4617       |44.942603422135585878|0.8485590441462779   |0.8485590441462779   |
-- |51003|Albemarle County     |VA                |91.4     |52.2     |Democrat  |Hillary Clinton|8284  |0.545            |29812      |27.787468133637461425|0.82849475935958     |0.82849475935958     |
-- |29167|Polk County          |MO                |83.7     |18.3     |Republican|Ted Cruz       |3430  |0.527            |7949       |43.150081771291986413|0.8270283673357998   |0.8270283673357998   |
-- |13311|White County         |GA                |85.2     |19.3     |Republican|Donald Trump   |2715  |0.453            |6866       |39.542674046023885814|0.8138010645750399   |0.8138010645750399   |
-- |17169|Schuyler County      |IL                |88.9     |18.6     |Republican|Donald Trump   |697   |0.444            |2169       |32.134624250806823421|0.7891433014044845   |0.7891433014044845   |
-- |39141|Ross County          |OH                |84.1     |13.7     |Republican|John Kasich    |4918  |0.405            |18084      |27.19531077195310772 |0.7484803117446943   |0.7484803117446943   |
-- |28067|Jones County         |MS                |78.7     |16.8     |Republican|Donald Trump   |6388  |0.531            |14985      |42.629295962629295963|0.7449224706928214   |0.7449224706928214   |
-- |47089|Jefferson County     |TN                |80.4     |13.6     |Republican|Donald Trump   |4050  |0.449            |10033      |40.366789594338682348|0.7217861162718172   |0.8922776655107306   |
-- |37041|Chowan County        |NC                |79.7     |20.1     |Democrat  |Hillary Clinton|974   |0.618            |3001       |32.455848050649783406|0.715991788339163    |0.715991788339163    |
-- |5045 |Faulkner County      |AR                |89.4     |27.2     |Republican|Ted Cruz       |6228  |0.333            |25128      |24.785100286532951289|0.6905971925489941   |0.5256777120389875   |
-- |47143|Rhea County          |TN                |76.9     |12.6     |Republican|Donald Trump   |2339  |0.441            |5965       |39.212070410729253982|0.676907821513018    |0.8840009127209513   |
-- |33003|Carroll County       |NH                |91.9     |31.2     |Democrat  |Bernie Sanders |5655  |0.636465953854812|20993      |26.937550612108798171|0.6469314328451519   |0.8659442442460148   |
-- |19127|Marshall County      |IA                |85.2     |19.3     |Democrat  |Bernie Sanders |960   |0.534            |3765       |25.49800796812749004 |0.6315433941121419   |0.6315433941121419   |
-- |19041|Clay County          |IA                |93.1     |18.4     |Democrat  |Bernie Sanders |303   |0.506            |1486       |20.390309555854643338|0.6114321848947092   |0.6114321848947092   |
-- |39119|Muskingum County     |OH                |87.1     |14.2     |Republican|John Kasich    |6599  |0.435            |20274      |32.549077636381572457|0.5975996015296411   |0.5975996015296411   |
-- |21177|Muhlenberg County    |KY                |77.9     |11.3     |Democrat  |Bernie Sanders |1632  |0.457            |4067       |40.127858372264568478|0.5962611296420608   |0.5962611296420608   |
-- |5111 |Poinsett County      |AR                |73.3     |8.6      |Republican|Donald Trump   |1036  |0.385            |3510       |29.51566951566951567 |0.5862543295016011   |0.5862543295016011   |
-- |29186|Ste. Genevieve County|MO                |82.1     |10.7     |Republican|Donald Trump   |1080  |0.444            |4017       |26.88573562359970127 |0.5818824671247106   |0.5818824671247106   |
-- |19011|Benton County        |IA                |91.9     |18.8     |Democrat  |Hillary Clinton|672   |0.56             |2623       |25.619519634006862371|0.5799490858226558   |0.5799490858226558   |
-- |12093|Okeechobee County    |FL                |67.8     |10.2     |Republican|Donald Trump   |2202  |0.585            |5590       |39.391771019677996422|0.5461963004332013   |0.5461963004332013   |
-- |51107|Loudoun County       |VA                |93.8     |57.9     |Democrat  |Hillary Clinton|21171 |0.586            |86971      |24.342596957606558508|0.5235610934939623   |0.5235610934939623   |
-- |37077|Granville County     |NC                |81.1     |16.4     |Democrat  |Hillary Clinton|4693  |0.588            |12378      |37.914041040555824851|0.5164228713158127   |0.5164228713158127   |
-- |29159|Pettis County        |MO                |81.8     |15.2     |Republican|Donald Trump   |3343  |0.453            |9902       |33.760856392647949909|0.5103798711841199   |0.5103798711841199   |
-- |29510|St. Louis city       |MO                |82.9     |29.6     |Democrat  |Hillary Clinton|34458 |0.55             |75631      |45.560682788803532943|0.5101217228548701   |0.5101217228548701   |
-- |37127|Nash County          |NC                |83.1     |19.2     |Democrat  |Hillary Clinton|8554  |0.658            |22600      |37.849557522123893805|0.50516883635957     |0.50516883635957     |
-- |29213|Taney County         |MO                |84.7     |18.6     |Republican|Donald Trump   |5086  |0.474            |13028      |39.038992938286766963|0.5049111783037685   |0.5049111783037685   |
-- |37057|Davidson County      |NC                |80.4     |17.6     |Republican|Donald Trump   |10964 |0.452            |31960      |34.305381727158948686|0.500119272537765    |0.500119272537765    |
-- |48113|Dallas County        |TX                |77.4     |28.6     |Democrat  |Hillary Clinton|113574|0.715            |327760     |34.651574322675128143|0.42117564157856946  |0.6387175037132362   |
-- |17193|White County         |IL                |85.4     |14.3     |Republican|Donald Trump   |1424  |0.51             |3776       |37.711864406779661017|-0.5006534104253784  |-0.5006534104253784  |
-- |37025|Cabarrus County      |NC                |86.4     |25.1     |Republican|Donald Trump   |11300 |0.426            |40941      |27.600693681150924501|-0.5126168373820138  |-0.5126168373820138  |
-- |45057|Lancaster County     |SC                |82.3     |18.7     |Republican|Donald Trump   |4190  |0.339            |16922      |24.760666587873773786|-0.5258168753652576  |-0.5258168753652576  |
-- |22079|Rapides Parish       |LA                |82.4     |18.3     |Democrat  |Hillary Clinton|4722  |0.713            |14628      |32.280557834290401969|-0.5537482186509375  |-0.5537482186509375  |
-- |17043|DuPage County        |IL                |92.1     |46.3     |Democrat  |Bernie Sanders |65159 |0.523            |263881     |24.692569756822203948|-0.5672762741362557  |-0.5672762741362557  |
-- |47065|Hamilton County      |TN                |86.3     |27.2     |Republican|Donald Trump   |16985 |0.329            |73726      |23.038005588259230122|-0.5798515669334514  |-0.5798515669334514  |
-- |28123|Scott County         |MS                |72.3     |9.6      |Democrat  |Hillary Clinton|2013  |0.855            |5719       |35.198461269452701521|-0.6153245542286497  |-0.6153245542286497  |
-- |22105|Tangipahoa Parish    |LA                |80.1     |19.4     |Democrat  |Hillary Clinton|4267  |0.657            |13475      |31.666048237476808905|-0.6164918519533601  |-0.6164918519533601  |
-- |47017|Carroll County       |TN                |78.6     |15.4     |Republican|Donald Trump   |1579  |0.432            |4606       |34.281372123317412071|-0.617563107209407   |-0.8234985086830886  |
-- |26155|Shiawassee County    |MI                |90.6     |14.2     |Democrat  |Bernie Sanders |4452  |0.578            |16821      |26.466916354556803995|-0.6188127623917969  |-0.6188127623917969  |
-- |21113|Jessamine County     |KY                |84.6     |27.4     |Democrat  |Bernie Sanders |2113  |0.498            |7949       |26.581959994967920493|-0.6201279294245073  |-0.6201279294245073  |
-- |28075|Lauderdale County    |MS                |84.1     |18.9     |Republican|Donald Trump   |4740  |0.453            |14046      |33.74626228107646305 |-0.6371719342506532  |-0.6371719342506532  |
-- |39147|Seneca County        |OH                |89.4     |15.3     |Republican|John Kasich    |4596  |0.452            |13953      |32.939152870350462266|-0.662084807882814   |-0.662084807882814   |
-- |13145|Harris County        |GA                |89.2     |27.3     |Republican|Donald Trump   |2542  |0.369            |8629       |29.458801715146598679|-0.7115916749971303  |-0.7115916749971303  |
-- |12105|Polk County          |FL                |82.4     |18.1     |Republican|Donald Trump   |33187 |0.449            |116161     |28.56982980518418402 |-0.7176909617210364  |-0.7176909617210364  |
-- |17091|Kankakee County      |IL                |86.4     |17.1     |Republican|Donald Trump   |6403  |0.427            |25159      |25.45013712786676736 |-0.7257439576065807  |-0.7257439576065807  |
-- |17067|Hancock County       |IL                |90.6     |18.4     |Republican|Donald Trump   |1494  |0.43             |4414       |33.84685092886270956 |-0.7278647345406779  |-0.7278647345406779  |
-- |5101 |Newton County        |AR                |79.8     |12.7     |Republican|Donald Trump   |1073  |0.385            |3004       |35.719041278295605859|-0.7367348311730226  |-0.7367348311730226  |
-- |26045|Eaton County         |MI                |93.4     |24.6     |Democrat  |Bernie Sanders |7007  |0.556            |27500      |25.48                |-0.7710946212507053  |-0.7710946212507053  |
-- |51131|Northampton County   |VA                |78.1     |20.2     |Democrat  |Hillary Clinton|868   |0.725            |2483       |34.957712444623439388|-0.7849765358289099  |-0.7849765358289099  |
-- |17019|Champaign County     |IL                |93.6     |42.4     |Democrat  |Bernie Sanders |20581 |0.659            |56391      |36.496958734549839513|-0.8881727491869641  |-0.8881727491869641  |
-- |47039|Decatur County       |TN                |78.8     |14.2     |Republican|Donald Trump   |842   |0.528            |1979       |42.54674077817079333 |-0.9240174791175952  |-0.9240174791175952  |
-- |48329|Midland County       |TX                |81.8     |24.4     |Republican|Ted Cruz       |10474 |0.479            |22750      |46.03956043956043956 |-0.9269996185846769  |-0.7232958827785635  |
-- |45085|Sumter County        |SC                |82.3     |19.2     |Democrat  |Hillary Clinton|9816  |0.866            |22430      |43.762817654926437807|-0.9427067703393931  |-0.9427067703393931  |
-- +-----+---------------------+------------------+---------+---------+----------+---------------+------+-----------------+-----------+---------------------+---------------------+---------------------+

-- Rekordy te (wygrani kandydaci w danych regionach) wykazują zależność edukacji populacji od wyników wyborów.
-- Jest to 59 rekordów spośród 2 745 wygranych kandydatów w danych regionach, czyli ok. 2,14%.
-- Jest to oczywiście wynik wyłącznie według mojej interpretacji i wyboru granicznych wartości korelacji (załozylem 50% co według prezentacji odpowiada niskiej korelacji).
-- Przypominam, ze zalozylem rowniez, iz oba wskazniki powinny być do siebie zblizone co najmniej w 20%.