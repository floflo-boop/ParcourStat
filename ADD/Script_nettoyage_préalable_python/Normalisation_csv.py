import pandas as pd
import unicodedata
import re

def normaliser_nom_colonne(nom, max_length=30):
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

    # Limiter la longueur du nom
    if len(nom) > max_length:
        nom = nom[:max_length]
    return nom

csv_files = [
    '/home/florian/Desktop/groupe_4/csv_non_modifié/Anciens/Parcoursup_2018.csv',
    '/home/florian/Desktop/groupe_4/csv_non_modifié/Anciens/Parcoursup_2024.csv'
]

for fichier in csv_files:
    try:
        df = pd.read_csv(fichier, sep=';', encoding='utf-8', engine='python')
        # Appliquer la normalisation et la limitation de longueur aux noms de colonnes
        df.columns = [normaliser_nom_colonne(col) for col in df.columns]
        # Sauvegarder le fichier
        nom_fichier_sortie = fichier.replace('.csv', '_normalise_raccourci.csv')
        df.to_csv(nom_fichier_sortie, index=False, sep=';', encoding='utf-8')
        print(f"Fichier {fichier} traité avec succès. Noms de colonnes raccourcis.")
    except Exception as e:
        print(f"Erreur lors du traitement du fichier {fichier} : {e}")
