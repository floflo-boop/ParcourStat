CREATE TABLE "Test".region (
    id   SERIAL PRIMARY KEY,
    nom  TEXT NOT NULL UNIQUE
);

/* Insertion des données dans la table région */

INSERT INTO "Test".region(nom, id)
SELECT DISTINCT p.Region_etablissement
FROM "Test".parcoursup2024 p
WHERE p.Region_etablissement IS NOT NULL
ON CONFLICT (nom) DO NOTHING;
