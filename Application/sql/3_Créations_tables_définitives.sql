
-- Début de la transaction
BEGIN;

-- Toujours utiliser le même schéma
SET search_path TO "ParcourStat";

-- Création de la table region avec une auto incrémentation de la clé primaire

create table region(
	id   SERIAL PRIMARY KEY,
    nom  TEXT
);

-- Suppression des données de la table pour s'assurer qu'elle soit vierge et qu'elle existe.

truncate table region;

-- Insertion dans la table region des données cibles provenant de nos deux tables temporaires. 

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


-- Suppression des données de la table pour s'assurer qu'elle soit vierge et qu'elle existe

truncate table departement;

-- Insertion dans la table departement des données cibles provenant de nos tables temporaires et de la table définitive region construite ci-dessus.
-- Utilisation d'une jointure afin de créer la correspondance pour chaque donnée avec sa bonne clé étrangère.

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

-- Supression des données de la table pour s'assurer qu'elle soit vierge et qu'elle existe 

truncate table commune;

-- Insertion des données dans la table commune.

INSERT INTO commune (nom, departement_id)
SELECT DISTINCT 
    tp."Commune_etablissement",
    d.code
FROM tmp_parcoursup2024 tp -- Il n'y a pas de commune dans le jeu de donnée de 2018. On ne se base donc que sur 2024.
INNER JOIN Departement d ON tp."Departement_etablissement" = d.nom;

-- Attention, en sortie on peut avoir des "doublons" par exemple Valence se repète deux fois mais à deux clés primaires différentes, et deux clés étrangères 
-- vers departement sont différentes. Cela s'explique par le fait qu'il existe deux villes nommées Valence dans deux départements différents. C'est donc normal.




-- Création de la table Académie 

CREATE TABLE academie (
  id  SERIAL PRIMARY KEY,
  nom TEXT
);

-- Supression des données de la table pour s'assurer qu'elle soit vierge et qu'elle existe 

truncate table academie;

-- Insertion des données dans la table academie

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

-- Supression des données de la table pour s'assurer qu'elle soit vierge et qu'elle existe 

truncate table etablissement;


-- Insertion des données dans la table Etablissement

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
SELECT DISTINCT ON (COALESCE(tp2024."Code_UAI", tp2018."Code_UAI")) /* On élimine un maximum de doublons à l'aide de DISTINCT et de COALESCE qui permet de sélectionner une priorité de valeur. 
Si, pour un même champ, il existe deux valeurs différentes, une des deux sera privéligée. Dans notre cas, des valeurs NULL en 2018 sont complétées en 2024. La priorité est donc donnée à 2024 */
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
FULL OUTER JOIN tmp_parcoursup2018 tp2018 ON tp2024."Code_UAI" = tp2018."Code_UAI" /* On réalise un FULL OUTER JOIN afin de garder aussi bien les établissements communs à nos tables, que ceux présents uniquement dans une des deux tables. */
LEFT JOIN wikidata wd ON COALESCE(tp2024."Code_UAI", tp2018."Code_UAI") = wd.etablissement_id
LEFT JOIN commune c ON tp2024."Commune_etablissement" = c.nom
LEFT JOIN academie a ON COALESCE(tp2024."Academie_etablissement", tp2018."Academie_etablissement") = a.nom
WHERE (tp2018."Code_UAI" IS NULL OR tp2018."Code_UAI" != 'identifiant obsolète') /*Exclusion des 'identifiants obsolètes'. Il s'agit du cas que nous n'avons pas réussi à élucider, et qui représente 60 lignes de données.*/
ON CONFLICT (Id)
DO UPDATE SET
    Nom = COALESCE(EXCLUDED.Nom, etablissement.Nom),
    Statut = COALESCE(EXCLUDED.Statut, etablissement.Statut),
    Site_web = COALESCE(EXCLUDED.Site_web, etablissement.Site_web),
    Adresse = COALESCE(EXCLUDED.Adresse, etablissement.Adresse),
    Nombre_etudiants = COALESCE(EXCLUDED.Nombre_etudiants, etablissement.Nombre_etudiants),
    Url_logo = COALESCE(EXCLUDED.Url_logo, etablissement.Url_logo),
    Url_image = COALESCE(EXCLUDED.Url_image, etablissement.Url_image),
    Commune_id = COALESCE(EXCLUDED.Commune_id, etablissement.Commune_id),
    Academie_id = COALESCE(EXCLUDED.Academie_id, etablissement.Academie_id);


