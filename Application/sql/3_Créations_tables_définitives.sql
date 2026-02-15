
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
  nom TEXT NOT NULL,
  etablissement_id TEXT NOT NULL REFERENCES etablissement(id),
  type_formation_id INT NOT NULL REFERENCES types_formations(id),
  discipline_id INT NOT NULL REFERENCES discipline(id),
  selectivite BOOL,
  Coordonnees_GPS_formation TEXT,
  identifiant_parcoursup TEXT,

  CONSTRAINT formation_unique_nom_etab
  UNIQUE (nom, etablissement_id)
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
select
    nom,
    etablissement_id,
    max(type_formation_id) as type_formation_id,
    max(discipline_id) as discipline_id,
    bool_or(selectivite) as selectivite,
    max(coordonnees_gps_formation) as coordonnees_gps_formation,
    max(identifiant_parcoursup) as identifiant_parcoursup
from (
    select
        tm."Filiere_formation_Detaillee" as nom,
        e.id as etablissement_id,
        tf.id as type_formation_id,
        d.id as discipline_id,
        tm."Selectivite" as selectivite,
        tm."Coordonnees_gps_formation" as coordonnees_gps_formation,
        tm."Lien_formation_parcoursup" as identifiant_parcoursup
    from tmp_parcoursup2024 tm
    join etablissement e on tm."Code_UAI" = e.id  -- ← Changement ici
    join types_formations tf on tm."Filiere_formation_tres_agregee" = tf.nom
    join discipline d on tm."Filiere_formation" = d.nom

    union all

    select
        tm."Filiere_formation_detaillee" as nom,
        e.id as etablissement_id,
        tf.id as type_formation_id,
        d.id as discipline_id,
        null::boolean as selectivite,
        tm."Coordonnees_gps_formation" as coordonnees_gps_formation,
        tm."Lien_formation_parcoursup" as identifiant_parcoursup
    from tmp_parcoursup2018 tm
    join etablissement e on tm."Code_UAI" = e.id  -- ← Changement ici
    join types_formations tf on tm."Filiere_formation_tres_agregee" = tf.nom
    join discipline d on tm."Filiere_formation" = d.nom
) t
group by nom, etablissement_id;







-- Création de la table candidatures


CREATE TABLE candidatures (
    id SERIAL PRIMARY KEY,
    formation_id INT NOT NULL REFERENCES formation(id),
    annee INT NOT NULL,
    ET_C INT,
    ET_CF INT,
    ET_C_PP INT,
    EC_I INT,
    EC_NB_G INT,
    EC_B_NB_G INT,
    EC_NB_T INT,
    EC_B_NB_T INT,
    EC_NB_P INT,
    EC_B_NB INT,
    EC_AC INT,
    ETC_PC INT,
    EC_NB_G_PC INT,
    EC_NB_T_PC INT,
    EC_NB_P_PC INT,
    EAC_PC INT,
    ETC_CE INT,
    EC_CE_PC INT,
    ETC_R_PA INT,
    ETC_A_PE INT,
    ETC_F_A_PE INT,
    EC_TG_PA_E INT,
    EC_B_TG_PA_E INT,
    EC_TT_PA_E INT,
    EC_B_TT_PA_E INT,
    EC_TP_PA_E INT,
    EC_B_TP_PA_E INT,
    EAC_PA_E INT,
    CONSTRAINT candidatures_unique
        UNIQUE (formation_id, annee)
);


-- Supprimer les données de la table afin de s'assurer qu'elle existe et qu'elle est vierge de données 

truncate table candidatures;


-- Insérer les données cibles dans la table. 

