






WITH RECURSIVE table ( column ) AS (WITH table AS (SELECT * ), table2 (column2) AS (SELECT ALL *) SELECT * )
SELECT DISTINCT *, table_1.*

FROM log_sor
WHERE sor_etat = 'V'
ORDER BY sor_num
