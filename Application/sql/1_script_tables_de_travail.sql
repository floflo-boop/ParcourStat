
-- Début de la transaction
BEGIN;

CREATE SCHEMA IF NOT EXISTS "ParcourStat";

-- Toujours utiliser le même schéma
SET search_path TO "ParcourStat";

-- Création de la table temporaire parcoursup2018 et transformation des données : suppression des espaces et normalisation

CREATE TABLE TMP_parcoursup2018 AS (
SELECT
    CAST("Annee" as INT) as "Annee",
	TRIM("Code_UAI") as "Code_UAI",
	TRIM("Etablissement") as "Etablissement",
	CASE
        WHEN TRIM(INITCAP("Departement_etablissement")) = 'Corse-Du-Sud' THEN '2A'
        ELSE TRIM(CAST("Code_departemental_etablissement" as VARCHAR(100)))
    END AS "Code_departemental_etablissement",
	CASE 
		WHEN TRIM(INITCAP("Departement_etablissement")) = 'Corse Du Sud' THEN 'Corse-Du-Sud'
		ELSE TRIM(INITCAP("Departement_etablissement"))
	END AS "Departement_etablissement",
	CASE
        WHEN TRIM("Region_etablissement") = 'Auvergne-Rhône-Alpes' THEN 'Auvergne-Rhône-Alpes'
        WHEN TRIM("Region_etablissement") = 'Bourgogne-Franche-Comté' THEN 'Bourgogne-Franche-Comté'
        WHEN TRIM("Region_etablissement") = 'Bretagne' THEN 'Bretagne'
        WHEN TRIM("Region_etablissement") = 'Centre-Val de Loire' THEN 'Centre-Val-de-Loire'
		WHEN TRIM("Region_etablissement") = 'Centre' THEN 'Centre-Val-de-Loire'
        WHEN TRIM("Region_etablissement") = 'Grand Est' THEN 'Grand-Est'
        WHEN TRIM("Region_etablissement") = 'Hauts-de-France' THEN 'Hauts-de-France'
        WHEN TRIM("Region_etablissement") = 'Île-de-France' THEN 'Île-de-France'
        WHEN TRIM("Region_etablissement") = 'Normandie' THEN 'Normandie'
        WHEN TRIM("Region_etablissement") = 'Nouvelle Aquitaine' THEN 'Nouvelle-Aquitaine'
        WHEN TRIM("Region_etablissement") = 'Occitanie' THEN 'Occitanie'
        WHEN TRIM("Region_etablissement") = 'Pays de la Loire' THEN 'Pays-de-la-Loire'
        WHEN TRIM("Region_etablissement") = 'Provence Alpes Côte d''Azur' THEN 'Provence-Alpes-Côte-d''Azur'
        WHEN TRIM("Region_etablissement") = 'Guadeloupe' THEN 'Guadeloupe'
        WHEN TRIM("Region_etablissement") = 'Martinique' THEN 'Martinique'
        WHEN TRIM("Region_etablissement") = 'Guyane' THEN 'Guyane'
        WHEN TRIM("Region_etablissement") = 'Mayotte' THEN 'Mayotte'
		WHEN TRIM("Academie_etablissement") = 'Etranger' THEN 'Etranger'
		WHEN TRIM("Academie_etablissement") = 'Polynésie Française' THEN 'Polynésie Française'
        ELSE TRIM("Region_etablissement")
    END as "Region_etablissement" ,
	TRIM("Academie_etablissement") as "Academie_etablissement",
	TRIM("Filiere_formation_tres_agregee") as "Filiere_formation_tres_agregee",
	TRIM("Filiere_formation") as "Filiere_formation",
	TRIM("Concours_communs_banques_epreuves") as "Concours_communs_banques_epreuves",
	TRIM("Filiere_formation_detaillee") as "Filiere_formation_detaillee",
	TRIM("Filiere_formation_tres_detaillee") as "Filiere_formation_tres_detaillee",
	TRIM("Lien_formation_Parcoursup") as "Lien_formation_parcoursup",
	TRIM("Coordonnees_GPS_formation") as "Coordonnees_gps_formation",
	CAST("Capacite_etablissement_formation" as INT) as "Capacite_etablissement_formation",
	CAST("ET_C" as INT) as "ET_C",
	CAST("ET_CF" as INT) as "ET_CF",
	CAST("ET_CP" as INT) as "ET_CP",
	CAST("ET_C_PP" as INT) as "ET_C_PP",
	CAST("EC_I" as INT) as "EC_I",
	CAST("EC_NB_G" as INT) as "EC_NB_G",
	CAST("EC_B_NB_G" as INT) as "EC_B_NB_G",
	CAST("EC_NB_T" as INT) as "EC_NB_T",
	CAST("EC_B_NB_T" as INT) as "EC_B_NB_T",
	CAST("EC_NB_P" as INT) as "EC_NB_P",
	CAST("EC_B_NB" as INT) as "EC_B_NB",
	CAST("EC_AC" as INT) as "EC_AC",
	CAST("ETC_PC" as INT) as "ETC_PC",
	CAST("EC_NB_G_PC" as INT) as "EC_NB_G_PC",
	CAST("EC_NB_T_PC" as INT) as "EC_NB_T_PC",
	CAST("EC_NB_P_PC" as INT) as "EC_NB_P_PC",
	CAST("EAC_PC" as INT) as "EAC_PC",
	CAST("ETC_CE" as INT) as "ETC_CE",
	CAST("EC_CE_PC" as INT) as "EC_CE_PC",
	CAST("EC_CE_I" as INT) as "EC_CE_I",
	CAST("EFC_CE_HI" as INT) as "EFC_CE_HI",
	CAST("EC_NBG_CE" as INT) as "EC_NBG_CE",
	CAST("EC_B_NB_CE" as INT) as "EC_B_NB_CE",
	CAST("EC_NB_T_CE" as INT) as "EC_NB_T_CE",
	CAST("EC_B_NB_T_CE" as INT) as "EC_B_NB_T_CE",
	CAST("EC_NBP_CE" as INT) as "EC_NBP_CE",
	CAST("EC_B_NB_P_CE" as INT) as "EC_B_NB_P_CE",
	CAST("EC_AC_CE" as INT) as "EC_AC_CE",
	CAST("ETC_R_PA" as INT) as "ETC_R_PA",
	CAST("Rang_dernier_appele" as INT) as "Rang_dernier_appele",
	CAST("ETC_A_PE" as INT) as "ETC_A_PE",
	CAST("EC_A" as INT) as "EC_A",
	CAST("EA_PP" as INT) as "EA_PP",
	CAST("EA_PC" as INT) as "EA_PC",
	CAST("EA_I" as INT) as "EA_I",
	CAST("EA_BN_B" as INT) as "EA_BN_B",
	CAST("EA_NB" as INT) as "EA_NB",
	CAST("EA_NB_G" as INT) as "EA_NB_G",
	CAST("EA_NB_T" as INT) as "EA_NB_T",
	CAST("EA_NB_P" as INT) as "EA_NB_P",
	CAST("EA_AC" as INT) as "EA_AC",
	CAST("EA_NB_SI" as INT) as "EA_NB_SI",
	CAST("EA_NB_SM" as INT) as "EA_NB_SM",
	CAST("EA_NB_AB" as INT) as "EA_NB_AB",
	CAST("EA_NB_B" as INT) as "EA_NB_B",
	CAST("EA_NB_TB" as INT) as "EA_NB_TB",
	CAST("EA_NB_G_M" as INT) as "EA_NB_G_M",
	CAST("EA_NB_T_M" as INT) as "EA_NB_T_M",
	CAST("EA_NB_P_M" as INT) as "EA_NB_P_M",
	CAST("EA_NB_IME" as INT) as "EA_NB_IME",
	CAST("EA_F_IME" as INT) as "EA_F_IME",
	CAST("EA_IMA" as INT) as "EA_IMA",
	CAST("EA_IMA_PCV" as INT) as "EA_IMA_PCV",
	CAST("PA_F" as INT) as "PA_F",
	CAST("PA_NB_IMA" as INT) as "PA_NB_IMA",
	CAST("PA_NB_IMA_PCV" as INT) as "PA_NB_IMA_PCV",
	CAST("PA_NB_IME" as INT) as "PA_NB_IME",
	CAST("PA_NB_B" as INT) as "PA_NB_B",
	CAST("PA_NB" as INT) as "PA_NB",
	CAST("PA_NB_SI_MB" as INT) as "PA_NB_SI_MB",
	CAST("PA_NB_SM_B" as INT) as "PA_NB_SM_B",
	CAST("PA_NB_AB" as INT) as "PA_NB_AB",
	CAST("PA_NB_B_MB" as INT) as "PA_NB_B_MB", -- CHANGEMENT concerne les néo bacheliers avec mention bien. Rajout de MB pour mention bien.
	CAST("PA_NB_TB" as INT) as "PA_NB_TB",
	CAST("PA_NB_G" as INT) as "PA_NB_G",
	CAST("PA_M" as INT) as "PA_M",
	CAST("PA_NB_T" as INT) as "PA_NB_T",
	CAST("PA_M_BT" as INT) as "PA_M_BT",
	CAST("PA_NB_P" as INT) as "PA_NB_P",
	CAST("PA_M_BP" as INT) as "PA_M_BP",
	TRIM("tri") as "Tri"
FROM
    parcoursup2018
);




