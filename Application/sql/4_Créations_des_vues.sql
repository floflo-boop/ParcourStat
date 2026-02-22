-- Début de la transaction
BEGIN;

-- Toujours utiliser le même schéma
CREATE SCHEMA IF NOT EXISTS "ParcourStat";
SET search_path TO "ParcourStat";


-- Création d'une vue permettant de montrer le nombre de formation par région. 
-- Cela permet de créer une première connaissance : la répartition inégale de l'accès à la formation supérieure dû à la concentration des formations en île de France et à la rareté de ces formations notamment dans les Territoires d'Outre Mer et les lieux d'expatriation.
-- Nous pourrions utiliser un jeu de données sur le taux de ruralités dans les régions afin de faire ressortir la répartition des formations en fonction de l'urbanisation. 
-- Cela crée une nouvelle information : la répartition inégale de l'accès à l'enseignement supérieur en fonction d'un critère de ruralité. 
-- Mais peu révélateur quant à l'inégalité de la repartition des formations d'enseignement supérieur sur le territoire français en fonction de l'éloignement avec la capitale française.

create view nombre_formation_par_region as  
	select r.nom as region, count(f.id ) as nbr_formation 
	from region r
	join departement d on r.id = d.region_id 
	join commune c on d.code = c.departement_id 
	join etablissement e on c.id = e.commune_id 
	join formation f on e.id = f.etablissement_id 
	group by r.nom 
	order by nbr_formation DESC;






-- Création d'une vue permettant de montrer le taux d'acceptation des filles dans les disciplines en combinant 2018 et 2024. 
-- Le chiffre est calculé en fonction du rapport candidates/admises. Donc 25 par exemple voudrait que seulement 25 des candidates aient été acceptées.
-- Cela permet de créer une première connaissance sur la parité dans les formations. 
-- Cette vue est à enrichir, elle n'est pour le moment pas encore élaborée à son maximum. 


create view taux_filles_acceptées_par_disciplines as 
	select d.nom as discipline, AVG(a.pa_f) as taux_acceptation_candidates
	from admissions a 
	join formation f on a.formation_id = f.id 
	join discipline d on f.discipline_id = d.id 
	GROUP BY discipline 
	order by taux_acceptation_candidates DESC;






-- Création d'une vue permettant de montrer le nombre moyen de boursiers admis par région.
-- Elle permet d'identifier les régions qui accueillent le plus de boursiers et celles qui en accueillent le moins.
-- Cela crée de la connaissance autour du taux d'accessibilité sociale de chaque région.
-- Toutefois, elle reste limitée puisqu'elle ne prend pas en compte le nombre de formations par régions, croisée avec le nombre de boursiers. Une région qui accueille un grand nombre de boursiers ne possède donc pas forcément une grande accessibilité sociale, mais peut avoir un grand nombre de formations.


create view boursiers_admis_regions as
select
   region.nom AS region,
   AVG(admissions.PA_NB_B) AS boursiers_admis
from admissions
join formation ON admissions.formation_id = formation.id
join etablissement ON formation.etablissement_id = etablissement.id
join commune ON etablissement.commune_id = commune.id
join departement ON commune.departement_id = departement.code
join region ON departement.region_id = region.id
group by region.nom;






--- Création d'une vue permettant de croiser le niveau de richesse des départements 
-- avec les caractéristiques des formations Parcoursup qui y sont proposées.
-- Elle permet d'identifier si les départements les plus riches proposent davantage
-- de formations sélectives, et inversement si les territoires moins favorisés
-- sont davantage orientés vers des formations non sélectives.

CREATE OR REPLACE VIEW VUE_simple_formations_richesse AS
SELECT
    dep.nom AS "Departement",
    dep.code AS "Code_departement",
    reg.nom AS "Region",
    r.revenu_moyen_par_foyer_euros AS "Revenu_moyen_par_foyer",
    r.taux_foyers_imposes_pct AS "Taux_foyers_imposes",
    f.nom AS "Nom_formation",
    f.selectivite AS "Selective",
    tt.nom AS "Type_formation"

