--1: Vérifier l’influence de la vitesse du vent
/*Cette requête compare les turbines sur la période disponible. Les unités 
de l’énergie seront celles de la colonne energy_produced */
 
SELECT
    t.turbine_name,
    COUNT(*) AS nombre_mesures,
    ROUND(SUM(f.energy_produced), 2) AS energie_totale,
    ROUND(AVG(f.energy_produced), 2) AS energie_moyenne
FROM workspace.wind_power.fact_production AS f
JOIN workspace.wind_power.dim_turbine AS t
    ON f.turbine_id = t.turbine_id
GROUP BY t.turbine_name
ORDER BY energie_totale DESC;



/*Turbine A affiche la production totale et moyenne la plus élevée.
Turbines B et C ont des résultats proches : leur énergie totale diffère d’environ 3 311 unités.
Les trois turbines ont le même nombre de mesures : la comparaison porte donc sur des volumes d’observations équivalents. */

--2: Étudier l’évolution dans le temps
/* Cette requête donne la production totale pour chaque jour. Elle nous permettra de repérer 
les journées où la production est plus élevée ou plus faible */


SELECT
    d.date_id AS date,
    ROUND(SUM(f.energy_produced), 2) AS energie_totale
FROM workspace.wind_power.fact_production AS f
JOIN workspace.wind_power.dim_date AS d
    ON f.date_id = d.date_id
GROUP BY d.date_id
ORDER BY d.date_id;

/* Nous avons maintenant la production quotidienne sur les 14 jours, du 1er au 14 juin 2024.
Le 13 juin est le jour le plus productif de la période.
Le 5 juin est le jour le moins productif.
L’écart entre ces deux journées est de 36 819,23 unités, soit environ 7,7 % de la production du jour le plus faible.
La production varie d’un jour à l’autre : cela peut être expliqué par les condition du vent.
*/


--3. Vérifier l’influence de la vitesse du vent
/* Cette analyse compare la production moyenne selon trois catégories de vitesse du vent. 
Les seuils sont exploratoires, pas des seuils techniques universels. */


SELECT
    CASE
        WHEN s.wind_speed < 5 THEN 'Faible (< 5)'
        WHEN s.wind_speed < 10 THEN 'Modérée (5 à 10)'
        ELSE 'Forte (10 et plus)'
    END AS categorie_vent,
    COUNT(*) AS nombre_mesures,
    ROUND(AVG(s.wind_speed), 2) AS vitesse_moyenne,
    ROUND(AVG(s.energy_produced), 2) AS energie_moyenne,
    ROUND(SUM(s.energy_produced), 2) AS energie_totale
FROM workspace.wind_power.wind_power_silver AS s
GROUP BY
    CASE
        WHEN s.wind_speed < 5 THEN 'Faible (< 5)'
        WHEN s.wind_speed < 10 THEN 'Modérée (5 à 10)'
        ELSE 'Forte (10 et plus)'
    END
ORDER BY vitesse_moyenne;

/*La catégorie vent faible présente l’énergie moyenne la plus élevée.
La catégorie vent fort représente la majorité des mesures, mais son énergie moyenne est légèrement plus faible.
L’écart entre les moyennes extrêmes est d’environ 0,83 %.*/

--4: Evaluation du statut opérationnel
--vérifier si les arrêts ou autres statuts d’exploitation peuvent contribuer aux différences observées.

SELECT
    s.status AS statut,
    COUNT(*) AS nombre_mesures,
    ROUND(AVG(f.energy_produced), 2) AS energie_moyenne,
    ROUND(SUM(f.energy_produced), 2) AS energie_totale
FROM workspace.wind_power.fact_production AS f
JOIN workspace.wind_power.dim_operational_status AS s
    ON f.status_id = s.status_id
GROUP BY s.status
ORDER BY energie_moyenne DESC;

--toutes les mesures associées à un statut autre que Online ont une énergie produite égale à zéro.
--Mesures Online 5 485 soit 90,7 % des mesures
--Mesures non Online 563 soit 9,3 % des mesures
--Énergie totale produite pendant la période 6 847 971,29

