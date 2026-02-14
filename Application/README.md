# ParcourStat - Base de données Parcoursup

## Description 
ParcourStat est une base de données relationnelle fondée sur PostgreSQL qui récupère et structure des données Parcoursup issues des sessions de 2024 et de 2018 tout en permettant de les comparer. Elle permet plus globalement une analyse de l'offre de formation de l'enseignement supérieur à l'aide de données issues des candidatures et des admissions des étudiants au sein des établissements. 

## Objectifs
Notre base de données a pour objectif de : 
- Structurer les données Parcoursup en un modèle logique de données
- Faciliter une comparaison entre les données de 2018 et 2024
- Permettre une lecture des données sur l'enseignement supérieur à travers des indicateurs géographiques
- Concrétiser l'enrichissement des données issues de wikidata pour les établissements
- Permettre l'élaboration future de datavisualisations et, à terme, d'une application Flask

## Source principale de données 
Notre base de données est fondée sur des données Parcoursup des sessions de 2018 et 2024, récupérées sous la forme de fichiers csv depuis le site du gouvernement français : 
- https://www.data.gouv.fr/datasets/parcoursup-2018-voeux-de-poursuite-detudes-et-de-reorientation-dans-lenseignement-superieur-et-reponses-des-etablissements 
- https://www.data.gouv.fr/datasets/parcoursup-2024-voeux-de-poursuite-detudes-et-de-reorientation-dans-lenseignement-superieur-et-reponses-des-etablissements 


## Croisement et enrichissement des données
Les données issues de Parcoursup ont été enrichies par des données sur les établissements requêtées depuis wikidata. Ainsi, les données suivantes sur les établissements ont été ajoutées  au sein de notre base de données :
- site web
- adresse 
- nombre d'étudiants
- logo
- image

## Architecture de la base de données 
Notre base de données compte 10 tables organisées comme suit : 

- Tables de données géographiques :
  - Académies  
  - Communes
  - Départements
  - Régions 

- Tables de données statistiques relatives aux étudiants : 
  - Candidatures
  - Admissions

Tables de données générales sur l'enseignement supérieur :
  - Disciplines
  - Formations
  - Type_formations
  - Etablissements


### Note sur les tables candidatures et admissions 
Les tables 'Candidatures' et 'Admissions' possèdent un nombre d'attributs assez conséquent. Toutefois, ces tables sont déjà issues d'une sélection effectuée depuis les csv d'origine, et contiennent donc uniquement les données que nous souhaitons conserver. La table 'Admissions' intègre notamment des calculs de pourcentage déjà effectués au sein des données originales, utiles à notre analyse.

### Contenu du dépôt 
Ce dépôt Github contient : 
- un dossier global 'Application'  
- un sous-dossier 'csv' avec trois fichiers csv : parcoursup2018, parcoursup2024, wikidata
- un sous-dossier 'sql' contenant trois scripts sql : un script de création des tables de travail, un script de normalisation des données, un script de création des tables définitives
- un fichier 'run.py' contenant un script python qui lance la création de la base de données 

## Installation de la base de données 
Pour installer notre base de données, il faut :
- Créer la base de données : 
CREATE DATABASE ParcourStat;
- Créer le schéma au sein de la base de données :
CREATE SCHEMA parcourstat;
- lancer la commande 'python run py' pour exécuter l'installation

## Auteurs 
- Florian Martin
- Solange Cussaguet
- Anaelle Martinez
- Clotilde Long




