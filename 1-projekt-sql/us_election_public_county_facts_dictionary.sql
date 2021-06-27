create table county_facts_dictionary
(
    column_name varchar(9) not null
        constraint county_facts_dictionary_pk
            primary key,
    description varchar
);

-- WARNING: this is considered dangerous and may not work every machine
-- alter table county_facts_dictionary
--     owner to postgres;

create unique index county_facts_dictionary_column_name_uindex
    on county_facts_dictionary (column_name);

INSERT INTO public.county_facts_dictionary (column_name, description) VALUES ('PST045214', 'Population, 2014 estimate');
INSERT INTO public.county_facts_dictionary (column_name, description) VALUES ('PST040210', 'Population, 2010 (April 1) estimates base');
INSERT INTO public.county_facts_dictionary (column_name, description) VALUES ('PST120214', 'Population, percent change - April 1, 2010 to July 1, 2014');
INSERT INTO public.county_facts_dictionary (column_name, description) VALUES ('POP010210', 'Population, 2010');
INSERT INTO public.county_facts_dictionary (column_name, description) VALUES ('AGE135214', 'Persons under 5 years, percent, 2014');
INSERT INTO public.county_facts_dictionary (column_name, description) VALUES ('AGE295214', 'Persons under 18 years, percent, 2014');
INSERT INTO public.county_facts_dictionary (column_name, description) VALUES ('AGE775214', 'Persons 65 years and over, percent, 2014');
INSERT INTO public.county_facts_dictionary (column_name, description) VALUES ('SEX255214', 'Female persons, percent, 2014');
INSERT INTO public.county_facts_dictionary (column_name, description) VALUES ('RHI125214', 'White alone, percent, 2014');
INSERT INTO public.county_facts_dictionary (column_name, description) VALUES ('RHI225214', 'Black or African American alone, percent, 2014');
INSERT INTO public.county_facts_dictionary (column_name, description) VALUES ('RHI325214', 'American Indian and Alaska Native alone, percent, 2014');
INSERT INTO public.county_facts_dictionary (column_name, description) VALUES ('RHI425214', 'Asian alone, percent, 2014');
INSERT INTO public.county_facts_dictionary (column_name, description) VALUES ('RHI525214', 'Native Hawaiian and Other Pacific Islander alone, percent, 2014');
INSERT INTO public.county_facts_dictionary (column_name, description) VALUES ('RHI625214', 'Two or More Races, percent, 2014');
INSERT INTO public.county_facts_dictionary (column_name, description) VALUES ('RHI725214', 'Hispanic or Latino, percent, 2014');
INSERT INTO public.county_facts_dictionary (column_name, description) VALUES ('RHI825214', 'White alone, not Hispanic or Latino, percent, 2014');
INSERT INTO public.county_facts_dictionary (column_name, description) VALUES ('POP715213', 'Living in same house 1 year & over, percent, 2009-2013');
INSERT INTO public.county_facts_dictionary (column_name, description) VALUES ('POP645213', 'Foreign born persons, percent, 2009-2013');
INSERT INTO public.county_facts_dictionary (column_name, description) VALUES ('POP815213', 'Language other than English spoken at home, pct age 5+, 2009-2013');
INSERT INTO public.county_facts_dictionary (column_name, description) VALUES ('EDU635213', 'High school graduate or higher, percent of persons age 25+, 2009-2013');
INSERT INTO public.county_facts_dictionary (column_name, description) VALUES ('EDU685213', 'Bachelor''s degree or higher, percent of persons age 25+, 2009-2013');
INSERT INTO public.county_facts_dictionary (column_name, description) VALUES ('VET605213', 'Veterans, 2009-2013');
INSERT INTO public.county_facts_dictionary (column_name, description) VALUES ('LFE305213', 'Mean travel time to work (minutes), workers age 16+, 2009-2013');
INSERT INTO public.county_facts_dictionary (column_name, description) VALUES ('HSG010214', 'Housing units, 2014');
INSERT INTO public.county_facts_dictionary (column_name, description) VALUES ('HSG445213', 'Homeownership rate, 2009-2013');
INSERT INTO public.county_facts_dictionary (column_name, description) VALUES ('HSG096213', 'Housing units in multi-unit structures, percent, 2009-2013');
INSERT INTO public.county_facts_dictionary (column_name, description) VALUES ('HSG495213', 'Median value of owner-occupied housing units, 2009-2013');
INSERT INTO public.county_facts_dictionary (column_name, description) VALUES ('HSD410213', 'Households, 2009-2013');
INSERT INTO public.county_facts_dictionary (column_name, description) VALUES ('HSD310213', 'Persons per household, 2009-2013');
INSERT INTO public.county_facts_dictionary (column_name, description) VALUES ('INC910213', 'Per capita money income in past 12 months (2013 dollars), 2009-2013');
INSERT INTO public.county_facts_dictionary (column_name, description) VALUES ('INC110213', 'Median household income, 2009-2013');
INSERT INTO public.county_facts_dictionary (column_name, description) VALUES ('PVY020213', 'Persons below poverty level, percent, 2009-2013');
INSERT INTO public.county_facts_dictionary (column_name, description) VALUES ('BZA010213', 'Private nonfarm establishments, 2013');
INSERT INTO public.county_facts_dictionary (column_name, description) VALUES ('BZA110213', 'Private nonfarm employment,  2013');
INSERT INTO public.county_facts_dictionary (column_name, description) VALUES ('BZA115213', 'Private nonfarm employment, percent change, 2012-2013');
INSERT INTO public.county_facts_dictionary (column_name, description) VALUES ('NES010213', 'Nonemployer establishments, 2013');
INSERT INTO public.county_facts_dictionary (column_name, description) VALUES ('SBO001207', 'Total number of firms, 2007');
INSERT INTO public.county_facts_dictionary (column_name, description) VALUES ('SBO315207', 'Black-owned firms, percent, 2007');
INSERT INTO public.county_facts_dictionary (column_name, description) VALUES ('SBO115207', 'American Indian- and Alaska Native-owned firms, percent, 2007');
INSERT INTO public.county_facts_dictionary (column_name, description) VALUES ('SBO215207', 'Asian-owned firms, percent, 2007');
INSERT INTO public.county_facts_dictionary (column_name, description) VALUES ('SBO515207', 'Native Hawaiian- and Other Pacific Islander-owned firms, percent, 2007');
INSERT INTO public.county_facts_dictionary (column_name, description) VALUES ('SBO415207', 'Hispanic-owned firms, percent, 2007');
INSERT INTO public.county_facts_dictionary (column_name, description) VALUES ('SBO015207', 'Women-owned firms, percent, 2007');
INSERT INTO public.county_facts_dictionary (column_name, description) VALUES ('MAN450207', 'Manufacturers shipments, 2007 ($1,000)');
INSERT INTO public.county_facts_dictionary (column_name, description) VALUES ('WTN220207', 'Merchant wholesaler sales, 2007 ($1,000)');
INSERT INTO public.county_facts_dictionary (column_name, description) VALUES ('RTN130207', 'Retail sales, 2007 ($1,000)');
INSERT INTO public.county_facts_dictionary (column_name, description) VALUES ('RTN131207', 'Retail sales per capita, 2007');
INSERT INTO public.county_facts_dictionary (column_name, description) VALUES ('AFN120207', 'Accommodation and food services sales, 2007 ($1,000)');
INSERT INTO public.county_facts_dictionary (column_name, description) VALUES ('BPS030214', 'Building permits, 2014');
INSERT INTO public.county_facts_dictionary (column_name, description) VALUES ('LND110210', 'Land area in square miles, 2010');
INSERT INTO public.county_facts_dictionary (column_name, description) VALUES ('POP060210', 'Population per square mile, 2010');