--création d'une table de travail à partir du csv sur le revenu fiscal de reference 
CREATE TABLE "ParcourStat".TMP_revenu_fiscal_reference AS (
SELECT
    CASE --case pour normaliser les codes départeents et qu'ils soient les mêmes que dans la table département
    WHEN TRIM(CAST("Dép." AS VARCHAR)) IN ('971', '972', '973', '974', '976') 
        THEN TRIM(CAST("Dép." AS VARCHAR))
    -- Corse
    WHEN TRIM(CAST("Dép." AS VARCHAR)) = '2A0' THEN '2A'
    WHEN TRIM(CAST("Dép." AS VARCHAR)) = '2B0' THEN '2B'
    -- Paris arrondissements → 75
    WHEN TRIM(CAST("Dép." AS VARCHAR)) IN ('754', '755', '756', '757', '758') THEN '75'
    -- Petite couronne arrondissements
    WHEN TRIM(CAST("Dép." AS VARCHAR)) IN ('921', '922') THEN '92'
    WHEN TRIM(CAST("Dép." AS VARCHAR)) = '930'           THEN '93'
    WHEN TRIM(CAST("Dép." AS VARCHAR)) = '940'           THEN '94'
    WHEN TRIM(CAST("Dép." AS VARCHAR)) = '950'           THEN '95'
    -- Bouches-du-Rhône et Nord
	WHEN TRIM(CAST("Dép." AS VARCHAR)) IN ('131', '132') THEN '13'
	WHEN TRIM(CAST("Dép." AS VARCHAR)) IN ('591', '592') THEN '59'
    -- Non-résidents : exclusion
    WHEN TRIM(CAST("Dép." AS VARCHAR)) = 'B31' THEN NULL
    -- Cas général : suppression du zéro final
    WHEN RIGHT(TRIM(CAST("Dép." AS VARCHAR)), 1) = '0'
        THEN LEFT(TRIM(CAST("Dép." AS VARCHAR)), LENGTH(TRIM(CAST("Dép." AS VARCHAR))) - 1)
    ELSE TRIM(CAST("Dép." AS VARCHAR))
END AS "Code_departement",
    TRIM(CAST("Revenu fiscal de référence par tranche (en euros)" AS VARCHAR)) AS "Tranche_revenus",
    SUM(
        CAST(NULLIF(TRIM(CAST("Nombre de foyers fiscaux" AS VARCHAR)), 'n.c.') AS INT)
    )                                                                      AS "Nombre_foyers_fiscaux",
    SUM(
        CAST(NULLIF(TRIM(CAST("Revenu fiscal de référence des foyers fiscaux" AS VARCHAR)), 'n.c.') AS BIGINT)
    )                                                                      AS "Revenu_fiscal_reference_milliers",
    SUM(
        CAST(NULLIF(TRIM(CAST("Nombre de foyers fiscaux imposés" AS VARCHAR)), 'n.c.') AS INT)
    )                                                                      AS "Nombre_foyers_imposes",
    SUM(
        CAST(NULLIF(TRIM(CAST("Revenu fiscal de référence des foyers fiscaux imposés" AS VARCHAR)), 'n.c.') AS BIGINT)
    )                                                                      AS "Revenu_fiscal_reference_imposes_milliers"
FROM revenu_fiscal_reference

WHERE TRIM(CAST("Commune" AS VARCHAR)) NOT IN ('', ' ')
  AND TRIM(CAST("Commune" AS VARCHAR)) IS NOT NULL
  AND TRIM(CAST("Dép." AS VARCHAR)) != 'B31'  -- ← exclure les non-résidents
GROUP BY
    CASE
        WHEN TRIM(CAST("Dép." AS VARCHAR)) IN ('971', '972', '973', '974', '976') 
            THEN TRIM(CAST("Dép." AS VARCHAR))
        WHEN TRIM(CAST("Dép." AS VARCHAR)) = '2A0' THEN '2A'
        WHEN TRIM(CAST("Dép." AS VARCHAR)) = '2B0' THEN '2B'
        WHEN TRIM(CAST("Dép." AS VARCHAR)) IN ('754', '755', '756', '757', '758') THEN '75'
        WHEN TRIM(CAST("Dép." AS VARCHAR)) IN ('921', '922') THEN '92'
        WHEN TRIM(CAST("Dép." AS VARCHAR)) = '930'            THEN '93'
        WHEN TRIM(CAST("Dép." AS VARCHAR)) = '940'            THEN '94'  -- ← corrigé
        WHEN TRIM(CAST("Dép." AS VARCHAR)) = '950'            THEN '95'
        WHEN TRIM(CAST("Dép." AS VARCHAR)) IN ('131', '132') THEN '13'
		WHEN TRIM(CAST("Dép." AS VARCHAR)) IN ('591', '592') THEN '59'
        WHEN TRIM(CAST("Dép." AS VARCHAR)) = 'B31' THEN NULL
        WHEN RIGHT(TRIM(CAST("Dép." AS VARCHAR)), 1) = '0'
            THEN LEFT(TRIM(CAST("Dép." AS VARCHAR)), LENGTH(TRIM(CAST("Dép." AS VARCHAR))) - 1)
        ELSE TRIM(CAST("Dép." AS VARCHAR))
    END,
    TRIM(CAST("Revenu fiscal de référence par tranche (en euros)" AS VARCHAR))
ORDER BY
    "Code_departement",
    "Tranche_revenus"