-- Création de la table temporaire parcourusp2024 et transformation des données : suppression des espaces et normalisation


CREATE TABLE TMP_parcoursup2024 AS (
SELECT
    CAST("Annee" as INT) as "Annee",
	TRIM("Statut_etablissement_filière_formation") as "Statut_etablissement_filière_formation",
	TRIM("Code_UAI") as "Code_UAI",
	CASE 
		WHEN TRIM("Etablissement") = '3il' THEN '3IL'
		ELSE TRIM(INITCAP("Etablissement"))	
	END AS "Etablissement",
	CASE 
		WHEN TRIM(INITCAP("Departement_etablissement")) = 'Corse-Du-Sud' then '2A'
		WHEN TRIM(INITCAP("Departement_etablissement")) = 'Haute-Corse' then '2B'
		WHEN TRIM("Commune_etablissement") = 'Sarrola-Carcopino' THEN '2A'
        WHEN TRIM("Commune_etablissement") = 'Borgo' THEN '2B'
		ELSE TRIM(CAST("Code_departemental_etablissement" as VARCHAR(100)))
	END AS "Code_departemental_etablissement",
	CASE 
		WHEN TRIM("Commune_etablissement") = 'Sarrola-Carcopino' THEN 'Corse-Du-Sud'
        WHEN TRIM("Commune_etablissement") = 'Borgo' THEN 'Haute-Corse'
		WHEN TRIM(INITCAP("Departement_etablissement")) = 'Corse Du Sud' THEN 'Corse-Du-Sud'
		ELSE TRIM(INITCAP("Departement_etablissement"))
	END AS "Departement_etablissement",
    CASE
        WHEN TRIM("Region_etablissement") = 'Auvergne-Rhône-Alpes' THEN 'Auvergne-Rhône-Alpes'
        WHEN TRIM("Region_etablissement") = 'Bourgogne-Franche-Comté' THEN 'Bourgogne-Franche-Comté'
        WHEN TRIM("Region_etablissement") = 'Bretagne' THEN 'Bretagne'
        WHEN TRIM("Region_etablissement") = 'Centre-Val de Loire' THEN 'Centre-Val-de-Loire'
		WHEN TRIM("Region_etablissement") = 'Centre' THEN 'Centre-Val-de-Loire'
        WHEN TRIM("Region_etablissement") = 'Grand Est' THEN 'Grand-Est'
        WHEN TRIM("Region_etablissement") = 'Hauts-de-France' THEN 'Hauts-de-France'
        WHEN TRIM("Region_etablissement") = 'Île-de-France' THEN 'Île-de-France'
        WHEN TRIM("Region_etablissement") = 'Normandie' THEN 'Normandie'
        WHEN TRIM("Region_etablissement") = 'Nouvelle Aquitaine' THEN 'Nouvelle-Aquitaine'
        WHEN TRIM("Region_etablissement") = 'Occitanie' THEN 'Occitanie'
        WHEN TRIM("Region_etablissement") = 'Pays de la Loire' THEN 'Pays-de-la-Loire'
        WHEN TRIM("Region_etablissement") = 'Provence-Alpes-Côte d''Azur' THEN 'Provence-Alpes-Côte-d''Azur'
        WHEN TRIM("Region_etablissement") = 'Guadeloupe' THEN 'Guadeloupe'
        WHEN TRIM("Region_etablissement") = 'Martinique' THEN 'Martinique'
        WHEN TRIM("Region_etablissement") = 'Guyane' THEN 'Guyane'
		WHEN TRIM("Region_etablissement") = 'Réunion' THEN 'La Réunion' 
        WHEN TRIM("Region_etablissement") = 'Mayotte' THEN 'Mayotte'
		WHEN TRIM("Academie_etablissement") = 'Etranger' THEN 'Etranger'
		WHEN TRIM("Academie_etablissement") = 'Polynésie Française' THEN 'Polynésie Française'
        ELSE TRIM("Region_etablissement")
    END as "Region_etablissement" ,
	TRIM("Academie_etablissement") as "Academie_etablissement",
	TRIM("Commune_etablissement") as "Commune_etablissement",
	TRIM("Filiere_formation") as "Filiere_formation",
	cast(case
		when "Selectivite" = 'formation sélective' then true
		else false
	end as BOOLEAN) as "Selectivite",
	TRIM("Filiere_formation_tres_agregee") as "Filiere_formation_tres_agregee",
	TRIM("Filiere_formation detaillee") as "Filiere_formation_Detaillee",
	TRIM("Filiere_formation_agregee") as "Filiere_formation_agregee", -- Changement : renommage de "Filiere_formation" dans le CSV d'origine en "Filiere_formation_agregee" en raison d'un doublon avec le précédent (juste avant le précédent case) et version agrégée de ce dernier.
	TRIM("Filiere_formation_detaillee_bis") as "Filiere_formation_detaillee_bis",
	TRIM("Filiere_formation_détaillée") as "Filiere_formation_détaillée",
	TRIM("Coordonnees_GPS_formation") as "Coordonnees_gps_formation",
	CAST("Capacite_etablissement_formation" as INT) as "Capacite_etablissement_formation",
	CAST("ET_C" as INT) as "ET_C",
	CAST("ET_CF" as INT) as "ET_CF",
	CAST("ET_C_PP" as INT) as "ET_C_PP",
	CAST("EC_I" as INT) as "EC_I",
	CAST("EC_NB_G" as INT) as "EC_NB_G",
	CAST("EC_B_NB_G" as INT) as "EC_B_NB_G",
	CAST("EC_NB_T" as INT) as "EC_NB_T",
	CAST("EC_B_NB_T" as INT) as "EC_B_NB_T",
	CAST("EC_NB_P" as INT) as "EC_NB_P",
	CAST("EC_B_NB" as INT) as "EC_B_NB",
	CAST("EC_AC" as INT) as "EC_AC",
	CAST("ETC_PC" as INT) as "ETC_PC",
	CAST("EC_NB_G_PC" as INT) as "EC_NB_G_PC",
	CAST("EC_NB_T_PC" as INT) as "EC_NB_T_PC",
	CAST("EC_NB_P_PC" as INT) as "EC_NB_P_PC",
	CAST("EAC_PC" as INT) as "EAC_PC",
	CAST("ETC_CE" as INT) as "ETC_CE",
	CAST("EC_CE_PC" as INT) as "EC_CE_PC",
	CAST("EC_CE_I" as INT) as "EC_CE_I",
	CAST("EFC_CE_HI" as INT) as "EFC_CE_HI",
	CAST("EC_NB_CE" as INT) as "EC_NB_CE",
	CAST("EC_B_NB_CE" as INT) as "EC_B_NB_CE",
	CAST("EC_NB_T_CE" as INT) as "EC_NB_T_CE",
	CAST("EC_B_NB_T_CE" as INT) as "EC_B_NB_T_CE",
	CAST("EC_NB_P_CE" as INT) as "EC_NB_P_CE",
	CAST("EC_B_NB_P_CE" as INT) as "EC_B_NB_P_CE",
	CAST("EC_AC_CE" as INT) as "EC_AC_CE",
	CAST("ETC_R_PA" as INT) as "ETC_R_PA",
	CAST("ETC_A_PE" as INT) as "ETC_A_PE",
	CAST("ETC_F_A_PE" as INT) as "ETC_F_A_PE",
	CAST("EA_PP" as INT) as "EA_PP",
	CAST("EA_PC" as INT) as "EA_PC",
	CAST("EA_PA_OP" as INT) as "EA_PA_OP",
	CAST("EA_PA_AB" as INT) as "EA_PA_AB",
	CAST("EA_PA_PP" as INT) as "EA_PA_PP",
	CAST("EA_I" as INT) as "EA_I",
	CAST("EA_BN_B" as INT) as "EA_BN_B",
	CAST("EA_NB" as INT) as "EA_NB",
	CAST("EA_NB_G" as INT) as "EA_NB_G",
	CAST("EA_NB_T" as INT) as "EA_NB_T",
	CAST("EA_NB_P" as INT) as "EA_NB_P",
	CAST("EA_AC" as INT) as "EA_AC",
	CAST("EA_NB_SI" as INT) as "EA_NB_SI",
	CAST("EA_NB_SM" as INT) as "EA_NB_SM",
	CAST("EA_NB_AB" as INT) as "EA_NB_AB",
	CAST("EA_NB_B" as INT) as "EA_NB_B",
	CAST("EA_NB_TB" as INT) as "EA_NB_TB",
	CAST("EA_NB_TBF" as INT) as "EA_NB_TBF",
	CAST("EA_NB_G_M" as INT) as "EA_NB_G_M",
	CAST("EA_NB_T_M" as INT) as "EA_NB_T_M",
	CAST("EA_NB_P_M" as INT) as "EA_NB_P_M",
	CAST("EA_NB_IME" as INT) as "EA_NB_IME",
	CAST("EA_F_IME" as INT) as "EA_F_IME",
	CAST("EA_IMA" as INT) as "EA_IMA",
	CAST("EA_IMA_PCV" as INT) as "EA_IMA_PCV",
	CAST("PA_OP_PP" as INT) as "PA_OP_PP",
	CAST("PA_AB" as INT) as "PA_AB",
	CAST("PA_AF_PP" as INT) as "PA_AF_PP",
	CAST("PA_F" as INT) as "PA_F",
	CAST("PA_NB_IMA" as INT) as "PA_NB_IMA",
	CAST("PA_NB_IMA_PCV" as INT) as "PA_NB_IMA_PCV",
	CAST("PA_NB_IME" as INT) as "PA_NB_IME",
	CAST("PA_NB_B" as INT) as "PA_NB_B",
	CAST("PA_NB" as INT) as "PA_NB",
	CAST("PA_NB_SI_MB" as INT) as "PA_NB_SI_MB",
	CAST("PA_NB_SM" as INT) as "PA_NB_SM",
	CAST("PA_NB_AB" as INT) as "PA_NB_AB",
	CAST("PA_NB_B_MB" as INT) as "PA_NB_B_MB", -- Changement : cette colonne concerne les néo bacheliers boursiers avec mention bien. Rajout de 'MB' pour mention bien.
	CAST("PA_NB_TB" as INT) as "PA_NB_TB",
	CAST("PA_NB_TB_F" as INT) as "PA_NB_TB_F",
	CAST("PA_NB_G" as INT) as "PA_NB_G",
	CAST("PA_M_BG" as INT) as "PA_M_BG",
	CAST("PA_NB_T" as INT) as "PA_NB_T",
	CAST("PA_M_BT" as INT) as "PA_M_BT",
	CAST("PA_NB_P" as INT) as "PA_NB_P",
	CAST("PA_M_BP" as INT) as "PA_M_BP",
	CAST("EC_TG_PA_E" as INT) as "EC_TG_PA_E",
	CAST("EC_B_TG_PA_E" as INT) as "EC_B_TG_PA_E",
	CAST("EC_TT_PA_E" as INT) as "EC_TT_PA_E",
	CAST("EC_B_TT_PA_E" as INT) as "EC_B_TT_PA_E",
	CAST("EC_TP_PA_E" as INT) as "EC_TP_PA_E",
	CAST("EC_B_TP_PA_E" as INT) as "EC_B_TP_PA_E",
	CAST("EAC_PA_E" as INT) as "EAC_PA_E",
	TRIM("Regroupement_1_par_formations_pour_classements") as "Regroupement_1_par_formations_pour_classements",
	CAST("Rang_dernier_appele_groupe 1" as INT) as "Rang_dernier_appele_groupe_1",
	TRIM("Regroupement_2_par_formations_pour_classements") as "Regroupement_2_par_formations_pour_classements",
	CAST("Rang_dernier_appele_groupe_2" as INT) as "Rang_dernier_appele_groupe_2",
	TRIM("Regroupement_3_par_formations_pour_classements") as "Regroupement_3_par_formations_pour_classements",
	CAST("Rang_dernier_appele_groupe_3" as INT) as "Rang_dernier_appele_groupe_3",
	TRIM("list_com") as "List_com",
	TRIM("tri") as "Tri",
	CAST("cod_aff_form" as INT) as "Cod_aff_form",
	TRIM("Concours_communs_banque_epreuves") as "Concours_communs_banque_epreuves",
	TRIM("Lien_formation_Parcoursup") as "Lien_formation_parcoursup",
	CAST("Taux_acces" as INT) as "Taux_acces",
	CAST("Part _terminales_generales_pouvant_recevoir_proposition_phase_principale" as INT) as "Part__terminales_generales_pouvant_recevoir_proposition_phase_principale",
	CAST("Part_terminales_technologiques_pouvant_recevoir_proposition_phase_principale" as INT) as "Part_terminales_technologiques_pouvant_recevoir_proposition_phase_principale",
	CAST("Part_ terminales_professionnelles_pouvant_recevoir_proposition_phase principale" as INT) as "Part__Terminales_professionnelles_pouvant_recevoir_proposition_phase_Principale",
	TRIM("etablissement_id_paysage") as "Etablissement_id_paysage",
	TRIM("composante_id_paysage") as "Composante_id_paysage"
FROM
    parcoursup2024
);



COMMIT;
