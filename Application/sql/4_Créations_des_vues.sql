-- Début de la transaction
BEGIN;

-- Toujours utiliser le même schéma
SET search_path TO "ParcourStat";


-- Création d'une vue permettant de montrer le nombre de formation par région. 
-- Cela permet de créer une première connaissance : la répartition inégale de l'accès à la formation supérieur du à la concentration des formations en île de France et à la rareté de ces formations notamment dans les Territoires d'Outre Mer et les lieux d'expatriation.
-- Nous pourrions utiliser un jeu de donnée sur le taux de ruralités dans les régions afin de faire ressortir la répartitions des formations en fonction de l'urbanisation. 
-- Cela créer une nouvelle information : la répartition inégale de l'accès à l'enseignement supérieur en fonction d'un critère de ruralité. 
-- Mais peu révélateur quant à l'inégalité de la repartition des formations d'enseignements supérieur sur le territoire français en fonction de l'éloignement avec la capitale française.

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
-- Le chiffre est calculé en fonction du rapport candidates/admises. Donc 25 par exemple voudrais que seulement 25 des candidates ont été acceptées.
-- Cela permet de créer une première connaissance sur la parité dans les formations. 
-- Cette vue est à enrichir, mais elle n'est pour le moment pas encore élaborée à son maximum. 


create view taux_filles_admises_par_disciplines as 
	select d.nom as discipline, AVG(a.pa_f) as taux_acceptation_candidates
	from "ParcourStat".admissions a 
	join "ParcourStat".formation f on a.formation_id = f.id 
	join "ParcourStat".discipline d on f.discipline_id = d.id 
	GROUP BY discipline 
	order by taux_acceptation_candidates DESC;

-- Fin de transction

COMMIT; 