/* Voici les principaux constats :
- Online : 5 485 mesures, avec une énergie moyenne de 1 248,49.
- Fault : 57 mesures, énergie nulle.
- Preventive Maintenance : 154 mesures, énergie nulle.
- Reactive Maintenance : 171 mesures, énergie nulle.
- Offline : 130 mesures, énergie nulle.
- Inspection : 51 mesures, énergie nulle. */

--4.— Calculer un indicateur de disponibilité
/*mesurer la proportion des observations Online pour chaque turbine, 
afin de voir si certaines sont plus souvent indisponibles que d'autres.*/


SELECT
    t.turbine_name,
    COUNT(*) AS nombre_mesures,
    SUM(CASE WHEN s.status = 'Online' THEN 1 ELSE 0 END) AS mesures_online,
    ROUND(100.0 * SUM(CASE WHEN s.status = 'Online' 
    THEN 1 ELSE 0 END)/ COUNT(*),2) AS taux_online_pct,
    SUM(CASE WHEN s.status != 'Online' 
         THEN 1 ELSE 0 
         END) AS mesures_non_online
FROM workspace.wind_power.fact_production AS f
JOIN workspace.wind_power.dim_turbine AS t
    ON f.turbine_id = t.turbine_id
JOIN workspace.wind_power.dim_operational_status AS s
    ON f.status_id = s.status_id
GROUP BY t.turbine_name
ORDER BY taux_online_pct DESC;

--Nous avons maintenant un quatrième résultat pour ton projet : le taux d’observations Online varie légèrement selon les turbines.
/* Turbine B présente le taux Online le plus élevé : 91,17 %.
Turbine C présente le taux le plus faible : 89,93 %, avec 203 mesures non Online.
L’écart entre les deux est de 1,24 point de pourcentage.
Chaque turbine compte 2 016 observations, ce qui permet une comparaison directe sur cette période. */


--— 5. Préparer la synthèse de l’analyse
/*avons désormais exploré quatre axes : la production par turbine, l’évolution quotidienne, la relation avec le vent et les statuts opérationnels.
les résultats de production par turbine et de disponibilité sont-ils cohérents avec les statuts et l’énergie ?*/
--Cette vérification permettra de repérer les éventuelles exceptions : des mesures Online sans production, ou des mesures non Online avec une production positive.

SELECT
    t.turbine_name,
    COUNT(*) AS total_mesures,
    SUM(CASE WHEN s.status = 'Online' THEN 1 ELSE 0 END)
        AS mesures_online,
    SUM(CASE WHEN s.status != 'Online' THEN 1 ELSE 0 END)
        AS mesures_non_online,
    SUM(CASE WHEN s.status = 'Online'
             AND f.energy_produced = 0 THEN 1 ELSE 0 END)
        AS mesures_online_energie_nulle,
    SUM(CASE WHEN s.status != 'Online'
             AND f.energy_produced != 0 THEN 1 ELSE 0 END)
        AS mesures_non_online_energie_positive
FROM workspace.wind_power.fact_production AS f
JOIN workspace.wind_power.dim_turbine AS t
    ON f.turbine_id = t.turbine_id
JOIN workspace.wind_power.dim_operational_status AS s
    ON f.status_id = s.status_id
GROUP BY t.turbine_name
ORDER BY t.turbine_name;

/*Parfait ! La vérification confirme que les données sont cohérentes avec les règles observées dans ton jeu de données.
Pour les trois turbines :
- aucune mesure Online n’a une énergie nulle ;
- aucune mesure non Online n’a une énergie positive ;
- le nombre total de mesures est bien de 2 016 par turbine.*/

--Bilan de l’analyse des données
   --Résultats clés — Wind Power DWH
/* 
Production par turbine
La turbine A affiche la production totale la plus élevée : 2 329 587,60 unités.*/

/* Évolution quotidienne
Le 13 juin 2024 est la journée la plus productive, avec 513 575,58 unités. */

/* Vitesse du vent
La production moyenne varie peu entre les catégories définies. Il faut prendre en compte l’influence du vent.*/

/* Statuts opérationnels
90,7 % des observations sont Online. La turbine B présente le taux Online le plus élevé, à 91,17 %. */
