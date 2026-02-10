
-- Début de la transaction
BEGIN;

-- Toujours utiliser le même schéma
SET search_path TO "Test";



-- Création de la table temporaire de parcourusp2018 et transformation des données (suppression des espaces et normalisation)

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
	CAST("PA_NB_B.1" as INT) as "Pa_nb_b.1",
	CAST("PA_NB_TB" as INT) as "Pa_nb_tb",
	CAST("PA_NB_G" as INT) as "Pa_nb_g",
	CAST("PA_M" as INT) as "Pa_m",
	CAST("PA_NB_T" as INT) as "Pa_nb_t",
	CAST("PA_M_BT" as INT) as "Pa_m_bt",
	CAST("PA_NB_P" as INT) as "Pa_nb_p",
	CAST("PA_M_BP" as INT) as "Pa_m_bp",
	TRIM("tri") as "Tri"
FROM
    "Test".parcoursup2018
);


/*
Dans le cas où l'automatisation de la normalisation des noms d'établissement ne marche pas, compléter la requête manuellement.

""CASE
		WHEN TRIM("Code_UAI") = '0010059J' then 'Lycée d''enseignement général, technique et professionnel agricole de Cibeins'
		WHEN TRIM("Code_UAI") = '0011170S' then 'MFR de MONTLUEL'
		WHEN TRIM("Code_UAI") = '0020051V' then 'Lycée des métiers d''Art'
		WHEN TRIM("Code_UAI") = '0021522U' then 'Lycée agricole La Thierache'
		WHEN TRIM("Code_UAI") = '0022134J' then 'ELISA Aerospace Hauts de France'
		WHEN TRIM("Code_UAI") = '0030935A' then 'ES Vichy'
		WHEN TRIM("Code_UAI") = '0031060L' then 'I.U.T Clermont Auvergne - site de Moulins'
		WHEN TRIM("Code_UAI") = '0031092W' then 'I.U.T Clermont Auvergne - site de Vichy'
		WHEN TRIM("Code_UAI") = '0050005D' then 'Lycée Alpes et Durance - Lycée des Métiers de la construction bois et de l''énergie.'
		WHEN TRIM("Code_UAI") = '0050607H' then 'Aix-Marseille Université - Site de Gap'
		WHEN TRIM("Code_UAI") = '0060034E' then 'Lycée des Métiers - Hôtelier et Tourisme Jeanne et Paul Augier'
		WHEN TRIM("Code_UAI") = '0060793E' then 'Lycée Vert d''Azur Antibes'
		WHEN TRIM("Code_UAI") = '0060807V' then 'Université Côte d''Azur - UFR de Médecine'
		WHEN TRIM("Code_UAI") = '0061643D' then 'IDRAC Business School - Campus de Nice'
		WHEN TRIM("Code_UAI") = '0061691F' then 'Lycée Mélinée & Misssak Manouchian'
		WHEN TRIM("Code_UAI") = '0062104E' then 'CESI Campus de Nice'
		WHEN TRIM("Code_UAI") = '0071445H' then 'Centre de Ressources, d’Expertise et de Performance Sportive d’Auvergne Rhône-Alpes Vallon-Pont-d''Arc (CREPS)'
		WHEN TRIM("Code_UAI") = '0080010T' then 'Lycée professionnel Simone Veil'
		WHEN TRIM("Code_UAI") = '0101037Y' then 'Campus des Comtes de champagne - URCA'
		WHEN TRIM("Code_UAI") = '0120936C' then 'Site Villefr. de Rouergue du lycée François Marty'
		WHEN TRIM("Code_UAI") = '0130189K' then 'Centre de Ressources, d''Expertise et de Performance Sportive PACA - site d''Aix-en-Provence (CREPS)'
		WHEN TRIM("Code_UAI") = '0130235K' then 'Institut National des Formations Notariales.'
		WHEN TRIM("Code_UAI") = '0132972K' then 'Institut de formation de manipulateurs d''électroradiologie médicale - Laurent CHEVROT - Hôpitaux universitaires de Marseille'
		WHEN TRIM("Code_UAI") = '0133479L' then 'IUT Aix-Marseille - Site de Marseille Luminy'
		WHEN TRIM("Code_UAI") = '0133522H' then 'Aix-Marseille Université - Site d''Arles'
		WHEN TRIM("Code_UAI") = '0134003F' then 'NELSON MANDELA'
		WHEN TRIM("Code_UAI") = '0140052F' then 'Lycée Guillaume le Conquérant'
		WHEN TRIM("Code_UAI") = '0141234R' then 'IUT GRAND OUEST NORMANDIE - Pôle de Caen - Site de Caen'
		WHEN TRIM("Code_UAI") = '0142133T' then 'Lycée Dumont d''Urville Laplace'
		WHEN TRIM("Code_UAI") = '0142179T' then 'IUT GRAND OUEST NORMANDIE - Pôle de Caen - Site de Lisieux'
		WHEN TRIM("Code_UAI") = '0142182W' then 'Builders école d''ingénieurs'
		WHEN TRIM("Code_UAI") = '0142218K' then 'IUT GRAND OUEST NORMANDIE - Pôle de Caen - Site d''Ifs'
		WHEN TRIM("Code_UAI") = '0142257C' then 'IUT GRAND OUEST NORMANDIE - Pôle de Caen - Site de Vire'
		WHEN TRIM("Code_UAI") = '0150746E' then 'I.U.T Clermont Auvergne - site d''Aurillac'
		WHEN TRIM("Code_UAI") = '0161192J' then 'CESI Campus d’Angoulême (La couronne)'
		WHEN TRIM("Code_UAI") = '0170029P' then 'LPO Léonce Vieljeux'
		WHEN TRIM("Code_UAI") = '0170393K' then 'LYCEE DU CAMPUS DE L''ALIMENTATION ENILIA ENSMIC'
		WHEN TRIM("Code_UAI") = '0171463Y' then 'La Rochelle Université'
		WHEN TRIM("Code_UAI") = '0171623X' then 'CESI Campus de La Rochelle'
		WHEN TRIM("Code_UAI") = '0180585N' then 'Lycée agricole de Bourges - Le Subdray'
		WHEN TRIM("Code_UAI") = '0180860M' then 'Université d''Orléans - Centre Univ. de Bourges (Bourges)'
		WHEN TRIM("Code_UAI") = '0190071Z' then 'IBSAC (Ecole secondaire professionnelle privée)'
		WHEN TRIM("Code_UAI") = '0190244M' then 'Campus du Végétal du pays de Brive'
		WHEN TRIM("Code_UAI") = '0190609J' then 'Ecole Forestière de Meymac'
		WHEN TRIM("Code_UAI") = '0210032W' then 'Lycée des métiers de la céramique Henry Moisand'
		WHEN TRIM("Code_UAI") = '0212108C' then 'Polytech Dijon'
		WHEN TRIM("Code_UAI") = '0212198A' then 'L''institut Agro Dijon'
		WHEN TRIM("Code_UAI") = '0220102S' then 'Lycée Saint - Joseph - Bossuet'
		WHEN TRIM("Code_UAI") = '0220116G' then 'Lycée/Pôle supérieur Saint BRIEUC'
		WHEN TRIM("Code_UAI") = '0221031B' then 'Lycée agricole de Merdrignac'
		WHEN TRIM("Code_UAI") = '0240023V' then 'Lycée Agricole La Peyrouse'
		WHEN TRIM("Code_UAI") = '0251028G' then 'Institution Notre-Dame Saint-Jean - LYCEE'
		WHEN TRIM("Code_UAI") = '0251202W' then 'ENILEA-Lycée-campus Mamirolle'
		WHEN TRIM("Code_UAI") = '0251746M' then 'IRTS de Franche-Comté'
		WHEN TRIM("Code_UAI") = '0251763F' then 'IUT Nord Franche-Comté - Site de Montbéliard'
		WHEN TRIM("Code_UAI") = '0261097B' then 'MFR Anneyron'
		WHEN TRIM("Code_UAI") = '0261265J' then 'SYLVA CAMPUS'
		WHEN TRIM("Code_UAI") = '0261372A' then 'Université Grenoble Alpes - Antenne de Valence'
		WHEN TRIM("Code_UAI") = '0271070S' then 'Lycée polyvalent privé Notre-Dame Saint-François'
		WHEN TRIM("Code_UAI") = '0280706R' then 'Lycée agricole de Chartres - La Saussaye'
		WHEN TRIM("Code_UAI") = '0271677B' then 'Université de Rouen Normandie - Campus Evreux'
		WHEN TRIM("Code_UAI") = '0290181P' then 'Lycée Sup''Javouhey BREST'
		WHEN TRIM("Code_UAI") = '0291751W' then 'Lycée agricole Kerustum'
		WHEN TRIM("Code_UAI") = '0301376H' then 'Institut National des Formations Notariales de Nîmes'
		WHEN TRIM("Code_UAI") = '0310147S' then 'INSTITUT NATIONAL DES FORMATIONS NOTARIALES - Site de Toulouse'
		WHEN TRIM("Code_UAI") = '0312020C' then 'CESI Campus de Toulouse (Labège)'
		WHEN TRIM("Code_UAI") = '0312061X' then 'Lycée de la photographie - ETPA'
		WHEN TRIM("Code_UAI") = '0312390E' then 'Prépa T² Toulouse INP'
		WHEN TRIM("Code_UAI") = '0330119A' then 'Lycée Professionnel Jehan Duperier'
		WHEN TRIM("Code_UAI") = '0330159U' then 'Centre de Ressources, d''Expertise et de Performance Sportive de Bordeaux (CREPS)'
		WHEN TRIM("Code_UAI") = '0331495W' then 'Lycée Assomption Sainte Clotilde'
		WHEN TRIM("Code_UAI") = '0331498Z' then 'Lycée Le Mirail'
		WHEN TRIM("Code_UAI") = '0331683A' then 'Lycée Agricole et Forestier de Bazas'
		WHEN TRIM("Code_UAI") = '0332380H' then 'LPA Camille Godard'
		WHEN TRIM("Code_UAI") = '0332984P' then 'CESI Campus de Bordeaux'
		WHEN TRIM("Code_UAI") = '0333203C' then 'INFN - Institut National des Formations Notariales - Bordeaux'
		WHEN TRIM("Code_UAI") = '0333357V' then 'I.U.T de Bordeaux - Site de Gradignan'
		WHEN TRIM("Code_UAI") = '0333358W' then 'I.U.T. de Bordeaux - Site de Bordeaux-Bastide'
		WHEN TRIM("Code_UAI") = '0340023R' then 'Lycée René Gosse'
		WHEN TRIM("Code_UAI") = '0340838B' then 'I.U.T de Montpellier-Sète - site de Montpellier - campus Occitanie'
		WHEN TRIM("Code_UAI") = '0341089Z' then 'Université Paul Valery - Montpellier 3'
		WHEN TRIM("Code_UAI") = '0341267T' then 'IDRAC Business School - Campus de MONTPELLIER'
		WHEN TRIM("Code_UAI") = '0341470N' then 'Lycée Privé Agricole Vallée de l''Hérault'
		WHEN TRIM("Code_UAI") = '0341543T' then 'IFMEM Institut de formation de manipulateur d''électroradiologie médicale'
		WHEN TRIM("Code_UAI") = '0341956S' then 'CESI Campus de Montpellier (Mauguio)'
		WHEN TRIM("Code_UAI") = '0350709F' then 'Lycée des métiers La Champagne'
		WHEN TRIM("Code_UAI") = '0350795Z' then 'Lycée / Pôle Sup de La Salle - Groupe Saint Jean'
		WHEN TRIM("Code_UAI") = '0351047Y' then 'The Land'
		WHEN TRIM("Code_UAI") = '0351858E' then 'Institut de Formation de Manipulateurs d''Electroradiologie du CHU de Rennes (IFMEM)'
		WHEN TRIM("Code_UAI") = '0352305R' then 'RENNES SCHOOL OF BUSINESS'
		WHEN TRIM("Code_UAI") = '0352373P' then 'UniLaSalle Rennes'
		WHEN TRIM("Code_UAI") = '0352771X' then 'Institut Agro Rennes-Angers (Campus de Rennes)'
		WHEN TRIM("Code_UAI") = '0352824E' then 'ISEN Ouest Rennes'
		WHEN TRIM("Code_UAI") = '0360017Y' then 'Lycée agricole de l''Indre - Naturapolis'
		WHEN TRIM("Code_UAI") = '0360775X' then 'IUT de l''Indre'
		WHEN TRIM("Code_UAI") = '0360778A' then 'I.U.T de l''Indre'
		WHEN TRIM("Code_UAI") = '0370749N' then 'Campus Sainte Marguerite'
		WHEN TRIM("Code_UAI") = '0370770L' then 'I.U.T de Tours'
		WHEN TRIM("Code_UAI") = '0370800U' then 'Université de Tours'
		WHEN TRIM("Code_UAI") = '0371470X' then 'INSTITUT DE FORMATION DE TECHNICIENS DE LABORATOIRE MÉDICAL (IFTLM) SITE IFPS DU CHRU DE TOURS'
		WHEN TRIM("Code_UAI") = '0380272Z' then 'EGC Business School de Villefontaine'
		WHEN TRIM("Code_UAI") = '0382170C' then 'Lycée polyvalent SCHNEIDER ELECTRIC'
		WHEN TRIM("Code_UAI") = '0382371W' then 'Lycée Agricole Paul Claudel'
		WHEN TRIM("Code_UAI") = '0383208F' then 'Lycée PHILIPPINE DUCHESNE ITEC BOISFLEURY'
		WHEN TRIM("Code_UAI") = '0390033Z' then 'Lycée polyvalent Hyacinthe Friant - Lycée des métiers de l''hôtellerie, de la restauration et du sanitaire et du social'
		WHEN TRIM("Code_UAI") = '0390812W' then 'ENILEA-Lycée-campus Poligny'
		WHEN TRIM("Code_UAI") = '0391092A' then 'Lycée Paul Emile Victor- Lycée des métiers de la production et de la maintenance industrielles'
		WHEN TRIM("Code_UAI") = '0400004M' then 'Lycée des métiers de l''hôtellerie et du commerce Louis Darmante'
		WHEN TRIM("Code_UAI") = '0400934Y' then 'I.U.T des Pays de l''Adour - Antenne de Mont De Marsan'
		WHEN TRIM("Code_UAI") = '0410018X' then 'Lycée agricole - LEGTA de Vendôme'
		WHEN TRIM("Code_UAI") = '0410970G' then 'Université de Tours - Antenne de Blois'
		WHEN TRIM("Code_UAI") = '0420093Y' then 'ENISE Saint-Etienne'
		WHEN TRIM("Code_UAI") = '0422152L' then 'Université Jean Monnet - Campus de Roanne'
		WHEN TRIM("Code_UAI") = '0430951A' then 'I.U.T Clermont Auvergne - site du Puy'
		WHEN TRIM("Code_UAI") = '0440005S' then 'Lycée Polyvalent Guy Moquet - Etienne Lenoir'
		WHEN TRIM("Code_UAI") = '0440012Z' then 'Lycée général et technologique Grand Air'
		WHEN TRIM("Code_UAI") = '0440021J' then 'Lycée général Clemenceau'
		WHEN TRIM("Code_UAI") = '0440024M' then 'Lycée général Gabriel Guist''Hau'
		WHEN TRIM("Code_UAI") = '0440029T' then 'LGT Livet'
		WHEN TRIM("Code_UAI") = '0440030U' then 'Lycée Polyvalent Gaspard Monge - La Chauvinière'
		WHEN TRIM("Code_UAI") = '0440033X' then 'Lycée professionnel François Arago'
		WHEN TRIM("Code_UAI") = '0440063E' then 'Lycée professionnel Louis-Jacques Goussier'
		WHEN TRIM("Code_UAI") = '0440074S' then 'Lycée professionnel Brossaud-Blancho'
		WHEN TRIM("Code_UAI") = '0440086E' then 'Lycée général et technologique La Colinière'
		WHEN TRIM("Code_UAI") = '0440113J' then 'INSTITUT NATIONAL DES FORMATIONS NOTARIALES - Site de Nantes'
		WHEN TRIM("Code_UAI") = '0440172Y' then 'Lycée La Perverie Sacré-Coeur'
		WHEN TRIM("Code_UAI") = '' then ''
		WHEN TRIM("Code_UAI") = '' then ''
		WHEN TRIM("Code_UAI") = '' then ''
		WHEN TRIM("Code_UAI") = '' then ''
		WHEN TRIM("Code_UAI") = '' then ''
		WHEN TRIM("Code_UAI") = '' then ''
		WHEN TRIM("Code_UAI") = '' then ''
		WHEN TRIM("Code_UAI") = '' then ''
		WHEN TRIM("Code_UAI") = '' then ''
		WHEN TRIM("Code_UAI") = '' then ''
		WHEN TRIM("Code_UAI") = '' then ''
		ELSE TRIM("Etablissement")
	END AS "Etablissement",

*/


