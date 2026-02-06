BEGIN;


CREATE TABLE "Test".region (
    id SERIAL PRIMARY KEY,
    nom VARCHAR(1000) NOT NULL UNIQUE
);


CREATE TABLE "Test".departement (
  Id SERIAL PRIMARY KEY,
  Code TEXT NOT NULL UNIQUE,
  Nom TEXT NOT NULL,
  Region_id INT NOT NULL REFERENCES region(id)
);

CREATE TABLE "Test".commune (
  id SERIAL PRIMARY KEY,
  nom TEXT NOT NULL,
  departement_id INT NOT NULL REFERENCES departement(id)
);


CREATE TABLE "Test".academie (
  id SERIAL PRIMARY KEY,
  nom TEXT NOT NULL UNIQUE
);


CREATE TABLE "Test".etablissement (
  id SERIAL PRIMARY KEY,
  nom TEXT NOT NULL,
  statut TEXT,
  commune_id INT NOT NULL REFERENCES commune(id),
  academie_id INT NOT NULL REFERENCES academie(id)
);

CREATE TABLE "Test".discipline (
  id SERIAL PRIMARY KEY,
  nom TEXT NOT NULL UNIQUE,
  categorie TEXT,
  type TEXT
);

CREATE TABLE "Test".type_formation (
 id SERIAL PRIMARY KEY,
 nom TEXT NOT NULL UNIQUE
);


CREATE TABLE "Test".formation (
  id SERIAL PRIMARY KEY,
  nom TEXT NOT NULL,
  etablissement_id INT NOT NULL REFERENCES etablissement(id),
  type_formation_id INT NOT NULL REFERENCES type_formation(id),
  selectivite TEXT,
  geolocalisation TEXT,
  identifiant_parcoursup TEXT UNIQUE,
  Annee INT NOT NULL 
);

CREATE TABLE candidatures AS (
    id SERIAL PRIMARY KEY,
    formation_id INT NOT NULL  REFERENCES formation(id),
    Annee INT NOT NULL,
    Effectif_total_candidats_formation INT,
    Dont_candidates_formation INT,
    Effectif_total_candidats_phase_principale INT,
    Candidats_terminale_générale_phase principale INT,
    Dont_candidats_boursiers_terminale_générale_phase_principale INT,
    Effectif_candidats_néo_terminale_technologique_phase_principale INT,
    Dont_candidats_boursiers_terminale_technologique_phase_principale INT,
    Effectif_candidats_néo_bacheliers_terminale_professionnelle_phase principale INT,
    Dont_candidats_boursiers_néo_bacheliers_terminale_professionnelle_phase_principale INT,
    Effectif_autres_candidats_phase_principale INT,
    Effectif_total_candidats_phase_complémentaire INT,
    Effectif_candidats_terminale_générale_phase_complémentaire INT,
    Effectif_candidats_terminale_technologique_en_phase_complémentaire INT,
    Effectif_candidats_terminale_professionnelle_phase_complémentaire INT,
    Effectif_autres_candidats_phase_complémentaire INT,
    Effectif_candidats_avec_proposition_admission_etablissement INT,
    Effectif_candidats_terminale_générale_avec_proposition_admission INT,
    Dont_candidats_boursiers_terminale_générale_avec_proposition_admission INT,
    Effectif_candidats_terminale_technologique_avec_proposition_admission INT,
    Dont_candidats_boursiers_terminale_technologique_avec_proposition_admission INT,
    Effectif_candidats_terminale_professionnelle_avec_proposition_admission INT,
    Dont_candidats_boursiers_terminale_professionnelle_avec_proposition_admission INT,
    Effectif_autres_candidats_avec_proposition_admission INT,
    Effectif_candidats_acceptant_proposition_établissement (admis) INT,
    Dont_effectif_candidates_admises INT,
);


COMMIT;