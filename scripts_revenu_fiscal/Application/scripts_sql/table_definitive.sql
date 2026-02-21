--creation de la table définitive revenu_fiscal_reference 

CREATE TABLE "ParcourStat".revenu_fiscal_reference_def (
    code_departement    VARCHAR(100) REFERENCES "ParcourStat".departement(code),
    tranche_revenus     VARCHAR(100),
    nombre_foyers_fiscaux               INT,
    revenu_fiscal_reference_milliers    BIGINT,
    nombre_foyers_imposes               INT,
    revenu_fiscal_reference_imposes_milliers BIGINT,
    revenu_moyen_par_foyer_euros        NUMERIC,
    taux_foyers_imposes_pct             NUMERIC,
    PRIMARY KEY (code_departement, tranche_revenus)
);

-- Suppression des données pour s'assurer que la table est vierge
TRUNCATE TABLE "ParcourStat".revenu_fiscal_reference_def;

-- Insertion des données depuis la table temporaire
-- avec jointure sur la table département pour valider la clé étrangère
INSERT INTO "ParcourStat".revenu_fiscal_reference_def (
    code_departement,
    tranche_revenus,
    nombre_foyers_fiscaux,
    revenu_fiscal_reference_milliers,
    nombre_foyers_imposes,
    revenu_fiscal_reference_imposes_milliers,
    revenu_moyen_par_foyer_euros,
    taux_foyers_imposes_pct
)
SELECT
    r."Code_departement",
    r."Tranche_revenus",
    r."Nombre_foyers_fiscaux",
    r."Revenu_fiscal_reference_milliers",
    r."Nombre_foyers_imposes",
    r."Revenu_fiscal_reference_imposes_milliers",

    -- Revenu moyen par foyer en euros
    CASE
        WHEN r."Nombre_foyers_fiscaux" > 0
        THEN ROUND((r."Revenu_fiscal_reference_milliers" * 1000.0)
             / r."Nombre_foyers_fiscaux", 0)
        ELSE NULL
    END,

    -- Taux de foyers imposés
    CASE
        WHEN r."Nombre_foyers_fiscaux" > 0
        THEN ROUND(r."Nombre_foyers_imposes" * 100.0
             / r."Nombre_foyers_fiscaux", 1)
        ELSE NULL
    END

FROM "ParcourStat".TMP_revenu_fiscal_reference r
-- Jointure pour ne garder que les départements présents dans la table département
JOIN "ParcourStat".departement d
    ON d.code = r."Code_departement"

ORDER BY r."Code_departement", r."Tranche_revenus";

