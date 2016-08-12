WITH table1 AS
WITH RECURSIVE _table2 ( column1 ) AS

SELECT *
FROM log_sor
WHERE sor_etat = 'V'
ORDER BY sor_num
