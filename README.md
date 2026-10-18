# **Wind Power Data Warehouse**

## **1. Présentation du projet**

Ce projet consiste à construire un entrepôt de données dédié à l'analyse de la production d'énergie éolienne. Il utilise une architecture analytique reposant sur AWS S3, Databricks et dbt Core.

L'objectif est de transformer des données brutes de production éolienne en données structurées, fiables et exploitables pour des analyses SQL et des tableaux de bord.

## **Objectifs**

Stocker les données brutes dans AWS S3.

Transformer et nettoyer les données avec dbt Core.

Utiliser Databricks comme plateforme de traitement et de stockage analytique.

Organiser les données selon une architecture Bronze, Silver et Gold.

Construire un modèle dimensionnel en étoile.

Contrôler la qualité des données grâce aux tests dbt.

Versionner le code avec Git et GitHub.

## **2. Technologies utilisées**

**Technologie**      **Rôle**

AWS S3       Stockage des données brutes

Databricks   Traitement SQL et stockage des tables analytiques

dbt Core     Transformation des données et tests qualité

Python       Environnement d'exécution de dbt

Git          Gestion des versions

GitHub       Hébergement du code source


## **3. Architecture des données**

Le projet suit une architecture en trois couches.

### **Bronze — Données brutes**

Les données sources sont stockées dans AWS S3, puis mises à disposition de Databricks.

Source : wind_power_data.csv

Table : workspace.wind_power.wind_power_bronze

Rôle : conserver les données sources avant transformation.

### **Silver — Données nettoyées**

Le modèle wind_power_silver prépare les données pour l'analyse.

Les transformations comprennent notamment :

La normalisation du format de l'heure.

L'extraction des composantes temporelles : heure, minute, seconde, jour, mois, trimestre et année.

La classification des observations en périodes de la journée.

L'arrondi des mesures de vitesse du vent et d'énergie produite.

### **Gold — Modèle dimensionnel**

La couche Gold organise les données sous la forme d'un schéma en étoile.

**Dimensions :**

dim_date : informations calendaires.

dim_time : informations horaires et périodes de la journée.

dim_turbine : caractéristiques des turbines et de leur localisation.

dim_operational_status : statuts opérationnels et départements responsables.

**Table de faits :**

fact_production : identifiants de production, clés vers les dimensions et mesures de production éolienne.

## **4. Structure du dépôt**

.
## Structure du projet

```text
├── dbt_project.yml
├── models/
│   ├── sources.yml
│   ├── silver/
│   │   └── wind_power_silver.sql
│   └── gold/
│       ├── schema.yml
│       ├── dimensions/
│       │   ├── dim_date.sql
│       │   ├── dim_time.sql
│       │   ├── dim_turbine.sql
│       │   └── dim_operational_status.sql
│       └── facts/
│           └── fact_production.sql
├── tests/
│   ├── assert_fact_production_unique.sql
│   ├── assert_fact_status_fk.sql
│   └── assert_fact_turbine_fk.sql
└── README.md
```

## **5.Prérequis**

Python 3.12

dbt Core et l'adaptateur Databricks

Un workspace Databricks accessible

Un accès autorisé aux données sources

Git

Les versions utilisées lors de la validation du projet étaient :

Python 3.12.14

dbt Core 1.12.5

dbt-databricks 1.12.7

## **6. Installation et configuration**

**Cloner le dépôt**

git clone https://github.com/borokoromara/dbt-databricks-aws-dwhproject.git
cd dbt-databricks-aws-dwhproject


**Créer un environnement Python**

Sur macOS, avec Python 3.12 installé :

python3.12 -m venv .venv
source .venv/bin/activate
python -m pip install --upgrade pip
python -m pip install dbt-core==1.12.5 dbt-databricks==1.12.7


**Configurer l'accès à Databricks**

Définir les variables d'environnement suivantes dans le terminal :

DATABRICKS_HOST

DATABRICKS_HTTP_PATH

DATABRICKS_TOKEN

Créer ensuite un fichier local profiles.yml à la racine du projet avec la configuration Databricks adaptée au workspace et au schéma cibles.

Le fichier profiles.yml et les jetons d'accès ne doivent jamais être publiés dans GitHub.

## **7. Exécuter le projet**

Depuis la racine du dépôt, avec l'environnement virtuel activé et les accès Databricks configurés :

**Vérifier la configuration**

dbt debug --profiles-dir .

**Exécuter tous les modèles**

dbt run --profiles-dir .

**Exécuter uniquement le modèle Silver**

dbt run --select wind_power_silver --profiles-dir .

**Exécuter les tests**

dbt test --profiles-dir .

