--- Création d'une vue permettant de croiser le niveau de richesse des départements
-- avec les caractéristiques des formations Parcoursup qui y sont proposées.
-- Elle permet d'identifier si les départements les plus riches proposent davantage
-- de formations sélectives, et inversement si les territoires moins favorisés
-- sont davantage orientés vers des formations non sélectives.
CREATE OR REPLACE VIEW "ParcourStat".VUE_simple_formations_richesse AS
SELECT
    dep.nom                                         AS "Departement",
    dep.code                                        AS "Code_departement",
    reg.nom                                         AS "Region",
    r.revenu_moyen_par_foyer_euros                  AS "Revenu_moyen_par_foyer",
    r.taux_foyers_imposes_pct                       AS "Taux_foyers_imposes",
    f.nom                                           AS "Nom_formation",
    f.selectivite                                   AS "Selective",
    tt.nom                                          AS "Type_formation"

FROM formation f
-- Remontée de la hiérarchie géographique : formation → établissement → commune → département → région
JOIN etablissement e        ON f.etablissement_id = e.id
JOIN commune com            ON e.commune_id = com.id
JOIN departement dep        ON com.departement_id = dep.code
JOIN region reg             ON dep.region_id = reg.id
-- Jointure avec les données fiscales IRCOM 2023
-- Le filtre sur 'Total' garantit une seule ligne par département
JOIN revenu_fiscal_reference_def r
                            ON r.code_departement = dep.code
                            AND r.tranche_revenus = 'Total'
-- LEFT JOIN car certaines formations peuvent ne pas avoir de type renseigné
-- On évite ainsi de perdre ces formations dans le résultat
LEFT JOIN disciplinetypes dt    ON dt.formation_id = f.id
LEFT JOIN types_formations tt   ON tt.id = dt.type_formation_id;