-- Création de la table types_formations 

create table types_formations(
	id  SERIAL PRIMARY KEY,
 	nom TEXT
);


-- Suppression des données de la table afin de s'assurer qu'elle soit vierge et qu'elle existe 

truncate table types_formations;

-- Insertion des données dans la table types_formations 

INSERT INTO types_formations(nom)
SELECT DISTINCT p."Filiere_formation_tres_agregee"
FROM tmp_parcoursup2024 p
UNION
SELECT DISTINCT p2."Filiere_formation_tres_agregee"
FROM tmp_parcoursup2018 p2 ;


-- Création de la table discipline 

CREATE TABLE discipline (
  id  SERIAL PRIMARY KEY,
  nom TEXT,
  type INT REFERENCES types_formations(id)
);

-- Suppression des données de la table afin de s'assurer qu'elle soit vierge et qu'elle existe 

truncate table discipline; 

-- Insertion des données dans la table discipline 

insert into discipline (nom, type )
select distinct tp."Filiere_formation" as nom, tf.id as type
from tmp_parcoursup2024 tp
join types_formations tf 
on tp."Filiere_formation_tres_agregee" = tf.nom
union 
select distinct tp2."Filiere_formation" as nom, tf2.id as type
from tmp_parcoursup2018 tp2
join types_formations tf2 
on tp2."Filiere_formation_tres_agregee" = tf2.nom;



-- Création de la table Formation 

CREATE TABLE formation (
  id SERIAL PRIMARY KEY,
  nom TEXT,
  etablissement_id TEXT NOT NULL REFERENCES etablissement(id),
  type_formation_id INT NOT NULL REFERENCES types_formations(id),
  discipline_id INT NOT NULL REFERENCES discipline(id),
  selectivite BOOL,
  Coordonnees_GPS_formation TEXT,
  identifiant_parcoursup TEXT
);

-- Suppression des données de la table afin de s'assurer qu'elle soit vierge et qu'elle existe. 

truncate table formation; 

-- Insertion des données dans la table discipline 

insert into formation (
	nom, 
	etablissement_id, 
	type_formation_id, 
	discipline_id, 
	selectivite, 
	coordonnees_gps_formation, 
	identifiant_parcoursup
)
select distinct 
	tm."Filiere_formation_Detaillee" as nom,
	e.id as etablissement_id,
	tf.id as type_formation_id, 
	d.id as discipline_id,
	tm."Selectivite" as selectivite,
	tm."Coordonnees_gps_formation" as coordonnees_gps_formation,
	tm."Lien_formation_parcoursup" as identifiant_parcoursup
from tmp_parcoursup2024 tm
join etablissement e 
on tm."Etablissement" = e.nom 
join types_formations tf 
on tm."Filiere_formation_tres_agregee" = tf.nom 
join discipline d 
on tm."Filiere_formation" = d.nom 
union 
select distinct 
	tm."Filiere_formation_detaillee" as nom,
	e.id as etablissement_id,
	tf.id as type_formation_id, 
	d.id as discipline_id,
	null::boolean,
	tm."Coordonnees_gps_formation" as coordonnees_gps_formation,
	tm."Lien_formation_parcoursup" as identifiant_parcoursup
from tmp_parcoursup2018 tm
join etablissement e 
on tm."Etablissement" = e.nom 
join types_formations tf 
on tm."Filiere_formation_tres_agregee" = tf.nom 
join discipline d 
on tm."Filiere_formation" = d.nom ;

-- Fin de la transaction.
COMMIT