FROM formation f
-- Remontée de la hiérarchie géographique : formation → établissement → commune → département → région
JOIN etablissement e 
ON f.etablissement_id = e.id
JOIN commune com 
ON e.commune_id = com.id
JOIN departement dep 
ON com.departement_id = dep.code
JOIN region reg 
ON dep.region_id = reg.id
-- Jointure avec les données fiscales IRCOM 2023
-- Le filtre sur 'Total' garantit une seule ligne par département
JOIN revenu_fiscal_reference_def r
ON r.code_departement = dep.code
AND r.tranche_revenus = 'Total'
-- LEFT JOIN car certaines formations peuvent ne pas avoir de type renseigné
-- On évite ainsi de perdre ces formations dans le résultat
LEFT JOIN discipline dt
ON dt.id = f.discipline_id
LEFT JOIN types_formations tt
ON tt.id = dt.type;






-- Création d'une vue permettant de croiser nos informations sur les admissions des boursiers et les IPS. 
-- Vue générale qui permet de comparer une analyses multi échelles et multi critère.
-- Servira de base pour une autre vue et offre diverses possibilités de visualisation.


CREATE VIEW Boursiers_et_IPS as
SELECT
    e.id AS code_uai,
    e.nom AS nom_etablissement,
    il.ips_etablissement,
    il.ips_legt,
    il.ips_pro,
    il.typologie,
    a.ea_bn_b AS nb_admis_boursiers_neobac,
    a.ea_nb AS nb_admis_neobac_total,
    a.pa_nb_b AS pct_admis_neobac_boursiers,
    CASE 
        WHEN il.ips_etablissement < n.ips_national_legt THEN 'Sous la moyenne nationale'
        WHEN il.ips_etablissement > n.ips_national_legt THEN 'Au dessus de la moyenne nationale'
        ELSE 'Dans la moyenne nationale'
    END AS position_nationale,
    ROUND((il.ips_etablissement - n.ips_national_legt)::numeric, 2) AS ecart_ips_national,
    n.ips_national_legt AS ips_ref_nationale
FROM ips_lycee il
JOIN etablissement e ON e.id = il.code_uai
JOIN formation f ON f.etablissement_id = e.id
JOIN admissions a ON a.formation_id = f.id AND a.annee = 2024
CROSS JOIN ips_nationaux n
WHERE a.ea_bn_b IS NOT NULL
AND a.ea_nb > 0;






-- Création d'une vue s'appuyant sur la précédente. 
-- Elle permet une analyse plus précise à l'échelle de la région. 
-- Script créer dans l'optique d'une création d'une carte choroplète, dynamique et interactive sur Tableau.

CREATE VIEW ips_boursiers_region AS
WITH ips_region_agg AS (
    SELECT
        r.id AS region_id,
        r.nom AS region_nom,
        -- IPS moyen pondéré
        ROUND(
            SUM(a.ips_etablissement * a.nb_admis_neobac_total)::numeric
            / NULLIF(SUM(a.nb_admis_neobac_total), 0), 2
        ) AS ips_region_pondere,
        -- Effectifs boursiers
        SUM(a.nb_admis_boursiers_neobac) AS total_boursiers_admis,
        SUM(a.nb_admis_neobac_total) AS total_admis_neobac,
        -- Taux de boursiers
        ROUND(
            SUM(a.nb_admis_boursiers_neobac)::numeric
            / NULLIF(SUM(a.nb_admis_neobac_total), 0) * 100, 2
        ) AS taux_boursiers_region,
        -- Nombre d'établissements
        COUNT(DISTINCT a.code_uai) AS nb_etablissements
    FROM boursiers_et_ips a
    JOIN etablissement e ON e.id = a.code_uai
    JOIN commune c ON c.id = e.commune_id
    JOIN departement d ON d.code = c.departement_id
    JOIN region r ON r.id = d.region_id
    GROUP BY r.id, r.nom
)
SELECT
    *,
    -- Quintile pour la couleur (calculé après l'agrégation)
    NTILE(5) OVER (ORDER BY ips_region_pondere) AS quintile_ips,
    -- Écart à la moyenne nationale
    ROUND(ips_region_pondere - 118.5, 2) AS ecart_national
FROM ips_region_agg;



-- Fin de transaction

COMMIT; 