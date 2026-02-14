
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
	CAST("ET_C" as INT) as "Et_c",
	CAST("ET_CP" as INT) as "Et_cp",
	CAST("ET_C_PP" as INT) as "Et_c_pp",
	CAST("EC_I" as INT) as "Ec_i",
	CAST("EC_NB_G" as INT) as "Ec_nb_g",
	CAST("EC_B_NB_G" as INT) as "Ec_b_nb_g",
	CAST("EC_NB_T" as INT) as "Ec_nb_t",
	CAST("EC_B_NB_T" as INT) as "Ec_b_nb_t",
	CAST("EC_NB_P" as INT) as "Ec_nb_p",
	CAST("EC_B_NB" as INT) as "Ec_b_nb",
	CAST("EC_AC" as INT) as "Ec_ac",
	CAST("ETC_PC" as INT) as "Etc_pc",
	CAST("EC_NB_G_PC" as INT) as "Ec_nb_g_pc",
	CAST("EC_NB_T_PC" as INT) as "Ec_nb_t_pc",
	CAST("EC_NB_P_PC" as INT) as "Ec_nb_p_pc",
	CAST("EAC_PC" as INT) as "Eac_pc",
	CAST("ETC_CE" as INT) as "Etc_ce",
	CAST("EC_CE_PC" as INT) as "Ec_ce_pc",
	CAST("EC_CE_I" as INT) as "Ec_ce_i",
	CAST("EFC_CE_HI" as INT) as "Efc_ce_hi",
	CAST("EC_NBG_CE" as INT) as "Ec_nbg_ce",
	CAST("EC_B_NB_CE" as INT) as "Ec_b_nb_ce",
	CAST("EC_NB_T_CE" as INT) as "Ec_nb_t_ce",
	CAST("EC_B_NB_T_CE" as INT) as "Ec_b_nb_t_ce",
	CAST("EC_NBP_CE" as INT) as "Ec_nbp_ce",
	CAST("EC_B_NB_P_CE" as INT) as "Ec_b_nb_p_ce",
	CAST("EC_AC_CE" as INT) as "Ec_ac_ce",
	CAST("ETC_R_PA" as INT) as "Etc_r_pa",
	CAST("Rang_dernier_appele" as INT) as "Rang_dernier_appele",
	CAST("ETC_A_PPE" as INT) as "Etc_a_ppe",
	CAST("EC_A" as INT) as "Ec_a",
	CAST("EA_PP" as INT) as "Ea_pp",
	CAST("EA_PC" as INT) as "Ea_pc",
	CAST("EA_I" as INT) as "Ea_i",
	CAST("EA_BN_B" as INT) as "Ea_bn_b",
	CAST("EA_NB" as INT) as "Ea_nb",
	CAST("EA_NB_G" as INT) as "Ea_nb_g",
	CAST("EA_NB_T" as INT) as "Ea_nb_t",
	CAST("EA_NB_P" as INT) as "Ea_nb_p",
	CAST("EA_AC" as INT) as "Ea_ac",
	CAST("EA_NB_SI" as INT) as "Ea_nb_si",
	CAST("EA_NB_SM" as INT) as "Ea_nb_sm",
	CAST("EA_NB_AB" as INT) as "Ea_nb_ab",
	CAST("EA_NB_B" as INT) as "Ea_nb_b",
	CAST("EA_NB_TB" as INT) as "Ea_nb_tb",
	CAST("EA_NB_G_M" as INT) as "Ea_nb_g_m",
	CAST("EA_NB_T_M" as INT) as "Ea_nb_t_m",
	CAST("EA_NB_P_M" as INT) as "Ea_nb_p_m",
	CAST("EA_NB_IME" as INT) as "Ea_nb_ime",
	CAST("EA_F_IME" as INT) as "Ea_f_ime",
	CAST("EA_IMA" as INT) as "Ea_ima",
	CAST("EA_IMA_PCV" as INT) as "Ea_ima_pcv",
	CAST("PA_F" as INT) as "Pa_f",
	CAST("PA_NB_IMA" as INT) as "Pa_nb_ima",
	CAST("PA_NB_IMA_PCV" as INT) as "Pa_nb_ima_pcv",
	CAST("PA_NB_IME" as INT) as "Pa_nb_ime",
	CAST("PA_NB_B" as INT) as "Pa_nb_b",
	CAST("PA_NB" as INT) as "Pa_nb",
	CAST("PA_NB_SI_MB" as INT) as "Pa_nb_si_mb",
	CAST("PA_NB_SM_B" as INT) as "Pa_nb_sm_b",
	CAST("PA_NB_AB" as INT) as "Pa_nb_ab",
	CAST("PA_NB_B_MB" as INT) as "Pa_nb_b_mb", -- Changement : cette colonne concerne les néo bacheliers avec mention bien. Rajout de 'MB' pour mention bien.
	CAST("PA_NB_TB" as INT) as "Pa_nb_tb",
	CAST("PA_NB_G" as INT) as "Pa_nb_g",
	CAST("PA_M" as INT) as "Pa_m",
	CAST("PA_NB_T" as INT) as "Pa_nb_t",
	CAST("PA_M_BT" as INT) as "Pa_m_bt",
	CAST("PA_NB_P" as INT) as "Pa_nb_p",
	CAST("PA_M_BP" as INT) as "Pa_m_bp",
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
	CAST("ET_C" as INT) as "Et_c",
	CAST("ET_CF" as INT) as "Et_cf",
	CAST("ET_C_PP" as INT) as "Et_c_pp",
	CAST("EC_I" as INT) as "Ec_i",
	CAST("EC_NB_G" as INT) as "Ec_nb_g",
	CAST("EC_B_NB_G" as INT) as "Ec_b_nb_g",
	CAST("EC_NB_T" as INT) as "Ec_nb_t",
	CAST("EC_B_NB_T" as INT) as "Ec_b_nb_t",
	CAST("EC_NB_P" as INT) as "Ec_nb_p",
	CAST("EC_B_NB" as INT) as "Ec_b_nb",
	CAST("EC_AC" as INT) as "Ec_ac",
	CAST("ETC_PC" as INT) as "Etc_pc",
	CAST("EC_NB_G_PC" as INT) as "Ec_nb_g_pc",
	CAST("EC_NB_T_PC" as INT) as "Ec_nb_t_pc",
	CAST("EC_NB_P_PC" as INT) as "Ec_nb_p_pc",
	CAST("EAC_PC" as INT) as "Eac_pc",
	CAST("ETC_CE" as INT) as "Etc_ce",
	CAST("EC_CE_PC" as INT) as "Ec_ce_pc",
	CAST("EC_CE_I" as INT) as "Ec_ce_i",
	CAST("EFC_CE_HI" as INT) as "Efc_ce_hi",
	CAST("EC_NB_CE" as INT) as "Ec_nb_ce",
	CAST("EC_B_NB_CE" as INT) as "Ec_b_nb_ce",
	CAST("EC_NB_T_CE" as INT) as "Ec_nb_t_ce",
	CAST("EC_B_NB_T_CE" as INT) as "Ec_b_nb_t_ce",
	CAST("EC_NB_P_CE" as INT) as "Ec_nb_p_ce",
	CAST("EC_B_NB_P_CE" as INT) as "Ec_b_nb_p_ce",
	CAST("EC_AC_CE" as INT) as "Ec_ac_ce",
	CAST("ETC_R_PA" as INT) as "Etc_r_pa",
	CAST("ETC_A_PE" as INT) as "Etc_a_pe",
	CAST("ETC_F_A_PE" as INT) as "Etc_f_a_pe",
	CAST("EA_PP" as INT) as "Ea_pp",
	CAST("EA_PC" as INT) as "Ea_pc",
	CAST("EA_PA_OP" as INT) as "Ea_pa_op",
	CAST("EA_PA_AB" as INT) as "Ea_pa_ab",
	CAST("EA_PA_PP" as INT) as "Ea_pa_pp",
	CAST("EA_I" as INT) as "Ea_i",
	CAST("EA_BN_B" as INT) as "Ea_bn_b",
	CAST("EA_NB" as INT) as "Ea_nb",
	CAST("EA_NB_G" as INT) as "Ea_nb_g",
	CAST("EA_NB_T" as INT) as "Ea_nb_t",
	CAST("EA_NB_P" as INT) as "Ea_nb_p",
	CAST("EA_AC" as INT) as "Ea_ac",
	CAST("EA_NB_SI" as INT) as "Ea_nb_si",
	CAST("EA_NB_SM" as INT) as "Ea_nb_sm",
	CAST("EA_NB_AB" as INT) as "Ea_nb_ab",
	CAST("EA_NB_B" as INT) as "Ea_nb_b",
	CAST("EA_NB_TB" as INT) as "Ea_nb_tb",
	CAST("EA_NB_TBF" as INT) as "Ea_nb_tbf",
	CAST("EA_NB_G_M" as INT) as "Ea_nb_g_m",
	CAST("EA_NB_T_M" as INT) as "Ea_nb_t_m",
	CAST("EA_NB_P_M" as INT) as "Ea_nb_p_m",
	CAST("EA_NB_IME" as INT) as "Ea_nb_ime",
	CAST("EA_F_IME" as INT) as "Ea_f_ime",
	CAST("EA_IMA" as INT) as "Ea_ima",
	CAST("EA_IMA_PCV" as INT) as "Ea_ima_pcv",
	CAST("PA_OP_PP" as INT) as "Pa_op_pp",
	CAST("PA_AB" as INT) as "Pa_ab",
	CAST("PA_AF_PP" as INT) as "Pa_af_pp",
	CAST("PA_F" as INT) as "Pa_f",
	CAST("PA_NB_IMA" as INT) as "Pa_nb_ima",
	CAST("PA_NB_IMA_PCV" as INT) as "Pa_nb_ima_pcv",
	CAST("PA_NB_IME" as INT) as "Pa_nb_ime",
	CAST("PA_NB_B" as INT) as "Pa_nb_b",
	CAST("PA_NB" as INT) as "Pa_nb",
	CAST("PA_NB_SI_MB" as INT) as "Pa_nb_si_mb",
	CAST("PA_NB_SM" as INT) as "Pa_nb_sm",
	CAST("PA_NB_AB" as INT) as "Pa_nb_ab",
	CAST("PA_NB_B_MB" as INT) as "Pa_nb_b_mb", -- Changement : cette colonne concerne les néo bacheliers boursiers avec mention bien. Rajout de 'MB' pour mention bien.
	CAST("PA_NB_TB" as INT) as "Pa_nb_tb",
	CAST("PA_NB_TB_F" as INT) as "Pa_nb_tb_f",
	CAST("PA_NB_G" as INT) as "Pa_nb_g",
	CAST("PA_M_BG" as INT) as "Pa_m_bg",
	CAST("PA_NB_T" as INT) as "Pa_nb_t",
	CAST("PA_M_BT" as INT) as "Pa_m_bt",
	CAST("PA_NB_P" as INT) as "Pa_nb_p",
	CAST("PA_M_BP" as INT) as "Pa_m_bp",
	CAST("EC_TG_PA_E" as INT) as "Ec_tg_pa_e",
	CAST("EC_B_TG_PA_E" as INT) as "Ec_b_tg_pa_e",
	CAST("Effectif des candidats en terminale technologique ayant reçu une proposition d’admission de la part de l’établissement" as INT) as "Effectif_Des_Candidats_En_Terminale_Technologique_Ayant_Reçu_Une_Proposition_D’admission_De_La_Part_De_L’établissement",
	CAST("EC_B_TT_PA_E" as INT) as "Ec_b_tt_pa_e",
	CAST("EC_TP_PA_E" as INT) as "Ec_tp_pa_e",
	CAST("EC_B_TP_PA_E" as INT) as "Ec_b_tp_pa_e",
	CAST("EAC_PA_E" as INT) as "Eac_pa_e",
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
