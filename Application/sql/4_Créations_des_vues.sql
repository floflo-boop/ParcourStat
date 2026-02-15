-- Début de la transaction
BEGIN;

-- Toujours utiliser le même schéma
CREATE SCHEMA IF NOT EXISTS "ParcourStat";
SET search_path TO "ParcourStat";


-- Création d'une vue permettant de montrer le nombre de formation par région. 
-- Cela permet de créer une première connaissance : la répartition inégale de l'accès à la formation supérieure dû à la concentration des formations en île de France et à la rareté de ces formations notamment dans les Territoires d'Outre Mer et les lieux d'expatriation.
-- Nous pourrions utiliser un jeu de données sur le taux de ruralités dans les régions afin de faire ressortir la répartition des formations en fonction de l'urbanisation. 
-- Cela crée une nouvelle information : la répartition inégale de l'accès à l'enseignement supérieur en fonction d'un critère de ruralité. 
-- Mais peu révélateur quant à l'inégalité de la repartition des formations d'enseignement supérieur sur le territoire français en fonction de l'éloignement avec la capitale française.

create view nombre_formation_par_region as  
	select r.nom as region, count(f.id ) as nbr_formation 
	from region r
	join departement d on r.id = d.region_id 
	join commune c on d.code = c.departement_id 
	join etablissement e on c.id = e.commune_id 
	join formation f on e.id = f.etablissement_id 
	group by r.nom 
	order by nbr_formation DESC;



-- Création d'une vue permettant de montrer le taux d'acceptation des filles dans les disciplines en combinant 2018 et 2024. 
-- Le chiffre est calculé en fonction du rapport candidates/admises. Donc 25 par exemple voudrait que seulement 25 des candidates aient été acceptées.
-- Cela permet de créer une première connaissance sur la parité dans les formations. 
-- Cette vue est à enrichir, elle n'est pour le moment pas encore élaborée à son maximum. 


create view taux_filles_acceptées_par_disciplines as 
	select d.nom as discipline, AVG(a.pa_f) as taux_acceptation_candidates
	from admissions a 
	join formation f on a.formation_id = f.id 
	join discipline d on f.discipline_id = d.id 
	GROUP BY discipline 
	order by taux_acceptation_candidates DESC;


-- Création d'une vue permettant de montrer le nombre moyen de boursiers admis par région.
-- Elle permet d'identifier les régions qui accueillent le plus de boursiers et celles qui en accueillent le moins.
-- Cela crée de la connaissance autour du taux d'accessibilité sociale de chaque région.
-- Toutefois, elle reste limitée puisqu'elle ne prend pas en compte le nombre de formations par régions, croisée avec le nombre de boursiers. Une région qui accueille un grand nombre de boursiers ne possède donc pas forcément une grande accessibilité sociale, mais peut avoir un grand nombre de formations.


create view boursiers_admis_regions as
select
   region.nom AS region,
   AVG(admissions.PA_NB_B) AS boursiers_admis
from admissions
join formation ON admissions.formation_id = formation.id
join etablissement ON formation.etablissement_id = etablissement.id
join commune ON etablissement.commune_id = commune.id
join departement ON commune.departement_id = departement.code
join region ON departement.region_id = region.id
group by region.nom;

-- Fin de transaction

COMMIT; 