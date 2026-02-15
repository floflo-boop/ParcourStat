-- Ce script permet la destruction automatique des tables ayant servi à la construction de la Base de donnée.

BEGIN; 

drop table parcoursup2018;

drop table parcoursup2024;

drop table wikidata;

drop table tmp_parcoursup2018;

drop table tmp_parcoursup2024;

COMMIt;