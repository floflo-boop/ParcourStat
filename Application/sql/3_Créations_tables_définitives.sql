
-- Début de la transaction
BEGIN;

-- Toujours utiliser le même schéma
SET search_path TO "Test";

-- Créer la table region avec auto incrémentation de clés primaire

create table region(
	id   SERIAL PRIMARY KEY,
    nom  TEXT
);

-- supprimer les données de la table pour s'assurer qu'elle soit vierge et qu'elle existe.

truncate table region;

-- Insérer dans la table region les données cibles provenant de nos deux tables temporaires. 

INSERT INTO region(nom)
SELECT DISTINCT p."Region_etablissement"
FROM tmp_parcoursup2018 p
WHERE p."Region_etablissement" IS NOT NULL
UNION
SELECT DISTINCT p2."Region_etablissement"
FROM tmp_parcoursup2024 p2
WHERE p2."Region_etablissement" IS NOT NULL;



-- Création de la table departement

create table departement(
code VARCHAR(100) primary key,
nom TEXT,
region_id INT references region (id)
);


-- supprimer les données de la table pour s'assurer qu'elle soit vierge et qu'elle existe

truncate table departement;

-- Insérer dans la table departement les données cibles provenant de nos tables temporaires et de la table définitive region construite ci dessus.

INSERT INTO departement (code, nom, region_id)
SELECT distinct 
	tp1."Code_departemental_etablissement" AS code,
    tp1."Departement_etablissement" AS nom,
    r.id AS region_id
FROM tmp_parcoursup2018 tp1
JOIN region r
    ON tp1."Region_etablissement" = r.nom
UNION
SELECT DISTINCT
    tp2."Code_departemental_etablissement" AS code,
    tp2."Departement_etablissement" AS nom,
    r.id AS region_id
FROM tmp_parcoursup2024 tp2
JOIN region r
    ON tp2."Region_etablissement" = r.nom;


-- Fin de la transaction.
COMMIT;