insert into candidatures(
    formation_id,
    annee,
    ET_C,
    ET_CF,
    ET_C_PP,
    EC_I,
    EC_NB_G,
    EC_B_NB_G,
    EC_NB_T,
    EC_B_NB_T,
    EC_NB_P,
    EC_B_NB,
    EC_AC,
    ETC_PC,
    EC_NB_G_PC,
    EC_NB_T_PC,
    EC_NB_P_PC,
    EAC_PC,
    ETC_CE,
    EC_CE_PC,
    ETC_R_PA,
    ETC_A_PE,
    ETC_F_A_PE,
    EC_TG_PA_E,
    EC_B_TG_PA_E,
    EC_TT_PA_E,
    EC_B_TT_PA_E,
    EC_TP_PA_E,
    EC_B_TP_PA_E,
    EAC_PA_E
)
select
    formation_id,
    annee,
    MAX(ET_C) as ET_C,
    MAX(ET_CF) as ET_CF,
    MAX(ET_C_PP) as ET_C_PP,
    MAX(EC_I) as EC_I,
    MAX(EC_NB_G) as EC_NB_G,
    MAX(EC_B_NB_G) as EC_B_NB_G,
    MAX(EC_NB_T) as EC_NB_T,
    MAX(EC_B_NB_T) as EC_B_NB_T,
    MAX(EC_NB_P) as EC_NB_P,
    MAX(EC_B_NB) as EC_B_NB,
    MAX(EC_AC) as EC_AC,
    MAX(ETC_PC) as ETC_PC,
    MAX(EC_NB_G_PC) as EC_NB_G_PC,
    MAX(EC_NB_T_PC) as EC_NB_T_PC,
    MAX(EC_NB_P_PC) as EC_NB_P_PC,
    MAX(EAC_PC) as EAC_PC,
    MAX(ETC_CE) as ETC_CE,
    MAX(EC_CE_PC) as EC_CE_PC,
    MAX(ETC_R_PA) as ETC_R_PA,
    MAX(ETC_A_PE) as ETC_A_PE,
    MAX(ETC_F_A_PE) as ETC_F_A_PE,
    MAX(EC_TG_PA_E) as EC_TG_PA_E,
    MAX(EC_B_TG_PA_E) as EC_B_TG_PA_E,
    MAX(EC_TT_PA_E) as EC_TT_PA_E,
    MAX(EC_B_TT_PA_E) as EC_B_TT_PA_E,
    MAX(EC_TP_PA_E) as EC_TP_PA_E,
    MAX(EC_B_TP_PA_E) as EC_B_TP_PA_E,
    MAX(EAC_PA_E) as EAC_PA_E
from (
    select
        f.id as formation_id,
        p."Annee" as annee,
        p."ET_C" as ET_C,
        p."ET_CF" as ET_CF,
        p."ET_C_PP" as ET_C_PP,
        p."EC_I" as EC_I,
        p."EC_NB_G" as EC_NB_G,
        p."EC_B_NB_G" as EC_B_NB_G,
        p."EC_NB_T" as EC_NB_T,
        p."EC_B_NB_T" as EC_B_NB_T,
        p."EC_NB_P" as EC_NB_P,
        p."EC_B_NB" as EC_B_NB,
        p."EC_AC" as EC_AC,
        p."ETC_PC" as ETC_PC,
        p."EC_NB_G_PC" as EC_NB_G_PC,
        p."EC_NB_T_PC" as EC_NB_T_PC,
        p."EC_NB_P_PC" as EC_NB_P_PC,
        p."EAC_PC" as EAC_PC,
        p."ETC_CE" as ETC_CE,
        p."EC_CE_PC" as EC_CE_PC,
        p."ETC_R_PA" as ETC_R_PA,
        p."ETC_A_PE" as ETC_A_PE,
        p."ETC_F_A_PE" as ETC_F_A_PE,
        p."EC_TG_PA_E" as EC_TG_PA_E,
        p."EC_B_TG_PA_E" as EC_B_TG_PA_E,
        p."EC_TT_PA_E" as EC_TT_PA_E,
        p."EC_B_TT_PA_E" as EC_B_TT_PA_E,
        p."EC_TP_PA_E" as EC_TP_PA_E,
        p."EC_B_TP_PA_E" as EC_B_TP_PA_E,
        p."EAC_PA_E" as EAC_PA_E
    from tmp_parcoursup2024 p
    join etablissement e on p."Code_UAI" = e.id
    join formation f on f.nom = p."Filiere_formation_Detaillee"
       and f.etablissement_id = e.id

    union all

    select
        f.id as formation_id,
        p2."Annee" as annee,
        p2."ET_C" as ET_C,
        p2."ET_CF" as ET_CF,
        p2."ET_C_PP" as ET_C_PP,
        p2."EC_I" as EC_I,
        p2."EC_NB_G" as EC_NB_G,
        p2."EC_B_NB_G" as EC_B_NB_G,
        p2."EC_NB_T" as EC_NB_T,
        p2."EC_B_NB_T" as EC_B_NB_T,
        p2."EC_NB_P" as EC_NB_P,
        p2."EC_B_NB" as EC_B_NB,
        p2."EC_AC" as EC_AC,
        p2."ETC_PC" as ETC_PC,
        p2."EC_NB_G_PC" as EC_NB_G_PC,
        p2."EC_NB_T_PC" as EC_NB_T_PC,
        p2."EC_NB_P_PC" as EC_NB_P_PC,
        p2."EAC_PC" as EAC_PC,
        p2."ETC_CE" as ETC_CE,
        p2."EC_CE_PC" as EC_CE_PC,
        p2."ETC_R_PA" as ETC_R_PA,
        null::INT as ETC_A_PE,
        null::INT as ETC_F_A_PE,
        null::INT as EC_TG_PA_E,
        null::INT as EC_B_TG_PA_E,
        null::INT as EC_TT_PA_E,
        null::INT as EC_B_TT_PA_E,
        null::INT as EC_TP_PA_E,
        null::INT as EC_B_TP_PA_E,
        null::INT as EAC_PA_E
    from tmp_parcoursup2018 p2
    join etablissement e on p2."Code_UAI" = e.id
    join formation f on f.nom = p2."Filiere_formation_detaillee"
       and f.etablissement_id = e.id
) t
group by formation_id, annee;




