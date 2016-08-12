WITH RECURSIVE dfc

RECURSIVE

SELECT *
FROM log_sor
WHERE sor_etat = 'V'
ORDER BY sor_num
