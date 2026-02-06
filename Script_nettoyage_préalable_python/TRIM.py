import pandas as pd
import os

# Liste des chemins des fichiers CSV
csv_paths = [
    '/home/florian/Desktop/Base_de_donnée_ParcourStat/Application/csv/parcoursup2018.csv',
    '/home/florian/Desktop/Base_de_donnée_ParcourStat/Application/csv/parcoursup2024.csv'
]

# Chemins des scripts SQL de sortie
SQL_script = "/home/florian/.local/share/DBeaverData/workspace6/General/Scripts/2_script_trim_tables.sql"
app_script = "/home/florian/Desktop/Base_de_donnée_ParcourStat/Application/sql/2_script_trim_tables.sql"

def generate_sql_trim(csv_path):
    """Génère une requête SQL UPDATE pour trimmer toutes les colonnes de type texte d'une table."""
    # Chargement du CSV pour obtenir les noms des colonnes
    csv_charge = pd.read_csv(csv_path, sep=";", nrows=0)  # On ne lit que les noms de colonnes
    cols = csv_charge.columns
    nom_fichier = os.path.splitext(os.path.basename(csv_path))[0]

    # Génération des lignes UPDATE
    update_lignes = []
    for col in cols:
        update_lignes.append(f'\t"{col}" = TRIM("{col}")')

    update_part = ",\n".join(update_lignes)

    # Construction de la requête SQL UPDATE
    sql_query = f"""
-- Trim des données de la table {nom_fichier}
UPDATE ParcourStat.{nom_fichier}
SET
    {update_part};
"""
    return sql_query

def write_sql_script(file_path, csv_paths):
    """Écrit le script SQL complet avec une transaction unique."""
    with open(file_path, "w", encoding="utf-8") as fichier:
        fichier.write("""
-- Début de la transaction
BEGIN;

-- Toujours utiliser le même schéma
SET search_path TO ParcourStat;

""")
        for csv_path in csv_paths:
            fichier.write(generate_sql_trim(csv_path) + "\n\n")

        fichier.write("""
COMMIT;
""")

# Écriture des scripts SQL
write_sql_script(SQL_script, csv_paths)
write_sql_script(app_script, csv_paths)

print(f"Les requêtes SQL de trimming ont été exportées dans {SQL_script} et {app_script}.")