-- Création de la table admission
CREATE TABLE admissions (
    id SERIAL PRIMARY KEY,
    formation_id INT NOT NULL REFERENCES formation(id),
    annee INT NOT NULL,
    EA_PC INT, 
    EA_I INT, 
    EA_BN_B INT, 
    EA_NB INT, 
    EA_NB_G INT, 
    EA_NB_T INT, 
    EA_NB_P INT, 
    EA_AC INT, 
    EA_NB_SI INT, 
    EA_NB_SM INT, 
    EA_NB_AB INT, 
    EA_NB_B INT, 
    EA_NB_TB INT, 
    EA_NB_TBF INT, 
    EA_NB_G_M INT, 
    EA_NB_T_M INT, 
    EA_NB_P_M INT, 
    EA_NB_IME INT, 
    EA_F_IME INT, 
    EA_IMA INT, 
    EA_IMA_PCV INT, 
    PA_AB INT,
    PA_AF_PP INT, 
    PA_F INT,
    PA_NB_IMA INT, 
    PA_NB_IMA_PCV INT, 
    PA_NB_IME INT, 
    PA_NB_B INT, 
    PA_NB INT, 
    PA_NB_SI_MB INT, 
    PA_NB_SM INT, 
    PA_NB_AB INT, 
    PA_NB_B_MB INT, 
    PA_NB_TB INT, 
    PA_NB_TB_F INT, 
    PA_NB_G INT, 
    PA_M_BG INT, 
    PA_NB_T INT, 
    PA_M_BT INT, 
    PA_NB_P INT, 
    PA_M_BP INT,
    CONSTRAINT admissions_unique
        UNIQUE (formation_id, annee)
);



-- Supprimer les données de la table afin de s'assurer qu'elle existe et qu'elle est vierge de données 


truncate table admissions;

-- Insérer les données cibles dans la table. 

-- Insérer les données cibles dans la table admissions

