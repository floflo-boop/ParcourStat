BEGIN;

INSERT INTO "Test".Etablissement (Etablissement, ID)
SELECT DISTINCT ON (p."Code_UAI_etablissement")
    p."Etablissement",
    p."Code_UAI_etablissement"
FROM "Test".parcoursup2018 p
ORDER BY p."Code_UAI_etablissement", p."Etablissement";

COMMIT;