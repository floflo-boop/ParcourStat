import pandas as pd
import os

"""
Ce script permet de générer une requête SQL de création de table Temporaire à partir de 3 csv. 
Il suffit de lui donner en entrée 3 CSV et le script créera en sortie une requête pré remplie. 
L'utilisateur n'a plus qu'à modifier certains éléments comme les TYPES de chaque colonne et les NOMS de chaque colonne si il le souhaite.

Comme nous avons plus de 80 colonnes par CSV, cela permet d'accélérer la saisie.

    Définition de 4 variables : 
        - chemin vers le fichier csv sur lequel écrire la requête SQL
        - chargement du csv à l'aide de pd.read_csv
        - liste les noms des colonnes CSV
        - nom du fichier csv chargé.

Ensuite création d'une fonction generate_sql_create_table qui va concrétement générer la requête. 

    - Génére chaque ligne de code SQL pour créer une colonne en reprenant le nom de la colonne CSV. Laisse une marge de saisie manuelle.
    - Assemble les lignes en les séparant par une "," et un retour à la ligne
    - Créer la requête complète.
    - Exporter la requête dans un fichier SQL localisé dans DBeaver directement pour exploitation.

Dans DBeaver, penser à faire un clique droit sur le dossier "script" et "rafraîchir" afin de faire apparaître le script.
"""

# Liste des chemins des fichiers CSV
csv_paths = [
    '/home/florian/Desktop/groupe_4/csv_non_modifié/Parcoursup_2018_normalise.csv',
    '/home/florian/Desktop/groupe_4/csv_non_modifié/Parcoursup_2024_normalise.csv'
]

# Chemins des scripts SQL de sortie
SQL_script = "/home/florian/.local/share/DBeaverData/workspace6/General/Scripts/1_script_tables_de_travail.sql"
app_script = "/home/florian/Desktop/Base_de_donnée_ParcourStat/Application/sql/1_script_tables_de_travail.sql"


def generate_sql_create_table(csv_chemin):
    # Chargement du CSV
    csv_charge = pd.read_csv(csv_chemin, sep=";")
    cols = csv_charge.columns
    nom_fichier = os.path.splitext(os.path.basename(csv_chemin))[0]

    # Génération des lignes SELECT
    cast_lignes = []
    for col in cols:
        safe_col = col.replace("'", "''")
        cast_lignes.append(f'"{safe_col}" as "{safe_col.upper()}"')

    select_part = ",\n".join(cast_lignes)

    # Construction de la requête SQL
    sql_query = f"""CREATE TABLE TMP_{nom_fichier} AS (
SELECT
{select_part}
FROM {nom_fichier}
);
"""

    return sql_query + "\n"


# Écriture du script SQL dans DBeaver
with open(SQL_script, "w", encoding="utf-8") as fichier:
    for csv_path in csv_paths:
        fichier.write(generate_sql_create_table(csv_path))

# Écriture du script SQL pour l'application
with open(app_script, "w", encoding="utf-8") as fichier:
    for csv_path in csv_paths:
        fichier.write(generate_sql_create_table(csv_path))

print(f"Les requêtes SQL ont été exportées dans {SQL_script} et {app_script}.")