insert into admissions(
    formation_id,
    annee,
    EA_PC, 
    EA_I, 
    EA_BN_B, 
    EA_NB, 
    EA_NB_G, 
    EA_NB_T, 
    EA_NB_P, 
    EA_AC, 
    EA_NB_SI, 
    EA_NB_SM, 
    EA_NB_AB, 
    EA_NB_B, 
    EA_NB_TB, 
    EA_NB_TBF, 
    EA_NB_G_M, 
    EA_NB_T_M, 
    EA_NB_P_M, 
    EA_NB_IME, 
    EA_F_IME, 
    EA_IMA, 
    EA_IMA_PCV, 
    PA_AB,
    PA_AF_PP,
    PA_F, 
    PA_NB_IMA, 
    PA_NB_IMA_PCV, 
    PA_NB_IME, 
    PA_NB_B, 
    PA_NB, 
    PA_NB_SI_MB, 
    PA_NB_SM, 
    PA_NB_AB, 
    PA_NB_B_MB, 
    PA_NB_TB, 
    PA_NB_TB_F, 
    PA_NB_G, 
    PA_M_BG, 
    PA_NB_T, 
    PA_M_BT, 
    PA_NB_P, 
    PA_M_BP
)
select
    formation_id,
    annee,
    MAX(EA_PC) as EA_PC,
    MAX(EA_I) as EA_I,
    MAX(EA_BN_B) as EA_BN_B,
    MAX(EA_NB) as EA_NB,
    MAX(EA_NB_G) as EA_NB_G,
    MAX(EA_NB_T) as EA_NB_T,
    MAX(EA_NB_P) as EA_NB_P,
    MAX(EA_AC) as EA_AC,
    MAX(EA_NB_SI) as EA_NB_SI,
    MAX(EA_NB_SM) as EA_NB_SM,
    MAX(EA_NB_AB) as EA_NB_AB,
    MAX(EA_NB_B) as EA_NB_B,
    MAX(EA_NB_TB) as EA_NB_TB,
    MAX(EA_NB_TBF) as EA_NB_TBF,
    MAX(EA_NB_G_M) as EA_NB_G_M,
    MAX(EA_NB_T_M) as EA_NB_T_M,
    MAX(EA_NB_P_M) as EA_NB_P_M,
    MAX(EA_NB_IME) as EA_NB_IME,
    MAX(EA_F_IME) as EA_F_IME,
    MAX(EA_IMA) as EA_IMA,
    MAX(EA_IMA_PCV) as EA_IMA_PCV,
    MAX(PA_AB) as PA_AB,
    MAX(PA_AF_PP) as PA_AF_PP,
    MAX(PA_F) as PA_F,
    MAX(PA_NB_IMA) as PA_NB_IMA,
    MAX(PA_NB_IMA_PCV) as PA_NB_IMA_PCV,
    MAX(PA_NB_IME) as PA_NB_IME,
    MAX(PA_NB_B) as PA_NB_B,
    MAX(PA_NB) as PA_NB,
    MAX(PA_NB_SI_MB) as PA_NB_SI_MB,
    MAX(PA_NB_SM) as PA_NB_SM,
    MAX(PA_NB_AB) as PA_NB_AB,
    MAX(PA_NB_B_MB) as PA_NB_B_MB,
    MAX(PA_NB_TB) as PA_NB_TB,
    MAX(PA_NB_TB_F) as PA_NB_TB_F,
    MAX(PA_NB_G) as PA_NB_G,
    MAX(PA_M_BG) as PA_M_BG,
    MAX(PA_NB_T) as PA_NB_T,
    MAX(PA_M_BT) as PA_M_BT,
    MAX(PA_NB_P) as PA_NB_P,
    MAX(PA_M_BP) as PA_M_BP
