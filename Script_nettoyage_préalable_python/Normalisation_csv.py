import pandas as pd
import unicodedata
import re

def normaliser_nom_colonne(nom):
    nom = str(nom)
    mots_parasites = ['d\'', 'l\'', 'le', 'la', 'les', 'de', 'des', 'du', 'en', 'sur', 'avec', 'ayant', 'eu', 'une', 'au', 'bac']
    for mot in mots_parasites:
        nom = re.sub(r'\b' + re.escape(mot) + r'\b', '', nom, flags=re.IGNORECASE)
    nom = re.sub(r'\s+', ' ', nom).strip()
    nom = nom.replace(" ", "_")
    nom = nom.replace("'", "_")
    nom = unicodedata.normalize('NFKD', nom).encode('ascii', 'ignore').decode('ascii')
    nom = ''.join(c if c.isalnum() or c == '_' or c == '%' else '_' for c in nom)
    nom = re.sub(r'_+', '_', nom).strip('_')
    nom = nom.replace("letablissement", "etablissement").replace("dadmis", "admis")
    nom = nom.replace("%", "pourcentage")
    return nom

def renommer_colonnes_avec_numerotation(df):
    colonnes = df.columns.tolist()
    nouvelles_colonnes = []
    compteur_effectif = 0
    compteur_dont = {}

    for col in colonnes:
        col_normalisee = normaliser_nom_colonne(col)
        if col_normalisee.startswith("Effectif"):
            compteur_effectif += 1
            nouvelles_colonnes.append(f"{compteur_effectif}_{col_normalisee}")
            compteur_dont[compteur_effectif] = 0
        elif col_normalisee.startswith("Dont") :
            if compteur_effectif in compteur_dont:
                compteur_dont[compteur_effectif] += 1
                nouvelles_colonnes.append(f"{compteur_effectif}_{compteur_dont[compteur_effectif]}_{col_normalisee}")
            else:
                nouvelles_colonnes.append(col_normalisee)
        else:
            nouvelles_colonnes.append(col_normalisee)

    df.columns = nouvelles_colonnes
    return df

csv_files = [
    '/home/florian/Desktop/groupe_4/csv_non_modifié/Parcoursup_2018.csv',
    '/home/florian/Desktop/groupe_4/csv_non_modifié/Parcoursup_2024.csv'
]

for fichier in csv_files:
    try:
        df = pd.read_csv(fichier, sep=';', encoding='utf-8', engine='python')
        df = renommer_colonnes_avec_numerotation(df)
        nom_fichier_sortie = fichier.replace('.csv', '_normalise.csv')
        df.to_csv(nom_fichier_sortie, index=False, sep=';')
        print(f"Fichier {fichier} traité avec succès.")
    except Exception as e:
        print(f"Erreur lors du traitement du fichier {fichier} : {e}")
