import pandas as pd
import os

"""
Ce script permet de générer une requête SQL de création de table temporaire à partir de plusieurs fichiers CSV.
Il suffit de lui donner en entrée les chemins des CSV, et le script créera en sortie une requête pré-remplie.
L'utilisateur n'a plus qu'à modifier certains éléments comme les TYPES de chaque colonne et les NOMS de chaque colonne si besoin.

Comme nous avons plus de 80 colonnes par CSV, cela permet d'accélérer la saisie.

Définition des variables :
    - csv_paths : liste des chemins vers les fichiers CSV.
    - csv_charge : chargement du CSV à l'aide de pd.read_csv.
    - cols : liste des noms des colonnes du CSV.
    - nom_fichier : nom du fichier CSV chargé.

La fonction generate_sql_create_table génère la requête SQL pour chaque fichier CSV.
"""

# Liste des chemins des fichiers CSV
csv_paths = [
    '/home/florian/ParcourStat/Application/csv/parcoursup2018.csv',
    '/home/florian/ParcourStat/Application/csv/parcoursup2024.csv'
]

# Chemins des scripts SQL de sortie
SQL_script = "/home/florian/.local/share/DBeaverData/workspace6/General/Scripts/1_script_tables_de_travail.sql"
app_script = "/home/florian/Desktop/ParcourStat/Application/sql/1_script_tables_de_travail.sql"


def initcap(text):
    if not text:
        return text
    return ' '.join(word.capitalize() for word in text.split())


def generate_sql_create_table(csv_path):
    """Génère une requête SQL CREATE TABLE pour un fichier CSV donné."""
    # Chargement du CSV
    csv_charge = pd.read_csv(csv_path, sep=";")
    cols = csv_charge.columns
    nom_fichier = os.path.splitext(os.path.basename(csv_path))[0]
    string = ["Code_UAI_etablissement", "Etablissement", "Departement_etablissement", "Region_etablissement", "Commune_etablissement",
    "Academie_etablissement", "Filiere_formation_tres_agregee", "Filiere_formation", "Concours_communs_et_banques_epreuves", 
    "Filiere_formation_detaillee", "Filiere_formation_tres_detaillee", "Lien_formation_plateforme_Parcoursup", 
    "Coordonnees_GPS_formation", "tri", "Statut_etablissement_filiere_formation_public_prive", "Selectivite", 
    "Filiere_formation_detaillee_bis", "Regroupement_1_effectue_par_formations_pour_classements",
    "Regroupement_2_effectue_par_formations_pour_classements", "Regroupement_3_effectue_par_formations_pour_classements",
    "list_com", "tri", "Concours_communs_et_banque_epreuves", "Lien_formation_plateforme_Parcoursup",
    "etablissement_id_paysage", "composante_id_paysage", "Filiere_formation_1"]

    # Génération des lignes SELECT
    cast_lignes = []
    for col in cols:
        formatted_col_name = initcap(col).replace(" ", "_")
        if col not in string : 
            cast_lignes.append(f'\tCAST("{col}" as INT) as "{formatted_col_name}"')
        else : 
            cast_lignes.append(f'\tTRIM("{col}") as "{formatted_col_name}"')

    select_part = ",\n".join(cast_lignes)

    # Construction de la requête SQL
    sql_query = f"""
CREATE TABLE TMP_{nom_fichier} AS (
SELECT
    {select_part}
FROM
    "Test".{nom_fichier}
);
"""
    return sql_query

def write_sql_script(file_path, csv_paths):
    """Écrit le script SQL complet avec une transaction unique."""
    with open(file_path, "w", encoding="utf-8") as fichier:
        fichier.write("""
-- Début de la transaction
BEGIN;

-- Toujours utiliser le même schéma
SET search_path TO parcourStat_schema;

""")
        for csv_path in csv_paths:
            fichier.write(generate_sql_create_table(csv_path) + "\n")

        fichier.write("""
COMMIT;
""")

# Écriture des scripts SQL
write_sql_script(SQL_script, csv_paths)
write_sql_script(app_script, csv_paths)

print(f"Les requêtes SQL ont été exportées dans {SQL_script} et {app_script}.")
