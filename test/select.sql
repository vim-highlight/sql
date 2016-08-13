






WITH RECURSIVE table ( column ) AS (WITH table AS (), table2 (column2) AS () )

SELECT *
FROM log_sor
WHERE sor_etat = 'V'
ORDER BY sor_num
