SELECT Case_Num,
COUNT(Case_Num) AS NumOccurrences
FROM GEthicsAdmin.tblCASE_NARRATIVE
GROUP BY Case_Num
HAVING (COUNT(Case_Num) > 1)