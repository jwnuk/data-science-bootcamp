/*EDIT: rankingi dla kadydatów w obrêbie danej partii*/
/*ranking kandydatów w poszczególnych stanach*/
CREATE VIEW candidates_in_states AS
SELECT
  pr.state ,
  pr.party ,
  pr.candidate ,
  sum(pr.votes) votes ,
  RANK() OVER(
    PARTITION BY pr.state,
    pr.party
  ORDER BY
    sum(pr.votes) DESC
  ) ranking
FROM
  primary_results pr
GROUP BY
  pr.state ,
  pr.candidate ,
  pr.party 
ORDER BY
  pr.state ;

SELECT *
FROM
  candidates_in_states ;

/*ranking kandydatów w poszczególnych stanach z wartoœciami procentowymi*/
CREATE VIEW candidates_percent_in_states AS
SELECT * ,
  sum(votes) OVER (
    PARTITION BY state, party 
  ) vote_sum ,
  round(votes / sum(votes) OVER (PARTITION BY state, party) * 100::NUMERIC, 3) percent_votes
FROM
  candidates_in_states ;

SELECT *
FROM
  candidates_percent_in_states ;

/*wygrani w poszczególnych stanach*/
CREATE VIEW winners_in_states AS
SELECT *
FROM
  candidates_percent_in_states
WHERE
  ranking = 1 ;

SELECT *
FROM
  winners_in_states ;
