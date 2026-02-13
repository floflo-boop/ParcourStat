
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
-- Utilisation d'une jointure afin de créer la correspondance pour chaque donnée avec sa bonne clés étrangère.

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



-- Création de la table commune 

CREATE table commune (
  id SERIAL PRIMARY KEY,
  nom TEXT NOT NULL,
  departement_id VARCHAR(100) REFERENCES departement(code)
);

-- Supprimer les données de la table pour s'assurer qu'elle soit vierge et qu'elle existe 

truncate table commune;

-- Insérer les données dans la table commune.

INSERT INTO commune (nom, departement_id)
SELECT DISTINCT 
    tp."Commune_etablissement",
    d.code
FROM tmp_parcoursup2024 tp -- Il n'y a pas de commune dans le jeu de donnée de 2018. On ne se base donc que sur 2024.
INNER JOIN Departement d ON tp."Departement_etablissement" = d.nom;

-- Attention, en sortie on peut avoir des "doublons" par exemple Valence se repète deux fois mais à deux clés primaires différentes et deux clés étrangère 
-- vers departement qui sont différentes. Cela s'expliquer car il existe deux villes nommées Valence dans deux départements différents. C'est donc normal.




-- Création de la table Académie 

CREATE TABLE academie (
  id  SERIAL PRIMARY KEY,
  nom TEXT
);

-- Supprimer les données de la table pour s'assurer qu'elle soit vierge et qu'elle existe 

truncate table academie;

-- Insérer les données dans la table academie

insert into academie (nom)
select distinct tp."Academie_etablissement" as nom 
from tmp_parcoursup2024 tp
union 
select distinct tp2."Academie_etablissement" as nom 
from tmp_parcoursup2018 tp2;



-- Création de la table Etablissement

CREATE TABLE etablissement (
  Id TEXT PRIMARY KEY,
  Nom TEXT,
  Statut TEXT,
  Site_web TEXT,
  Adresse TEXT,
  Nombre_etudiants INT, 
  Url_logo TEXT,
  Url_image TEXT,
  Commune_id  INT REFERENCES commune(id),
  Academie_id  INT REFERENCES academie(id)
);

-- Supprimer les données de la table pour s'assurer qu'elle soit vierge et qu'elle existe 

truncate table etablissement;


-- Insérer les données dans la table Etablissement

-- Utilisation d'une sous-requête avec DISTINCT pour éliminer les doublons

INSERT INTO etablissement (
    Id,
    Nom,
    Statut,
    Site_web,
    Adresse,
    Nombre_etudiants,
    Url_logo,
    Url_image,
    Commune_id,
    Academie_id
) 
SELECT DISTINCT ON (COALESCE(tp2024."Code_UAI", tp2018."Code_UAI")) /* On élimine un maximum de doublon à l'aide de DISTINCT et de COALESCE qui permet de sélectionner une priorité de valeur. 
Si pour un même champs on a deux valeurs différentes, une des deux sera privéligée. Dans notre cas, en 2018 on peut avoir des NULL complété en 2024, alors on donne la priorité à 2024 */
    COALESCE(tp2024."Code_UAI", tp2018."Code_UAI") AS Id,
    COALESCE(tp2024."Etablissement", tp2018."Etablissement") AS Nom,
    tp2024."Statut_etablissement_filière_formation" AS Statut,
    wd.site_web AS Site_web,
    wd.adresse AS Adresse,
    wd.nb_etudiants AS Nombre_etudiants,
    wd.url_logo AS Url_logo,
    wd.url_image AS Url_image,
    c.id AS Commune_id,
    a.id AS Academie_id
FROM tmp_parcoursup2024 tp2024
FULL OUTER JOIN tmp_parcoursup2018 tp2018 ON tp2024."Code_UAI" = tp2018."Code_UAI" /* FULL OUTER JOIN afin de garder aussi bien les établissements communs à nos tables, que ceux présents uniquement dans une des deux tables. */
LEFT JOIN wikidata wd ON COALESCE(tp2024."Code_UAI", tp2018."Code_UAI") = wd.etablissement_id
LEFT JOIN commune c ON tp2024."Commune_etablissement" = c.nom
LEFT JOIN academie a ON COALESCE(tp2024."Academie_etablissement", tp2018."Academie_etablissement") = a.nom
WHERE (tp2018."Code_UAI" IS NULL OR tp2018."Code_UAI" != 'identifiant obsolète') /*Exclusion des 'identifiants obsolète'. Cas que nous n'avons pas réussi à élucider. Il représente 60 lignes de données.*/
ON CONFLICT (Id)
DO UPDATE SET
    Nom = COALESCE(EXCLUDED.Nom, "Test".etablissement.Nom),
    Statut = COALESCE(EXCLUDED.Statut, "Test".etablissement.Statut),
    Site_web = COALESCE(EXCLUDED.Site_web, "Test".etablissement.Site_web),
    Adresse = COALESCE(EXCLUDED.Adresse, "Test".etablissement.Adresse),
    Nombre_etudiants = COALESCE(EXCLUDED.Nombre_etudiants, "Test".etablissement.Nombre_etudiants),
    Url_logo = COALESCE(EXCLUDED.Url_logo, "Test".etablissement.Url_logo),
    Url_image = COALESCE(EXCLUDED.Url_image, "Test".etablissement.Url_image),
    Commune_id = COALESCE(EXCLUDED.Commune_id, "Test".etablissement.Commune_id),
    Academie_id = COALESCE(EXCLUDED.Academie_id, "Test".etablissement.Academie_id);



-- Fin de la transaction.
COMMIT;