from (
    select
        f.id as formation_id,
        p."Annee" as annee,
        p."EA_PC" as EA_PC,
        p."EA_I" as EA_I,
        p."EA_BN_B" as EA_BN_B,
        p."EA_NB" as EA_NB,
        p."EA_NB_G" as EA_NB_G,
        p."EA_NB_T" as EA_NB_T,
        p."EA_NB_P" as EA_NB_P,
        p."EA_AC" as EA_AC,
        p."EA_NB_SI" as EA_NB_SI,
        p."EA_NB_SM" as EA_NB_SM,
        p."EA_NB_AB" as EA_NB_AB,
        p."EA_NB_B" as EA_NB_B,
        p."EA_NB_TB" as EA_NB_TB,
        p."EA_NB_TBF" as EA_NB_TBF,
        p."EA_NB_G_M" as EA_NB_G_M,
        p."EA_NB_T_M" as EA_NB_T_M,
        p."EA_NB_P_M" as EA_NB_P_M,
        p."EA_NB_IME" as EA_NB_IME,
        p."EA_F_IME" as EA_F_IME,
        p."EA_IMA" as EA_IMA,
        p."EA_IMA_PCV" as EA_IMA_PCV,
        p."PA_AB" as PA_AB,
        p."PA_AF_PP" as PA_AF_PP,
        p."PA_F" as PA_F,
        p."PA_NB_IMA" as PA_NB_IMA,
        p."PA_NB_IMA_PCV" as PA_NB_IMA_PCV,
        p."PA_NB_IME" as PA_NB_IME,
        p."PA_NB_B" as PA_NB_B,
        p."PA_NB" as PA_NB,
        p."PA_NB_SI_MB" as PA_NB_SI_MB,
        p."PA_NB_SM" as PA_NB_SM,
        p."PA_NB_AB" as PA_NB_AB,
        p."PA_NB_B_MB" as PA_NB_B_MB,
        p."PA_NB_TB" as PA_NB_TB,
        p."PA_NB_TB_F" as PA_NB_TB_F,
        p."PA_NB_G" as PA_NB_G,
        p."PA_M_BG" as PA_M_BG,
        p."PA_NB_T" as PA_NB_T,
        p."PA_M_BT" as PA_M_BT,
        p."PA_NB_P" as PA_NB_P,
        p."PA_M_BP" as PA_M_BP
    from tmp_parcoursup2024 p
    join etablissement e on p."Code_UAI" = e.id
    join formation f on f.nom = p."Filiere_formation_Detaillee"
       and f.etablissement_id = e.id

    union all

    select
        f.id as formation_id,
        p2."Annee" as annee,
        p2."EA_PC" as EA_PC,
        p2."EA_I" as EA_I,
        p2."EA_BN_B" as EA_BN_B,
        p2."EA_NB" as EA_NB,
        p2."EA_NB_G" as EA_NB_G,
        p2."EA_NB_T" as EA_NB_T,
        p2."EA_NB_P" as EA_NB_P,
        p2."EA_AC" as EA_AC,
        p2."EA_NB_SI" as EA_NB_SI,
        p2."EA_NB_SM" as EA_NB_SM,
        p2."EA_NB_AB" as EA_NB_AB,
        p2."EA_NB_B" as EA_NB_B,
        p2."EA_NB_TB" as EA_NB_TB,
        null::int as EA_NB_TBF,
        p2."EA_NB_G_M" as EA_NB_G_M,
        p2."EA_NB_T_M" as EA_NB_T_M,
        p2."EA_NB_P_M" as EA_NB_P_M,
        p2."EA_NB_IME" as EA_NB_IME,
        p2."EA_F_IME" as EA_F_IME,
        p2."EA_IMA" as EA_IMA,
        p2."EA_IMA_PCV" as EA_IMA_PCV,
        null::int as PA_AB,
        null::int as PA_AF_PP,
        p2."PA_F" as PA_F,
        p2."PA_NB_IMA" as PA_NB_IMA,
        p2."PA_NB_IMA_PCV" as PA_NB_IMA_PCV,
        p2."PA_NB_IME" as PA_NB_IME,
        p2."PA_NB_B" as PA_NB_B,
        p2."PA_NB" as PA_NB,
        p2."PA_NB_SI_MB" as PA_NB_SI_MB,
        null::int as PA_NB_SM,
        p2."PA_NB_AB" as PA_NB_AB,
        p2."PA_NB_B_MB" as PA_NB_B_MB,
        p2."PA_NB_TB" as PA_NB_TB,
        null::int as PA_NB_TB_F,
        p2."PA_NB_G" as PA_NB_G,
        null::int as PA_M_BG,
        p2."PA_NB_T" as PA_NB_T,
        p2."PA_M_BT" as PA_M_BT,
        p2."PA_NB_P" as PA_NB_P,
        p2."PA_M_BP" as PA_M_BP
    from tmp_parcoursup2018 p2
    join etablissement e on p2."Code_UAI" = e.id
    join formation f on f.nom = p2."Filiere_formation_detaillee"
       and f.etablissement_id = e.id
) t
group by formation_id, annee;



-- Fin de la transaction.
COMMIT;