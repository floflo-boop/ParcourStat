-- Début de la transaction
BEGIN;

-- Toujours utiliser le même schéma
SET search_path TO "Test";


/* 

Après examen de notre jeu de donnée, nous avons remarqué qu'entre 2018 et 2024 certains établissements changent de noms ou alors tout simplement leurs saisie change.
La problématique réside dans le Code_UAI. Il ne change pas et sans normalisation on aurait deux valeurs pour un même code UAI. 

Nous avons donc pensé cette requête afin de normaliser les noms des établissements communs aux deux jeux de données et cela dans nos tables temporaires. 

Le script ce base sur le Code_UAI. Si il repère le même Code_UAI avec deux valeurs différentes dans la colonne "Etablissement" alors il normalise 
en appliquant au jeu de donnée 2018 la valeur de 2024. 


De cette manière, nous facilitons l'insertion des données dans les tables définitives par la suite et réduisons les conflits de clés primaire? 





Nous avons également pensé cette requête pour résoudre un second problème : les code_UAI à valeur "identifiant obsolète" de 2018. 
29 établissements en 2018 présentent en Code_UAI 'identifiant obsolète' ce qui aurait posé problème pour la clés primaire.

Ainsi nous avons pensé la seconde requête qui se base sur les coordonnées GPS. Si des enregistrements ont les même coordonnées GPS 
entre 2018 et 2024 mais des valeurs différentes dans Etablissement et Code_UAI, ce sont tout de même les mêmes.
Applique le même principe que précédemment, il normalise selon la graphie de 2024.

Après de multiples vérifications basé sur de multiples critères, ces établissement ne semblent pas avoir leurs équivalent strict en 2024. 
Ne pouvons donc pas croiser les données, nous avons décidé d'effacer dans nos tables temporaires ces données. 
Mais nous laissons la seconde requête comme un cran de sûreté quant à l'efficacité de la première requête.

*/




-- Requête une : normalisation des noms d'établissement sur graphie de 2024 et selon correspondance Code_UAI
UPDATE tmp_parcoursup2018 AS tp1
SET "Etablissement" = tp2."Etablissement" -- On remplace la valeur de "Etablissement" dans tmp_parcoursup2018 par celle de 2024
FROM tmp_parcoursup2024 AS tp2
WHERE tp1."Code_UAI" = tp2."Code_UAI" -- Sur la base de la correspondance entre les code UAI 2018 et 2024
  AND tp1."Etablissement" != tp2."Etablissement" -- On change la valeur que si il y a une différence 
  AND tp2."Code_UAI" IS NOT NULL  -- On change la valeur uniquement si le code UAI n'est pas null 
  AND TRIM(tp2."Code_UAI") != '' -- Que si la valeur n'est pas vide 
  AND LOWER(TRIM(tp2."Code_UAI")) != 'identifiant obsolète'; -- Que si la valeur n'est pas 'identifiant obsolète'. De toute manière, on en a pas en 2024.


-- Requête deux : normalisation des codes UAI et noms d'établissements selon correspondance GPS avec priorité à la graphie de 2024. 
UPDATE tmp_parcoursup2018 AS tp1
SET 
    "Etablissement" = tp2."Etablissement", -- On remplace les valeurs "Etablissement" et "Code_UAI" en 2018 par celles de 2024 
    "Code_UAI" = tp2."Code_UAI"
FROM tmp_parcoursup2024 AS tp2
WHERE tp1."Coordonnees_gps_formation" = tp2."Coordonnees_gps_formation" -- Sur correspondance des données GPS
  AND (tp1."Code_UAI" IS NULL -- Même critère que la requête précédente. Il faut que le Code_UAI soit valide.
       OR TRIM(tp1."Code_UAI") = '' 
       OR LOWER(TRIM(tp1."Code_UAI")) = 'identifiant obsolète')
  AND tp2."Code_UAI" IS NOT NULL 
  AND TRIM(tp2."Code_UAI") != ''
  AND LOWER(TRIM(tp2."Code_UAI")) != 'identifiant obsolète'
  AND tp2."Coordonnees_gps_formation" IS NOT NULL -- Même critère que la requête précédente mais appliquées aux coordonénes GPS.
  AND TRIM(tp2."Coordonnees_gps_formation") != ''
  AND tp1."Coordonnees_gps_formation" IS NOT NULL 
  AND TRIM(tp1."Coordonnees_gps_formation") != '';


-- On fait un processes similaire pour les Académies entre 2018 et 2024. 

/* Nous avons remarqué des changements d'Académie entre 2018 et 2024. Par exemple pour un établissement en Normandie présent en 2018 et 2024

Il peut avoir en 2018 l'académie de Rouen et en 2024 l'académie de Normandie. Pour notre table établissement, cela poserait problème. 

Ainsi nous allons normaliser les données. Si un établissement présente une telle différence, alors il y aura normalisation en faisant primé la valeur de 2024. 

*/

UPDATE tmp_parcoursup2018 tp1
SET "Academie_etablissement" = tp2."Academie_etablissement"
FROM tmp_parcoursup2024 tp2
WHERE tp1."Code_UAI" = tp2."Code_UAI"
  AND tp1."Academie_etablissement" != tp2."Academie_etablissement";



-- Fin de la transaction 
COMMIT;