-- Dodanie klucza głównego na county_facts (możliwe, że już to masz, bo to było tydzień temu)

alter table county_facts add primary key (fips);

-- Korekta której potrzebujemy do stworzenia relacji, żeby typy tych kolumn były kompatybilne.
-- Wcześniej ta kolumna miała typ `numeric` (teraz `integer`), `numeric` było niedoprecyzowaniem.
-- Wszystkie wiersze były w tej kolumnie liczbą całkowitą.

alter table primary_results alter column fips set data type integer;

-- Tworzymy samą relację.

alter table primary_results add foreign key (fips) references county_facts(fips);

-- Więcej potencjalnych relacji nie dostrzegliśmy 😇