**Nettoyer les fichiers générés**

dbt clean --profiles-dir .

## **8. Résultats et qualité des données**

Les vérifications effectuées sur le jeu de données ont donné les résultats suivants :

**Indicateur**                                           **Résultat**

Enregistrements dans la table de faits                      6 048

Identifiants de production distincts                        6 048

Dates distinctes                                               14

Horaires distincts                                            144

Turbines distinctes                                             3

Combinaisons statut / département                               6

Identifiants de turbine manquants dans les faits                0

Identifiants de statut manquants dans les faits                 0

Valeurs d'énergie manquantes dans les faits                     0

Tests dbt réussis                                       18 sur 18

Les tests contrôlent notamment l'unicité des identifiants de production, l'absence de valeurs nulles sur les colonnes ciblées et la validité des clés étrangères vers les dimensions.

## **9. Sécurité et bonnes pratiques**

Ne jamais versionner les jetons d'accès Databricks.

Conserver profiles.yml et les fichiers locaux de configuration hors du dépôt.

Utiliser un environnement Python virtuel.

Exécuter les tests dbt après les modifications des modèles.

Vérifier le statut Git avant chaque commit.

## **10. Améliorations futures**

Les évolutions envisagées comprennent :

Automatiser l'exécution et les tests dbt avec GitHub Actions.

Développer des indicateurs SQL sur la production éolienne.

Créer des visualisations ou des tableaux de bord.

Renforcer la reproductibilité et la gestion des clés substituts des dimensions.

Documenter les modèles et les dépendances de données plus en détail.

**Auteur et dépôt**

Dépôt GitHub : https://github.com/borokoromara/dbt-databricks-aws-dwhproject

**Analyse des données**
L’analyse a été réalisée à partir des données de production éolienne du 1er au 14 juin 2024, à l’aide de requêtes SQL exécutées dans Databricks.

## **1. Comparaison de la production par turbine**

Turbine         Nombre de mesures    Énergie totale     Énergie moyenne

Turbine A             2 016           2 329 587,60         1 155,55

Turbine C             2 016           2 260 847,52         1 121,45

Turbine B             2 016           2 257 536,17         1 119,81

La turbine A présente la production totale la plus élevée sur la période observée. Les trois turbines disposent du même nombre de mesures, ce qui facilite leur comparaison.

## **2. Évolution quotidienne de la production**

**Production quotidienne maximale :** 513 575,58 le 13 juin 2024.
**Production quotidienne minimale :** 476 756,35 le 5 juin 2024.

La production varie au cours de la période. Une analyse complémentaire des conditions météorologiques et opérationnelles serait nécessaire pour expliquer ces fluctuations.


## **3. Relation entre vitesse du vent et énergie produite**

Les observations ont été réparties en trois catégories exploratoires :

Catégorie de vent   Nombre de mesures  Vitesse moyenne  Énergie moyenne

Faible (< 5)             814                3,52          1 138,84

Modérée (5 à 10)       1 325                7,51          1 136,80

Forte (10 et plus)     3 905               17,45          1 129,36

Dans ce jeu de données, la production moyenne ne croît pas avec la vitesse moyenne du vent selon ces catégories. Ce résultat descriptif ne démontre pas une relation causale. Les unités, les conditions d’exploitation et la distribution des observations doivent être prises en compte pour approfondir cette analyse.

## **4. Statuts opérationnels**
Statut                  Nombre de mesures              Énergie moyenne

Online                            5 485                     1 248,49

Fault                                57                            0

Preventive Maintenance              154                            0

Reactive Maintenance                171                            0

Offline                             130                            0

Inspection                           51                            0

Les observations non Online présentent une énergie produite nulle dans les données analysées. Les contrôles complémentaires n’ont détecté aucune observation Online avec une énergie nulle ni aucune observation non Online avec une énergie positive.

## **5. Taux d'observations Online par turbine**

Turbine         Mesures Online     Mesures non Online         Taux Online

Turbine B               1 838                    178              91,17 %

Turbine A               1 834                    182              90,97 %

Turbine C               1 813                    203              89,93 %


La turbine B présente le taux d'observations Online le plus élevé sur la période. Cet indicateur représente la proportion des observations classées Online, et non un taux officiel de disponibilité technique.


## **Conclusion**

Ce projet met en œuvre un entrepôt de données éoliennes avec une architecture en couches Bronze, Silver et Gold, des modèles dbt, un schéma en étoile et des tests automatisés.

Les analyses SQL permettent de comparer les turbines, de suivre les variations quotidiennes de production et d’examiner les relations entre énergie produite, vitesse du vent et statuts opérationnels.