-- Création de la table temporaire de parcourusp2024 et transformation des données (suppression des espaces et normalisation)


CREATE TABLE TMP_parcoursup2024 AS (
SELECT
    CAST("Annee" as INT) as "Annee",
	TRIM("Statut_etablissement_filière_formation") as "Statut_etablissement_filière_formation",
	TRIM("Code_UAI") as "Code_UAI",
	TRIM("Etablissement") as "Etablissement",
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
	TRIM("Selectivite") as "Selectivite",
	TRIM("Filiere_formation_tres_agregee") as "Filiere_formation_tres_agregee",
	TRIM("Filiere_formation detaillee") as "Filiere_formation_Detaillee",
	TRIM("Filiere_formation.1") as "Filiere_formation.1",
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
	CAST("EC_NB_CE.1" as INT) as "Ec_nb_ce.1",
	CAST("EC_B_NB_P_CE" as INT) as "Ec_b_nb_p_ce",
	CAST("EC_AC_CE" as INT) as "Ec_ac_ce",
	CAST("ETC_R_PA" as INT) as "Etc_r_pa",
	CAST("ETC_A_PE" as INT) as "Etc_a_pe",
	CAST("EC_A" as INT) as "Ec_a",
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
	CAST("PA_NB_SM_B" as INT) as "Pa_nb_sm_b",
	CAST("PA_NB_AB" as INT) as "Pa_nb_ab",
	CAST("PA_NB_B.1" as INT) as "Pa_nb_b.1",
	CAST("PA_NB_TB" as INT) as "Pa_nb_tb",
	CAST("PA_NB_TB_F" as INT) as "Pa_nb_tb_f",
	CAST("PA_NB_G" as INT) as "Pa_nb_g",
	CAST("PA_M" as INT) as "Pa_m",
	CAST("PA_NB_T" as INT) as "Pa_nb_t",
	CAST("PA_M_BT" as INT) as "Pa_m_bt",
	CAST("PA_NB_P" as INT) as "Pa_nb_p",
	CAST("PA_M_BP" as INT) as "Pa_m_bp",
	CAST("EC_TM_PA_E" as INT) as "Ec_tm_pa_e",
	CAST("EC_B_TM_PA_E" as INT) as "Ec_b_tm_pa_e",
	CAST("Effectif des candidats en terminale technologique ayant reçu une proposition d’admission de la part de l’établissement" as INT) as "Effectif_Des_Candidats_En_Terminale_Technologique_Ayant_Reçu_Une_Proposition_D’admission_De_La_Part_De_L’établissement",
	CAST("EC_B_TT_PA_E" as INT) as "Ec_b_tt_pa_e",
	CAST("EC_TP_PA_E" as INT) as "Ec_tp_pa_e",
	CAST("EC_B_TGP_PA_E" as INT) as "Ec_b_tgp_pa_e",
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
    "Test".parcoursup2024
);



-- Mise à jour de la table tmp_2018 pour le cas des valeur "identifiant obsolète" de la colonne Code_UAI. Ils ont tous un Code UAI réel et fonctionnel en 2024. Cet UPDATE permet donc de normaliser cela.
-- Nécessaire afin d'éviter les doublons injustifié sur "identifiant obsolète" et permettre la normalisation des noms d'établissement.

UPDATE "Test".tmp_parcoursup2018 tp1
SET "Code_UAI" = tp2."Code_UAI"
FROM "Test".tmp_parcoursup2024 tp2
WHERE tp1."Etablissement" = tp2."Etablissement"
AND tp1."Code_UAI" = 'identifiant obsolète'
AND tp2."Code_UAI" != 'identifiant obsolète';



-- Le code UPDATE ne marche pas actuellement. Il n'y a pas de correspondance exact entre les noms des établissements 2018 et 2024 concerné

-- Demain, chercher les correspondances et normaliser les noms en se basant sur pacoursup 2024. Voir CSV créer à cet effet



COMMIT;
